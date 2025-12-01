**Add Push Notifications Capability**

1. In Xcode, open target settings. In **Signing & Capabilities** tab, click **+ Capability**.
2. Add **Push Notifications** capability.

In **AppDelegate.swift:**

```swift
import UIKit
import FirebaseCore
import FirebaseMessaging
import PolarGX

@main
class AppDelegate: UIResponder, UIApplicationDelegate, MessagingDelegate {
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Initialize Firebase
        FirebaseApp.configure()
        
        // Set Firebase Messaging delegate
        Messaging.messaging().delegate = self
        
        // Enable notification for your app, then register for remote notifications
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { _, _ in
            DispatchQueue.main.async{
                UIApplication.shared.registerForRemoteNotifications()
            }
        }
        
        // For quick integration, you can use our default implementation for Push Notification
        // If you want to use your own UNUserNotificationCenterDelegate implementation, please follow implementation in PolarQuickItegration.swift
        UNUserNotificationCenter.current().delegate = PolarQuickIntegration.userNotificationCenterDelegateImpl;
        
        // ... your existing PolarGX initialization code ...
        
        return true
    }
    
    // ... rest of your code ...
}
```

**Register FCM Token with PolarGX SDK**

After receiving the FCM token from Firebase:

```swift
// Implement MessagingDelegate method
func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
    print("Firebase registration token: \(String(describing: fcmToken))")
    
    if let fcmToken = fcmToken {
        // Register FCM token with PolarGX SDK
        PolarApp.shared.setGCM(fcmToken: fcmToken)
    }
    
    // You can also send the token to your server if needed
    let dataDict: [String: String] = ["token": fcmToken ?? ""]
    NotificationCenter.default.post(
        name: Notification.Name("FCMToken"),
        object: nil,
        userInfo: dataDict
    )
}
```
