
import Foundation
import UserNotifications

#if canImport(PolarGXCore)
@_exported import PolarGXCore
#endif

/// following types will be used for quick integration, you can use them or create custom types your own

//MARK: UNUserNotificationCenterDelegate implementation
public class PolarQuickIntegration: NSObject {
    public static let userNotificationCenterDelegateImpl = UserNotificationCenterDelegateQuickImpl()
    
    public final class UserNotificationCenterDelegateQuickImpl: NSObject, UNUserNotificationCenterDelegate {
        public func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
            completionHandler([.badge, .sound, .banner, .list])
        }
        
        public func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
            PolarApp.shared.pushClient.didReceive(response: response)
            completionHandler()
        }
    }
    
}
