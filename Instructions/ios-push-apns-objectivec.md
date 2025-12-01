**Add Push Notifications Capability**

1. In Xcode, open target settings. In **Signing & Capabilities** tab, click **+ Capability**.
2. Add **Push Notifications** capability.

In **AppDelegate.m**:

```objc
@import PolarGX;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // ... your existing code ...
    
    // Enable notification for your app, then register for remote notifications
    UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
    [center requestAuthorizationWithOptions:(UNAuthorizationOptionAlert | UNAuthorizationOptionBadge | UNAuthorizationOptionSound)
                          completionHandler:^(BOOL granted, NSError * _Nullable error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [[UIApplication sharedApplication] registerForRemoteNotifications];
        });
    }];

    // For quick integration, you can use our default implementation for Push Notification
    // If you want to use your own UNUserNotificationCenterDelegate implementation, please follow implementation in PolarQuickIntegration.swift
    [UNUserNotificationCenter currentNotificationCenter].delegate = [PolarQuickIntegration userNotificationCenterDelegateImpl];
    
    return YES;
}

// Handle device token registration
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    // Register APNS token with PolarGX SDK
    [[PolarApp shared] setAPNSWithDeviceToken:deviceToken];
}

// Handle registration failure (optional)
- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    NSLog(@"Failed to register for remote notifications: %@", error);
}
```
