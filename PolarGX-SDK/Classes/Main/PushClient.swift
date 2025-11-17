import Foundation
import UserNotifications

public class PushClient: NSObject {
    weak var app: PolarApp?
    
    init(app: PolarApp?) {
        self.app = app
    }
    
    @objc
    public func didReceive(response: UNNotificationResponse) {
        let push = PushExtractor(notification: response.notification)
        guard push.isPolarPush else { return }
        
        app?.trackEvent(
            name: InternalEvent.pushOpen.rawValue,
            attributes: push.getTrackingAttributes()
        )
    }
}
