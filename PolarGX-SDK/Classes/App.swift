import Foundation
import UIKit

typealias UntrackedEvent = (eventName: String, date: Date, attributes: [String: Any])

class InternalPolarApp: PolarApp {
    private let appId: String
    private let apiKey: String
    private let onLinkClickHandler: OnLinkClickHandler
        
    private lazy var apiService = APIService(configuration: Configuration.Env)
    private lazy var fingerprintGenerator = FingerprintGenerator()
    
    /// The storage location to save user data and events (belong to SDK)
    lazy var appDirectory = FileStorageURL.sdkDirectory.appendingSubDirectory(appId)
    
    private var currentUserSession: UserSession?
    private var otherUserSessions = [UserSession]()
    private var pendingEvents = [UntrackedEvent]()
    
    private var isHandlingOpenUrl = false
    
    /// App: created by `appId` and `apiKey`.
    init(appId: String, apiKey: String, onLinkClickHandler: @escaping OnLinkClickHandler) {
        var apiKey = apiKey;
        if apiKey.hasPrefix("dev_") {
            apiKey.removeFirst(4)
            Configuration.Env = DevEnvConfigutation()
        }
        
        self.appId = appId
        self.apiKey = apiKey
        self.onLinkClickHandler = onLinkClickHandler
        
        super.init()
        
        Logger.initialTime = .init()
        
        self.pendingEvents.reserveCapacity(Self.pendingEventsCapacity)
        self.startInitializingApp()
    }
    
