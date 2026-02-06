import Foundation
import UserNotifications

public class PushClient: NSObject {
    @objc
    public func didReceive(response: UNNotificationResponse) {}
}

class InternalPushClient: PushClient {
    let apiService: APIService
    let organizationUnid: String
    
    init(apiService: APIService, organizationUnid: String) {
        self.apiService = apiService
        self.organizationUnid = organizationUnid
    }
    
    public override func didReceive(response: UNNotificationResponse) {
        let push = PushExtractor(notification: response.notification.request.content)
        guard push.isPolarPush else { return }
        
        Logger.log("PushClient didReceive: \((try? JSONSerialization.data(withJSONObject: push.payload)).flatMap({ String(data: $0, encoding: .utf8) }) ?? "(not-decoded)")")
        
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
