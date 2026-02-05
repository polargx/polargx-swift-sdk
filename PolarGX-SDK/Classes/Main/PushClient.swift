import Foundation
import UserNotifications

public class PushClient: NSObject {
    let apiService: APIService
    let organizationUnid: String
    
    init(apiService: APIService, organizationUnid: String) {
        self.apiService = apiService
        self.organizationUnid = organizationUnid
    }
    
    @objc
    public func didReceive(response: UNNotificationResponse) {
        let push = PushExtractor(notification: response.notification.request.content)
        guard push.isPolarPush else { return }
        
        if let pushUnid = push.pushUnid {
            Task {
                do {
                    let pushEvent = PushEventModel(
                        organizationUnid: organizationUnid,
                        pushUnid: pushUnid,
                        action: .opened
                    )
                    try await apiService.trackPushEvent({ pushEvent })
                }catch let error {
                    Logger.elog("failed: \(error)")
                }
            }
        }
    }
}
