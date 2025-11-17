# PolarGX iOS SDK Installation Guide

A complete guide for integrating **PolarGX SDK** into your **Swift** or **Objective‑C** iOS app.

---

## 📘 Table of Contents

1. [Create and Setup Polar App](#1-create-and-setup-polar-app)
2. [Installing PolarGX SDK](#2-adding-polargx-sdk)
   * CocoaPods
   * Swift Package Manager (SPM)
3. [Configure Associated Domains](#3-configure-associated-domains)
4. [Configure URL Scheme](#3-configure-url-scheme)
5. [Using PolarGX SDK in Swift](#41-in-swift-project)
6. [Using PolarGX SDK in Objective‑C](#42-using-polargx-in-objective-c-project)

---

## 1. Create and setup Polar app:

### 1. Create and setup Polar app:

* Register PolarGX account at [https://app.polargx.com](https://app.polargx.com), after signup `unnamed` app has been created automatically.
* Setting your app in *App Settings > App Information*
* Create an API Key in *App Settings > API Keys* with *Mobile apps / frontend* purpose
* Configure your domain in *Link Attribution > Configuration > Link domain section* with:

  * Default link domain.
  * Alternate link domain.
* Configure your iOS Redirects in *Link Attribution > Configuration > Required Redirects section > iOS Redirects* with:

  * App Store Search / AppStore Id or Custom URL: Help your link redirects to AppStore or your custom url if your app hasn't been installed.
  * Universal Links: Help your link opens app immediately if your app was installed.

    * Open [https://developer.apple.com](https://developer.apple.com). Locate your app identifier in `Certificates, Identifiers & Profiles > Identifiers`
    * Use *App ID Prefix* for *Apple App Prefix*
    * Use *Bundle ID* for *Bundle Identifiers*
  * Scheme URL (deprecated way): Help your link opens app if your app was installed and can't be opened by *Universal Links*.
    Example: `yourapp_schemeurl://`

### 2. Installing PolarGX SDK

PolarGX can be integrated using **CocoaPods**, **Swift Package Manager**, or **manual integration**.

---

### 2.1. Install via CocoaPods

#### 2.1. Use CocoaPods

* Install CocoaPods: please follow this [Guide: getting started](https://guides.cocoapods.org/using/getting-started.html).
* Set up CocoaPods in your project: please follow this [Guide: using cocoapods](https://guides.cocoapods.org/using/using-cocoapods.html).
* To add PolarGX dependency, run:

  ```
  pod 'PolarGX'
  ```

### 2.2. Install via Swift Package Manager (SPM)

PolarGX Swift SDK is available via **Swift Package Manager (SPM)**.

##### Add via Xcode

1. Open your project in Xcode.
2. Go to **File > Add Packages…**
3. Enter the package URL:

   ```
   https://github.com/polargx/polargx-swift-sdk.git
   ```
4. Set **Dependency Rule** to **Up to Next Major Version** (Recommended).
5. Click **Add Package**.

##### Add in `Package.swift`

```swift
dependencies: [
    .package(url: "https://github.com/polargx/polargx-swift-sdk.git", from: "1.0.0")
]
```

Add to your target:

```swift
.target(
    name: "YourApp",
    dependencies: [
        .product(name: "PolarGX", package: "polargx-swift-sdk")
    ]
)
```

---

## 3. Configure Associated Domains:

* In Xcode, open target settings. In **Signing & Capabilities** tab, enable **Associated Domains** capability.
* In **Associated Domains**, add your app domains in **(1)** into Domains section with the following format:

  ```
  applinks:{subdomain}.app.link
  applinks:{subdomain}-alternate.app.link
  ```

### 3. Configure URL Scheme:

* In Xcode, open target settings. In **Info** tab, scroll to **URL Types** section.
* In **URL Types**, add a URL Type with **URL Schemes** set to the *Scheme URL* in **(1)**.
  Example: `yourapp_schemeurl`

---

# 4. Using PolarGX SDK

---

## 4.2. Using the SDK in Objective-C

The PolarGX SDK is written in Swift, but it works fully in Objective‑C projects.**
PolarGX Swift SDK can also be used in Objective-C projects.

### **Importing PolarGX into Objective-C**

Because PolarGX is written in Swift, you must enable Swift compatibility in your Objective-C project.

### **Step 1 — Ensure `Use Swift` is enabled**

Xcode will automatically ask to create a **Bridging Header** when you add Swift code. If it does not, create one manually:

1. Go to **File > New > File > Header File** → name it: `YourApp-Bridging-Header.h`.
2. In **Build Settings** of your target, search for:

   * **Objective-C Bridging Header** → set path:

     ```
     YourApp/YourApp-Bridging-Header.h
     ```

### **Step 2 — Import PolarGX into Objective-C**

Inside the bridging header:

```objc
// Import Swift support
@import PolarGX;
```

### **Step 3 — Initialize PolarGX in Objective-C**

In **AppDelegate.m**:

```objc
@import PolarGX;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [PolarApp initializeWithAppId:@"YOUR_APP_ID"
                           apiKey:@"YOUR_API_KEY"
                         callback:^(NSString * _Nullable link, NSDictionary * _Nullable data, NSError * _Nullable error) {
        NSLog(@"[POLAR] link=%@ data=%@ error=%@", link, data, error);
    }];

    return YES;
}
```

### **Step 4 — Handle Universal Links**

```objc
- (BOOL)application:(UIApplication *)application continueUserActivity:(NSUserActivity *)userActivity restorationHandler:(void (^)(NSArray * _Nullable))restorationHandler {
    return [[PolarApp shared] continueUserActivity:userActivity];
}
```

### **Step 5 — Handle URL Scheme**

```objc
- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<UIApplicationOpenURLOptionsKey,id> *)options {
    return [[PolarApp shared] openUrl:url];
}
```

### **Step 6 — For projects using SceneDelegate (iOS 13+)**

In **SceneDelegate.m**:

```objc
@import PolarGX;

- (void)scene:(UIScene *)scene willConnectToSession:(UISceneSession *)session options:(UISceneConnectionOptions *)connectionOptions {
    NSUserActivity *activity = connectionOptions.userActivities.anyObject;
    if (activity) {
        [[PolarApp shared] continueUserActivity:activity];
    }

    NSURL *url = connectionOptions.URLContexts.anyObject.URL;
    if (url) {
        [[PolarApp shared] openUrl:url];
    }
}

- (void)scene:(UIScene *)scene continueUserActivity:(NSUserActivity *)userActivity {
    [[PolarApp shared] continueUserActivity:userActivity];
}

- (void)scene:(UIScene *)scene openURLContexts:(NSSet<UIOpenURLContext *> *)URLContexts {
    NSURL *url = URLContexts.anyObject.URL;
    if (url) {
        [[PolarApp shared] openUrl:url];
    }
}
```

## 4.1. Using the SDK in Swift

* Get *App Id* and *API Key* from [https://app.polargx.com](https://app.polargx.com)

#### In `AppDelegate.swift`

```
// Add: Import PolarGX
import PolarGX

func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    // Your existing code

    // Add: Initialize Polar app
    PolarApp.initialize(appId: YOUR_APP_ID, apiKey: YOUR_API_KEY) { link, data, error in
        print("\n[POLAR] detect link clicked: \(link), data: \(data), error: \(error)\n")
        // Handle link clicked. This callback will be called in the main queue.
    }

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

```
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
