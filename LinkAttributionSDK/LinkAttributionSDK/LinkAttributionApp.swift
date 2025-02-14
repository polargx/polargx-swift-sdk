import Foundation
import UIKit

private func Log(_ sf: @autoclosure () -> String) {
    if LinkAttributionApp.isLoggingEnabled {
        print("[LinkAttribution/Debug] \(sf())")
    }
}

private func RLog(_ sf: @autoclosure () -> String) {
    print("[LinkAttribution] \(sf())")
}

public class LinkAttributionApp {
    private let appId: String
    private let apiKey: String
    private let onLinkClickHandler: OnLinkClickHandler
    
    public static var isLoggingEnabled = true
    
    private var trackingEventQueue: TrackingEventQueue!
    
    var apiService = APIService(server: Configuration.Server)
    
    private init(appId: String, apiKey: String, onLinkClickHandler: @escaping OnLinkClickHandler) {
        self.appId = appId
        self.apiKey = apiKey
        self.onLinkClickHandler = onLinkClickHandler
        
        self.startInitializingApp()
    }
    
    private func startInitializingApp() {
        trackingEventQueue = TrackingEventQueue(fileUrl: FileStorageURL.sdkDirectory.file(name: "tracking.json"))

        apiService.defaultHeaders = [
            "x-api-key": apiKey
        ]
        
        let date = Date()
        Task {
            let launchEvent = TrackEventModel(
                organizationUnid: appId,
                eventName: "app_launch",
                eventTime: date,
                data: [:]
            )
            
            var initializazingError: Error? = nil
            repeat {
                do {
                    try await apiService.trackEvent(launchEvent)
                    try Task.checkCancellation()
                    initializazingError = nil
                                        
                }catch let error where error is URLError {
                    Log("Initializing - failed ⛔️ + retrying 🔁: \(error)")
                    initializazingError = error
                    try? await Task.sleep(nanoseconds: 1_000_0000_000)
                    
                }catch let error {
                    Log("Initializing - failed ⛔️ + stopped ⛔️: \(error)")
                    initializazingError = nil
                    
                    if error.apiError?.httpStatus == 403 {
                        RLog("⛔️⛔️⛔️ INVALID appId or apiKey! ⛔️⛔️⛔️")
                    }
                }
            }while initializazingError != nil
            
            await startTrackingQueueIfNeeded()
        }
        
        startTrackingAppLifeCycle()
    }
    
    private func trackEvent(name: String, date: Date, attributes: [String: String]) async {
        await trackingEventQueue.push(TrackEventModel(
            organizationUnid: self.appId,
            eventName: name,
            eventTime: date,
            data: attributes
        ))
        await startTrackingQueueIfNeeded()
    }
    
    private func startTrackingQueueIfNeeded() async {
        guard await trackingEventQueue.trackingQueueIsRunning == false else {
            return
        }
        
        await trackingEventQueue.setTrackingQueueIsRunning(true)

        Task {
            do {
                while let event = await trackingEventQueue.willPop() {
                    try await apiService.trackEvent(event)
                    await trackingEventQueue.pop()
                }
                
            }catch let error {
                Log("Tracking - failed ⛔️ + stopped ⛔️: \(error)")
            }
            
            await trackingEventQueue.setTrackingQueueIsRunning(false)
        }
    }
    
    private func startTrackingAppLifeCycle() {
        let nc = NotificationCenter.default
        let queue = OperationQueue.main
        let track = { [weak self] (notification: Notification) in
            let date = Date()
            let eventName = switch notification.name {
            case UIApplication.willEnterForegroundNotification: "app_open"
            case UIApplication.didEnterBackgroundNotification: "app_close"
            case UIApplication.didBecomeActiveNotification: "app_active"
            case UIApplication.willResignActiveNotification: "app_inactive"
            case UIApplication.willTerminateNotification: "app_ternimate"
            default: "unknown_lifecycle"
            }
            Task { await self?.trackEvent(name: eventName, date: date, attributes: [:]) }
        }
        nc.addObserver(forName: UIApplication.willEnterForegroundNotification, object: nil, queue: queue, using: track)
        nc.addObserver(forName: UIApplication.didEnterBackgroundNotification, object: nil, queue: queue, using: track)
        nc.addObserver(forName: UIApplication.didBecomeActiveNotification, object: nil, queue: queue, using: track)
        nc.addObserver(forName: UIApplication.willResignActiveNotification, object: nil, queue: queue, using: track)
        nc.addObserver(forName: UIApplication.willTerminateNotification, object: nil, queue: queue, using: track)
    }
    
    private func handleOpenningURL(_ openningURL: URL, subDomain: String, slug: String) async {
        let clickTime = Date()
        
        do {
            let linkData = try await apiService.getLinkData(domain: subDomain, slug: slug)
            try await apiService.trackLinkClick(LinkClickModel(
                trackClick: subDomain, slug: slug, clickTime: clickTime, deviceData: [:], additionalData: [:])
            )
            
            DispatchQueue.main.async {
                self.onLinkClickHandler(openningURL, linkData?.data?.content ?? [:], nil)
            }
            
        }catch let error {
            DispatchQueue.main.async {
                self.onLinkClickHandler(openningURL, nil, error)
            }
        }
    }
}

//Access
public extension LinkAttributionApp {
    private static var _shared: LinkAttributionApp?
    static var shared: LinkAttributionApp! {
        guard let instance = _shared else { fatalError("LinkAttributionApp hasn't been initialized!") }
        return instance
    }
        
    typealias OnLinkClickHandler = (_ link: URL, _ data: [String: Any]?, _ error: Error?) -> Void
    static func initialize(appId: String, apiKey: String, onLinkClickHandler: @escaping OnLinkClickHandler)  {
        _shared = LinkAttributionApp(appId: appId, apiKey: apiKey, onLinkClickHandler: onLinkClickHandler)
    }
    
    func trackEvent(name: String, attributes: [String: String]) {
        let date = Date()
        Task {
            await trackEvent(name: name, date: date, attributes: attributes)
        }
    }
    
    func continueUserActivity(_ activity: NSUserActivity) -> Bool {
        switch activity.activityType {
        case NSUserActivityTypeBrowsingWeb:
            if let url = activity.webpageURL, let (subDomain, slug) = Formatter.validateSupportingURL(url) {
                Task { await handleOpenningURL(url, subDomain: subDomain, slug: slug) }
                return true
            }
            
        default:
            assertionFailure("\(activity.activityType) ???")
        }
        
        return false
    }
    
    func openUrl(_ url: URL) -> Bool {
        guard let (subDomain, slug) = Formatter.validateSupportingURL(url) else {
            return false
        }
        
        var urlComponents = URLComponents.init(url: url, resolvingAgainstBaseURL: false)
        urlComponents?.scheme = "https"
        guard let httpsUrl = urlComponents?.url else {
            return false
        }
        
        Task { await handleOpenningURL(httpsUrl, subDomain: subDomain, slug: slug) }
        return true
    }
}
