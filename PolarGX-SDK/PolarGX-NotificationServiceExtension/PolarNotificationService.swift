import Foundation
import UserNotifications

/// PolarGX NotificationServiceExtension SDK
/// Tracks push notification delivery and enables rich media attachments
@objc
open class PolarNotificationService: UNNotificationServiceExtension {
    var contentHandler: ((UNNotificationContent) -> Void)?
    var bestAttemptContent: UNMutableNotificationContent?
    var resultDescription: String = ""
    
    private var appGroupStorage: AppGroupStorage?
    private var apiService: APIService?
    private var task: Task<(), Never>?;
    
    
    open override func didReceive(_ request: UNNotificationRequest, withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void) {
        self.contentHandler = contentHandler
        bestAttemptContent = (request.content.mutableCopy() as? UNMutableNotificationContent)

        guard
            let organizationUnid = AppGroupStorage.shared.organizationUnid,
            let environment = AppGroupStorage.shared.environment,
            let apiKey = AppGroupStorage.shared.apiKey else {
            resultDescription = "No: organizationUnid=\(AppGroupStorage.shared.organizationUnid ?? "(nil)") |  organizationUnid=\(AppGroupStorage.shared.environment ?? "(nil)") |  apiKey=\(AppGroupStorage.shared.apiKey ?? "(nil)")"
            return completeNotificationService()
        }
        
        let pushExtractor = PushExtractor(notification: request.content)
        
        Configuration.selectEnvironment(by: environment)
        apiService = APIService(configuration: Configuration.Env)
        apiService?.defaultHeaders = ["x-api-key": apiKey]
        
        resultDescription = """
        PAYLOAD: \((try? JSONSerialization.data(withJSONObject: pushExtractor.payload)).flatMap({ String(data: $0, encoding: .utf8) }) ?? "(not-decoded)"))
        TIME: \(Date())
        """
        
        task = Task {
            do {
                try await trackPushDelivered(organizationUnid: organizationUnid, pushExtractor: pushExtractor)
                resultDescription = "DONE: TrackPushDelivered!\n" + resultDescription
                try Task.checkCancellation()
                
                await MainActor.run{
                    completeNotificationService()
                }
            }catch let error where error is CancellationError {
            }catch let error {
                resultDescription = "FAILED: \(error.localizedDescription)\n" + resultDescription
                //TODO: craslytics??
                await MainActor.run{
                    completeNotificationService()
                }
            }
        }
    }
    
    open override func serviceExtensionTimeWillExpire() {
        task?.cancel()
        //TODO: store for later tracking
        
        resultDescription = "FAILED: serviceExtensionTimeWillExpire getting called\n" + resultDescription
        
        completeNotificationService()
    }
    
    private func completeNotificationService() {
        AppGroupStorage.shared.lastNotificationServiceResult = resultDescription
        AppGroupStorage.shared.save()
        
        if let contentHandler = contentHandler, let bestAttemptContent = bestAttemptContent {
            if Configuration.Env.isDevelopment {
                bestAttemptContent.body += " #\(resultDescription)"
            }
            contentHandler(bestAttemptContent)
        }
    }
    
    private func trackPushDelivered(organizationUnid: String, pushExtractor: PushExtractor) async throws {
        guard let apiService = apiService else{
            throw Errors.with(message: "No APIService.")
        }
        
        guard let pushUnid = pushExtractor.pushUnid else{
            throw Errors.with(message: "No APIService.")
        }
        
        let pushEvent = PushEventModel(
            organizationUnid: organizationUnid,
            pushUnid: pushUnid,
            action: .delivered
        )
        try await apiService.trackPushEvent({ pushEvent })
    }

    
}
