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
    
    public static var isLoggingEnabled = true
    
    private var trackingEventQueue: TrackingEventQueue!
    
    var apiService = APIService(server: Configuration.Server)
    
    private init(appId: String, apiKey: String) {
        self.appId = appId
        self.apiKey = apiKey
        
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
                timestamp: date.timeIntervalSince1970,
                data: [:]
            )
            
            var initializazingError: Error? = nil
            repeat {
                do {
                    try await apiService.trackEvent(launchEvent)
                    try Task.checkCancellation()
                    initializazingError = nil
                    
                    Log("Initializing - successful ✅")
                    
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
            timestamp: date.timeIntervalSince1970,
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
                    Log("Tracking - successful ✅")
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
}

//Access
public extension LinkAttributionApp {
    private static var _shared: LinkAttributionApp?
    static var shared: LinkAttributionApp! {
        guard let instance = _shared else { fatalError("LinkAttributionApp hasn't been initialized!") }
        return instance
    }
    static func initialize(appId: String, apiKey: String)  {
        _shared = LinkAttributionApp(appId: appId, apiKey: apiKey)
    }
    
    func trackEvent(name: String, attributes: [String: String]) {
        let date = Date()
        Task {
            await trackEvent(name: name, date: date, attributes: attributes)
        }
    }
}