    private func startInitializingApp() {
        apiService.defaultHeaders = [
            "x-api-key": apiKey
        ]
        startTrackingAppLifeCycle()
        
        NotificationCenter.default.addObserver(self, selector: #selector(matchingWebLinkClick), name: UIApplication.willEnterForegroundNotification, object: nil)
        
        /// Loading pending events from last app sessions and send to backend in low prority thread
        let pendingEventFiles = try? FileStorage.listFiles(in: appDirectory).filter({ $0.hasPrefix("events_") })
        Task { await startResolvingPendingEvents(pendingEventFiles: pendingEventFiles) }
    }
    
    //MARK: Setting user
    
    /// Set userID and attributes:
    /// - Create current user session if needed
    /// - Backup user session into the otherUserSessions to keep running for sending events
    private func setUser(userID: String?, attributes: [String: Any]?) {
        Task { @MainActor in
            if let userSession = currentUserSession {
                if userSession.userID != userID {
                    currentUserSession = nil
                    otherUserSessions.append(userSession)
                    Task{
                        await userSession.invalidate()
                    }
                }
            }
            
            var events: [UntrackedEvent] = []
            if currentUserSession == nil, let userID = userID {
                let fileUrl = appDirectory.file(name: "events_\(Date().timeIntervalSince1970)_\(UUID().uuidString).json")
                Logger.log("TrackingEvents stored in `\(fileUrl.absoluteString)`")
                
                events = pendingEvents;
                pendingEvents = []
                pendingEvents.reserveCapacity(Self.pendingEventsCapacity)
                
                currentUserSession = UserSession(organizationUnid: appId, userID: userID, apiService: apiService, trackingStorageURL: fileUrl)
            }
            
            Task {
                await currentUserSession?.trackEvents(events)
                await currentUserSession?.setAttributes(attributes ?? [:])
            }
        }
    }
    
    private func setPushToken(apns: String?, fcm: String?) {
        Task { @MainActor in
            if let userSession = currentUserSession {
                Task {
                    await userSession.setPushToken(apns: apns, fcm: fcm)
                }
            }
        }
    }
    
    //MARK: Track Events
    
    private func trackEvent(name: String, date: Date, attributes: [String: Any]) {
        Task { @MainActor in
            if let userSession = currentUserSession {
                Task {
                    await userSession.trackEvents([(name, date, attributes)])
                }
                
            }else{
                if pendingEvents.count == Self.pendingEventsCapacity {
                    pendingEvents.removeFirst()
                }
                pendingEvents.append((name, date, attributes))
            }
        }
    }
    
    private func startTrackingAppLifeCycle() {
        let nc = NotificationCenter.default
        let queue = OperationQueue.main
        let track = { [weak self] (notification: Notification) in
            let date = Date()
            let eventName: String? = switch notification.name {
            case UIApplication.willEnterForegroundNotification: "app_open"
            case UIApplication.didEnterBackgroundNotification: "app_close"
            case UIApplication.didBecomeActiveNotification: "app_active"
            case UIApplication.willResignActiveNotification: "app_inactive"
            case UIApplication.willTerminateNotification: "app_ternimate"
            default: nil
            }
            
            if let eventName = eventName {
                self?.trackEvent(name: eventName, date: date, attributes: [:])
            }
        }
        nc.addObserver(forName: UIApplication.willEnterForegroundNotification, object: nil, queue: queue, using: track)
        nc.addObserver(forName: UIApplication.didEnterBackgroundNotification, object: nil, queue: queue, using: track)
        nc.addObserver(forName: UIApplication.didBecomeActiveNotification, object: nil, queue: queue, using: track)
        nc.addObserver(forName: UIApplication.willResignActiveNotification, object: nil, queue: queue, using: track)
        nc.addObserver(forName: UIApplication.willTerminateNotification, object: nil, queue: queue, using: track)
    }
    
    private func startResolvingPendingEvents(pendingEventFiles: [String]?) async {
        for file in pendingEventFiles ?? [] {
            let fileUrl = appDirectory.file(name: file)
            let eventQueue = TrackingEventQueue(fileUrl: fileUrl, apiService: apiService)
            if await eventQueue.events.isEmpty {
                try? FileStorage.remove(file: file, in: appDirectory)
                continue
            }
            
            await eventQueue.setReady()
            await eventQueue.sendEventsIfNeeded()
            
            if await eventQueue.events.isEmpty {
                try? FileStorage.remove(file: file, in: appDirectory)
            }
        }
    }
    
    //MARK: Link Clicks
    
    @objc
    private func matchingWebLinkClick() {
        let apiService = apiService
        Task { [weak self] in
            do {
                while self?.isHandlingOpenUrl == true {
                    try await Task.sleep(nanoseconds: 1_000_000_000)
                }
                
                guard
                    let ip = try await apiService.getClientIP(),
                    let fingerprint = await self?.fingerprintGenerator.generateFingerprint(ip: ip),
                    let linkClickedResponse = try await apiService.matchLinkClick(fingerprint: fingerprint)
                else {
                    throw Errors.with(message: "matchingWebLinkClick failed: Internal SERVER error.")
                }
                
                guard let linkClick = linkClickedResponse.linkClick, !linkClick.sdkUsed else {
                    Logger.rlog("[WARN] matchingWebLinkClick completed: No matching found!")
                    return
                }
                
                var linkUrlString = linkClick.url
                if !linkUrlString.hasPrefix("http://") || !linkUrlString.hasPrefix("https://") {
                    linkUrlString = "https://" + linkUrlString
                }
                
                guard let linkUrl = URL(string: linkUrlString), let (subDomain, slug) = Formatter.validateSupportingURL(linkUrl) else {
                    throw Errors.with(message: "matchingWebLinkClick failed: invalid or unsupported url `\(linkClick.url)`")
                }
                
                await self?.handleOpenningURL(linkUrl, subDomain: subDomain, slug: slug, clickUnid: linkClick.unid)
                
            }catch let error {
                Logger.rlog("[ERROR]⛔️ \(error)")
            }
        }
    }
    
    private func handleOpenningURL(_ openningURL: URL, subDomain: String, slug: String, clickUnid: String?) async {
        let clickTime = Date()
        
        do {
            let linkData = try await apiService.getLinkData(domain: subDomain, slug: slug)
            var clickId = clickUnid;
            if clickId == nil {
                clickId = try await apiService.trackLinkClick(LinkClickModel(
                   trackClick: subDomain, slug: slug, clickTime: clickTime, deviceData: [:], additionalData: [:])
               )?.unid
            }
            
            DispatchQueue.main.sync {
                self.onLinkClickHandler(openningURL, linkData?.data?.content ?? [:], nil)
            }
            
            if let clickId = clickId {
                _ = try await apiService.updateLinkClick(clickUnid: clickId, sdkUsed: true)
            }
            
        }catch let error {
            let clickHandler = onLinkClickHandler
            DispatchQueue.main.async {
                clickHandler(openningURL, nil, error)
            }
        }
    }

    //MARK: PolarApp methods
    
    override var currentUserID: String? {
        return currentUserSession?.userID
    }
    
    @objc public override func updateUser(userID: String?, attributes: [String: Any]?) {
        setUser(userID: userID, attributes: attributes)
    }
    
    override func setPushToken(deviceToken: Data?, fcmToken: String?) {
        let apnsToken = deviceToken?.reduce("", {$0 + String(format: "%02X", $1)})
        setPushToken(apns: apnsToken, fcm: fcmToken)
    }
    
    @objc public override func trackEvent(name: String, attributes: [String: Any]) {
        trackEvent(name: name, date: Date(), attributes: attributes)
    }
    
    @discardableResult
    @objc public override func continueUserActivity(_ activity: NSUserActivity) -> Bool {
        switch activity.activityType {
        case NSUserActivityTypeBrowsingWeb:
            if let url = activity.webpageURL, let (subDomain, slug) = Formatter.validateSupportingURL(url) {
                isHandlingOpenUrl = true
                Task { @MainActor [weak self] in
                    await self?.handleOpenningURL(url, subDomain: subDomain, slug: slug, clickUnid: nil)
                    self?.isHandlingOpenUrl = false
                }
                return true
            }
            
        default:
            assertionFailure("\(activity.activityType) ???")
        }
        
        return false
    }
    
    @discardableResult
    @objc public override func openUrl(_ url: URL) -> Bool {
        guard let (subDomain, slug) = Formatter.validateSupportingURL(url) else {
            return false
        }
        
        var urlComponents = URLComponents.init(url: url, resolvingAgainstBaseURL: false)
        urlComponents?.scheme = "https"
        let clickId = urlComponents?.queryItems?.first(where: { $0.name == "__clid" })?.value
        urlComponents?.queryItems = nil
        guard let httpsUrl = urlComponents?.url else {
            return false
        }
        
        isHandlingOpenUrl = true
        Task { @MainActor [weak self] in
            await self?.handleOpenningURL(httpsUrl, subDomain: subDomain, slug: slug, clickUnid: clickId)
            self?.isHandlingOpenUrl = false
        }
        return true
    }
}

//MARK: - App
@objc
public class PolarApp: NSObject {
    @objc public static var isLoggingEnabled = true
    @objc public static var pendingEventsCapacity = 100
    @objc public static var minimumIntervalForSendingUserAttributes: UInt64 = 1_000_000_000

    private static var _shared: PolarApp?
    @objc public static var shared: PolarApp {
        _shared ?? {
            Logger.rlog("PolarApp hasn't been initialized!")
            return PolarApp()
        }()
    }
    
    public typealias OnLinkClickHandler = (_ link: URL, _ data: [String: Any]?, _ error: Error?) -> Void
    @objc public static func initialize(appId: String, apiKey: String, onLinkClickHandler: @escaping OnLinkClickHandler)  {
        _shared = InternalPolarApp(appId: appId, apiKey: apiKey, onLinkClickHandler: onLinkClickHandler)
    }
    
    @objc public var currentUserID: String? { nil }
    @objc public func updateUser(userID: String?, attributes: [String: Any]?) {}
    @objc public func setPushToken(deviceToken: Data?, fcmToken: String?) {}
    @objc public func trackEvent(name: String, attributes: [String: Any]) { }
    
    @discardableResult
    @objc public func continueUserActivity(_ activity: NSUserActivity) -> Bool { false }
    @discardableResult
    @objc public func openUrl(_ url: URL) -> Bool { false }
}
