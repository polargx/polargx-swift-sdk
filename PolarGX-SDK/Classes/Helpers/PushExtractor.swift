import Foundation
import UserNotifications

struct PushExtractor {
    let notification: UNNotification
    
    init(notification: UNNotification) {
        self.notification = notification
    }
    
    var payload: [AnyHashable: Any] {
        return notification.request.content.userInfo
    }
    
    var isPolarPush: Bool {
        return payload["$polar"] as? Bool ?? false
    }
    
    var campaignId: String? {
        return payload["$pl_cpid"] as? String
    }
    
    func getTrackingAttributes() -> [String: Any] {
        return ([
            "$pl_cpid": campaignId
        ] as [String: Any?]).compactMapValues({ $0 })
    }
}
