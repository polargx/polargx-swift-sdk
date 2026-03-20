import Foundation
import UserNotifications

@objc
public protocol PolarAppDelegate: AnyObject {
    func polarApp(_ app: PolarApp, didClickLink link: URL, data: [AnyHashable: Any]?, error: Error?)
    func polarApp(_ app: PolarApp, didReceiveNotification notication: UNNotificationResponse, data: [AnyHashable: Any])
}
