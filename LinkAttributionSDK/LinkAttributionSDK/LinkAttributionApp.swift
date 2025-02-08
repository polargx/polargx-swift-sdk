import Foundation

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
    
    var apiService = APIService(server: Configuration.Server)
    
    private init(appId: String, apiKey: String) {
        self.appId = appId
        self.apiKey = apiKey
        
        startInitializingApp()
    }
    
    private func startInitializingApp() {
        apiService.defaultHeaders = [
            "x-api-key": apiKey
        ]
        
        Task {
            let launchEvent = TrackEventModel(
                organizationUnid: appId,
                eventName: "app_launch",
                timestamp: Date().timeIntervalSince1970,
                data: [:]
            )
            
            var initializazingError: Error? = nil
            repeat {
                do {
                    try await apiService.trackEvent(launchEvent)
                    try Task.checkCancellation()
                    initializazingError = nil
                    
                    Log("startInitializingApp: successful ✅")
                    
                }catch let error where error is URLError {
                    Log("startInitializingApp: failed ⛔️ + retry 🔁 \(error)")
                    initializazingError = error
                    try? await Task.sleep(nanoseconds: 1_000_0000_000)
                    
                }catch let error {
                    Log("startInitializingApp: failed ⛔️ + stop ⛔️ \(error)")
                    initializazingError = nil
                    
                    if error.apiError?.httpStatus == 403 {
                        RLog("⛔️⛔️⛔️ INVALID appId or apiKey! ⛔️⛔️⛔️")
                    }
                }
            }while initializazingError != nil
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
    static func initialize(appId: String, apiKey: String)  {
        _shared = LinkAttributionApp(appId: appId, apiKey: apiKey)
    }
}
