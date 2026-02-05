import Foundation
import UserNotifications

struct PushExtractor {
    let notificationContent: UNNotificationContent
    
    init(notification: UNNotificationContent) {
        self.notificationContent = notification
    }
    
    var payload: [AnyHashable: Any] {
        return notificationContent.userInfo
    }
    
    var pushData: [String: Any]? {
        return payload["push_data"] as? [String: Any]
    }
    
    var pushUnid: String? {
        return pushData?["push_unid"] as? String
    }
    
    var isPolarPush: Bool {
        return pushUnid != nil
    }
}
