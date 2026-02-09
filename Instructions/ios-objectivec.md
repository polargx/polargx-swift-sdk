#### Using the SDK in Objective-C

The PolarGX SDK is written in Swift, but it works fully in Objective‑C projects.
Because PolarGX is written in Swift, you must enable Swift compatibility in your Objective-C project.

**Step 1 — Ensure `Use Swift` is enabled**

Xcode will automatically ask to create a **Bridging Header** when you add Swift code. If it does not, create one manually:

1. Go to **File > New > File > Header File** → name it: `YourApp-Bridging-Header.h`.
2. In **Build Settings** of your target, search for: **Objective-C Bridging Header** → set path:

```objc
YourApp/YourApp-Bridging-Header.h
```

**Step 2 — Import PolarGX into Objective-C**

Inside the bridging header:

```objc
// Import Swift support
@import PolarGX;
```

**Step 3 — Initialize PolarGX in Objective-C**

In **AppDelegate.m**:

```objc
@import PolarGX;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Configure app group (required for push notifications)
    PolarSettings.appGroupIdentifier = @"group.{your-bundle-id}";

    // Initialize PolarGX
    [PolarGX initializeWithOrganizationUnid:@"your-org-unid"
                                     apiKey:@"your-api-key"
                                environment:EnvironmentProduction];

    return YES;
}
```

**Step 4 — Handle Universal Links**

```objc
- (BOOL)application:(UIApplication *)application continueUserActivity:(NSUserActivity *)userActivity restorationHandler:(void (^)(NSArray * _Nullable))restorationHandler {
    return [[PolarApp shared] continueUserActivity:userActivity];
}
```

**Step 5 — Handle URL Scheme**

```objc
- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<UIApplicationOpenURLOptionsKey,id> *)options {
    return [[PolarApp shared] openUrl:url];
}
```

**Step 6 — For projects using SceneDelegate (iOS 13+)**

In **SceneDelegate.m**:

```objc
@import PolarGX;

- (void)scene:(UIScene *)scene willConnectToSession:(UISceneSession *)session options:(UISceneConnectionOptions *)connectionOptions {
    NSUserActivity *activity = connectionOptions.userActivities.allObjects.firstObject;
    if (activity) {
        [[PolarApp shared] continueUserActivity:activity];
    }

    NSURL *url = connectionOptions.URLContexts.allObjects.firstObject.URL;
    if (url) {
        [[PolarApp shared] openUrl:url];
    }
}

- (void)scene:(UIScene *)scene continueUserActivity:(NSUserActivity *)userActivity {
    [[PolarApp shared] continueUserActivity:userActivity];
}

- (void)scene:(UIScene *)scene openURLContexts:(NSSet<UIOpenURLContext *> *)URLContexts {
    NSURL *url = URLContexts.allObjects.firstObject.URL;
    if (url) {
        [[PolarApp shared] openUrl:url];
    }
}
```
