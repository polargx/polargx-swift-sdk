**Add Push Notifications Capability**

1. In Xcode, open target settings. In **Signing & Capabilities** tab, click **+ Capability**.
2. Add **Push Notifications** capability.

In **AppDelegate.m:**

```objc
@import FirebaseCore;
@import FirebaseMessaging;
@import PolarGX;

@interface AppDelegate () <FIRMessagingDelegate>
@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Initialize Firebase
    [FIRApp configure];
    
    // Set Firebase Messaging delegate
    [FIRMessaging messaging].delegate = self;
    
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
    
    // ... your existing PolarGX initialization code ...
    
    return YES;
}

// ... rest of your code ...
@end
```

**Register FCM Token with PolarGX SDK**

After receiving the FCM token from Firebase:

```objc
// Implement FIRMessagingDelegate method
- (void)messaging:(FIRMessaging *)messaging didReceiveRegistrationToken:(NSString *)fcmToken {
    NSLog(@"Firebase registration token: %@", fcmToken);
    
    if (fcmToken) {
        // Register FCM token with PolarGX SDK
        [[PolarApp shared] setGCMWithFcmToken:fcmToken];
    }
    
    // You can also send the token to your server if needed
    NSDictionary *dataDict = [NSDictionary dictionaryWithObject:fcmToken forKey:@"token"];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"FCMToken" object:nil userInfo:dataDict];
}
```
