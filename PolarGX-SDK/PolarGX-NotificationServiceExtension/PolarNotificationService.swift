import Foundation
import UserNotifications

/// PolarGX NotificationServiceExtension SDK
/// Tracks push notification delivery and enables rich media attachments
@objc
open class PolarNotificationService: UNNotificationServiceExtension {
    open var appGroupIdentifier: String? { nil }
    
    var contentHandler: ((UNNotificationContent) -> Void)?
    var bestAttemptContent: UNMutableNotificationContent?
    var resultDescription: String = ""
    
    private var apiService: APIService?
    private var task: Task<(), Never>?;
    
    open override func didReceive(_ request: UNNotificationRequest, withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void) {
        guard
            let organizationUnid = AppGroupStorage.shared.organizationUnid,
            let environment = AppGroupStorage.shared.environment,
            let apiKey = AppGroupStorage.shared.apiKey else {
            return contentHandler(request.content)
        }
        
        self.contentHandler = contentHandler
        bestAttemptContent = (request.content.mutableCopy() as? UNMutableNotificationContent)
        let pushExtractor = PushExtractor(notification: request.content)
        
        Configuration.selectEnvironment(by: environment)
        apiService = APIService(configuration: Configuration.Env)
        apiService?.defaultHeaders = ["x-api-key": apiKey]
        
        resultDescription = """
        TIME: \(Date())
        PAYLOAD: \(pushExtractor.payload.description)
        """
        
        task = Task {
            do {
                try await trackPushDelivered(organizationUnid: organizationUnid, pushExtractor: pushExtractor)
                resultDescription += "\nDONE: TrackPushDelivered!"
                try Task.checkCancellation()
                
                await MainActor.run{
                    completeNotificationService()
                }
            }catch let error where error is CancellationError {
            }catch let error {
                resultDescription += "\nFAILED: \(error.localizedDescription)"
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
        
        resultDescription += "\nFAILED: serviceExtensionTimeWillExpire getting called"
        
        completeNotificationService()
    }
    
    private func completeNotificationService() {
        AppGroupStorage.shared.lastNotificationServiceResult = resultDescription
        AppGroupStorage.shared.save()
        
        if let contentHandler = contentHandler, let bestAttemptContent = bestAttemptContent {
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
