import Foundation

private func Log(_ sf: @autoclosure () -> String) {
    if LinkAttributionApp.isLoggingEnabled {
        print("[LinkAttribution/APP] \(sf())")
    }
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
            "app-id": appId,
            "api-key": apiKey
        ]
       
        
        Task {
            let clientActivityCreate = await ClientActivityCreateModel(
                appIdentifier: Bundle.main.bundleIdentifier ?? "",
                appVersion: Bundle.main.object(forInfoDictionaryKey: kCFBundleVersionKey as String) as? String ?? "",
                sdkVersion: Bundle(for: Self.self).object(forInfoDictionaryKey: kCFBundleVersionKey as String) as? String ?? "",
                deviceModel: SystemInfo.deviceModel,
                screenSize: .init(
                    width: Int(SystemInfo.screenSize.width),
                    height: Int(SystemInfo.screenSize.height),
                    resolution: "\(SystemInfo.screenScale)"
                )
            )
            
            var clientActivity: ClientActivityModel!
            var initializazingError: Error? = nil
            repeat {
                do {
                    let activityOrNil = try await apiService.request(
                        method: .POST,
                        path: "/v1/m/client-activities",
                        headers: [:],
                        queries: [:],
                        body: clientActivityCreate,
                        result: ClientActivityModel.self
                    )
                    try Task.checkCancellation()
                    guard let activity = activityOrNil else{
                        throw Errors.with(message: "Can't create client session: nil response")
                    }
                    
                    clientActivity = activity
                    initializazingError = nil
                    
                    Log("startInitializingApp: successful ✅")
                    
                }catch let error {
                    Log("startInitializingApp: failed ⛔️ \(error)")
                    initializazingError = error
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
