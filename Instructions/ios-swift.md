#### Using the SDK in Swift

* Get *App Id* and *API Key* from [https://app.polargx.com](https://app.polargx.com)

#### In `AppDelegate.swift`

```swift
// Add: Import PolarGX
import PolarGX

func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    // Your existing code

    // Add: Configure app group (required for push notifications)
    PolarSettings.appGroupIdentifier = "group.{your-bundle-id}"

    // Add: Initialize Polar app
    PolarGX.initialize(
        organizationUnid: "your-org-unid",
        apiKey: "your-api-key",
        environment: .production
    )

    return true
}

func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
    // Add: Polar app handles the user activity
    return PolarApp.shared.continueUserActivity(userActivity)
}

func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
    // Add: Polar app handles the opening url
    return PolarApp.shared.openUrl(url)
}
```

#### In `SceneDelegate.swift`

```swift
// Add: Import PolarGX
import PolarGX

func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
    // Your existing code

    // Add: Polar app handles the user activity
    if let userActivity = connectionOptions.userActivities.first {
        _ = PolarApp.shared.continueUserActivity(userActivity)
    }

    // Add: Polar app handles the opening url
    if let url = connectionOptions.urlContexts.first?.url {
        _ = PolarApp.shared.openUrl(url)
    }
}

func scene(_ scene: UIScene, continue userActivity: NSUserActivity) {
    // Add: Polar app handles the user activity
    _ = PolarApp.shared.continueUserActivity(userActivity)
}

func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
    // Add: Polar app handles the opening url
    if let url = URLContexts.first?.url {
        _ = PolarApp.shared.openUrl(url)
    }
}
```
