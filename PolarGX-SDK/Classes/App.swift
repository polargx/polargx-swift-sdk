import Foundation
import UIKit

typealias UntrackedEvent = (eventName: String, date: Date, attributes: [String: Any])

class InternalPolarApp: PolarApp {
    private let appId: String
    private let apiKey: String
    private let onLinkClickHandler: OnLinkClickHandler
        
    lazy var apiService = APIService(server: Configuration.Env.server)
    
    /// The storage location to save user data and events (belong to SDK)
    lazy var appDirectory = FileStorageURL.sdkDirectory.appendingSubDirectory(appId)
    
    private var currentUserSession: UserSession?
    private var otherUserSessions = [UserSession]()
    private var pendingEvents = [UntrackedEvent]()
    
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
        
        self.pendingEvents.reserveCapacity(Self.PendingEventsCapacity)
        self.startInitializingApp()
    }
    
    private func startInitializingApp() {
        apiService.defaultHeaders = [
            "x-api-key": apiKey
        ]
        startTrackingAppLifeCycle()
        
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
                }
            }
            
            var events: [UntrackedEvent] = []
            if currentUserSession == nil, let userID = userID {
                let fileUrl = appDirectory.file(name: "events_\(Date().timeIntervalSince1970)_\(UUID().uuidString).json")
                Logger.log("TrackingEvents stored in `\(fileUrl.absoluteString)`")
                
                events = pendingEvents;
                pendingEvents = []
                pendingEvents.reserveCapacity(Self.PendingEventsCapacity)
                
                currentUserSession = UserSession(organizationUnid: appId, userID: userID, apiService: apiService, trackingStorageURL: fileUrl)
            }
            
            Task {
                await currentUserSession?.trackEvents(events)
                await currentUserSession?.setAttributes(attributes ?? [:])
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
                if pendingEvents.count == Self.PendingEventsCapacity {
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
            DispatchQueue.main.async {
                self.onLinkClickHandler(openningURL, nil, error)
            }
        }
    }

    //MARK: PolarApp methods
    
    @objc public override func updateUser(userID: String?, attributes: [String: Any]?) {
        setUser(userID: userID, attributes: attributes)
    }
    
    @objc public override func trackEvent(name: String, attributes: [String: Any]) {
        trackEvent(name: name, date: Date(), attributes: attributes)
    }
    
    @discardableResult
    @objc public override func continueUserActivity(_ activity: NSUserActivity) -> Bool {
        switch activity.activityType {
        case NSUserActivityTypeBrowsingWeb:
            if let url = activity.webpageURL, let (subDomain, slug) = Formatter.validateSupportingURL(url) {
                Task { await handleOpenningURL(url, subDomain: subDomain, slug: slug, clickUnid: nil) }
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
        
        Task { await handleOpenningURL(httpsUrl, subDomain: subDomain, slug: slug, clickUnid: clickId) }
        return true
    }
}

//MARK: - App
@objc
public class PolarApp: NSObject {
    @objc public static var isLoggingEnabled = true
    @objc public static var PendingEventsCapacity = 100

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
    
    @objc public func updateUser(userID: String?, attributes: [String: Any]?) {}
    @objc public func trackEvent(name: String, attributes: [String: Any]) { }
    @objc public func continueUserActivity(_ activity: NSUserActivity) -> Bool { false }
    @objc public func openUrl(_ url: URL) -> Bool { false }
}
