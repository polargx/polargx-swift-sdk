**Add Push Notifications Capability**

1. In Xcode, open target settings. In **Signing & Capabilities** tab, click **+ Capability**.
2. Add **Push Notifications** capability.

In **AppDelegate.swift**:

```swift
import PolarGX

func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    // ... your existing code ...
    
    // Enable notification for your app, then register for remote notifications
    UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { _, _ in
        DispatchQueue.main.async{
            UIApplication.shared.registerForRemoteNotifications()
        }
    }
    
    // For quick integration, you can use our default implementation for Push Notification
    // If you want to use your own UNUserNotificationCenterDelegate implementation, please follow implementation in PolarQuickItegration.swift
    UNUserNotificationCenter.current().delegate = PolarQuickIntegration.userNotificationCenterDelegateImpl;
    
    return true
}

// Handle device token registration
func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
    // Register APNS token with PolarGX SDK
    PolarApp.shared.setAPNS(deviceToken: deviceToken)
}

// Handle registration failure (optional)
func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
    print("Failed to register for remote notifications: \(error)")
}
```
