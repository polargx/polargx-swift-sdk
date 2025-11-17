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
5. [Push Notifications](#41-push-notifications)
6. [Using PolarGX SDK in Swift](#43-using-the-sdk-in-swift)
7. [Using PolarGX SDK in Objective‑C](#42-using-the-sdk-in-objective-c)

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

## 4.1. Push Notifications

PolarGX SDK supports push notifications via **APNS** (Apple Push Notification Service) and **GCM/FCM** (Google Cloud Messaging / Firebase Cloud Messaging). The SDK automatically registers and manages push tokens for your users.

### **4.1.1. Setup Push Notifications on app.polargx.com**

1. Log in to [https://app.polargx.com](https://app.polargx.com)
2. Navigate to **CONFIGURATIONS > Push Services** in the left sidebar
3. Click **+ New Push Service** button to create a new push notification service
4. Select your push notification platform:
   * **Google Cloud Messaging (GCM)**: For push notifications using Firebase/Google Cloud Messaging for iOS devices
   * **Apple Push Notification Service (APNS)**: For push notifications for Apple platforms only

#### **For GCM (Google Cloud Messaging):**

1. Select **Google Cloud Messaging (GCM)** card
2. Fill in the **Platform Configuration**:
   * **Service Name**: Enter a descriptive name (e.g., "Production Push Service", "Development iOS Push")
   * **Bundle ID - iOS**: Enter your iOS app's unique bundle identifier, e.g., `com.yourcompany.yourapp`
   * **Upload your GCM service account file**: Upload your GCM service account JSON file (downloaded from Firebase Console)
3. Click **Create** or **Save** to complete the setup

#### **For APNS (Apple Push Notification Service):**

1. Select **Apple Push Notification Service (APNS)** card
2. Fill in the **Platform Configuration**:
   * **Service Name**: Enter a descriptive name (e.g., "Production Push Service", "Development iOS Push")
   * **Bundle ID**: Enter your iOS app's unique bundle identifier (e.g., `com.yourcompany.yourapp`)
   * **Team ID**: Enter your iOS app's unique team identifier (found in Apple Developer Portal)
   * **Key ID**: Enter your APNS authentication key ID (created in Apple Developer Portal)
   * **Upload your APNS authentication key file**: Upload your APNS authentication key file (`.p8` file downloaded from Apple Developer Portal)
3. Click **Create** or **Save** to complete the setup

**Note**: You can create multiple push services for different environments (e.g., one for Production and one for Development). Each service should have a unique Service Name and appropriate configuration.

### **4.1.2. Setup APNS on developer.apple.com**

Follow these detailed steps to obtain the required information from Apple Developer Portal. You'll need an active **Apple Developer Program membership**.

#### **Step 1: Access Apple Developer Portal**

1. Visit [https://developer.apple.com/account](https://developer.apple.com/account) and sign in with your Apple Developer credentials
2. Make sure you have **admin** or **account holder** access to create authentication keys

#### **Step 2: Navigate to Keys Section**

1. From the left sidebar, select **Certificates, Identifiers & Profiles**
2. Click on **Keys** - this is where you'll manage your APNs authentication keys

#### **Step 3: Create New APNs Key**

1. Click the **+** button to create a new key
2. Enter a descriptive name (e.g., "Production Push Notifications")
3. Check the **Apple Push Notifications service (APNs)** checkbox
4. Click **Continue** and then **Register** to complete the creation

#### **Step 4: Download Authentication Key**

1. Click **Download** to save the `.p8` file to your computer
2. **⚠️ Important**: This file can only be downloaded once. If you lose it, you'll need to create a new key
3. Keep this file secure as it provides access to your APNs service

#### **Step 5: Record Key ID and Team ID**

1. After creating the key, you'll see a **Key ID** (a 10-character string like `ABC123DEFG`) - copy this value
2. For your **Team ID**, go to the **Membership** section in your account settings - it's displayed at the top right (also a 10-character string)

#### **Step 6: Get Your App Bundle ID**

1. Navigate to **Identifiers** and select your app
2. The **Bundle ID** is shown in the format `com.yourcompany.yourapp`
3. This identifier must match exactly what's configured in your iOS app's Xcode project

**💡 Pro Tip**: You can use the same `.p8` authentication key for multiple apps within your team. However, each app must have its own unique Bundle ID.

#### **Step 7: Upload APNS Credentials to app.polargx.com**

1. Go to [https://app.polargx.com](https://app.polargx.com)
2. Navigate to **CONFIGURATIONS > Push Services**
3. Click **+ New Push Service** and select **Apple Push Notification Service (APNS)**
4. Fill in the required information:
   * **Service Name**: Enter a descriptive name
   * **Bundle ID**: Enter your iOS app's Bundle ID (from Step 6)
   * **Team ID**: Enter your Team ID (from Step 5)
   * **Key ID**: Enter the Key ID of your APNS authentication key (from Step 5)
   * **Upload your APNS authentication key file**: Upload the `.p8` file you downloaded (from Step 4)
5. Click **Create** or **Save** to complete the setup

### **4.1.3. Setup GCM/FCM on Firebase/Google Cloud**

Follow these detailed steps to obtain your Service Account JSON credentials. The token must be string encoded (JSON stringified) before passing to the API.

#### **Step 1: Enable Firebase Cloud Messaging API**

1. Go to [Firebase Console](https://console.firebase.google.com) and select your project
2. Ensure **Firebase Cloud Messaging API (V1)** is enabled
3. You can check the status on the **Status Dashboard** link shown in your project settings

#### **Step 2: Access Project Settings**

1. Click the **⚙️ gear icon** next to "Project Overview" and select **Project settings**
2. You'll see your **Sender ID** displayed - note this for reference

#### **Step 3: Navigate to Service Accounts**

1. In **Project settings**, go to the **Service accounts** tab
2. Here you'll see your service account email and options to manage it
3. Click on **Manage Service Accounts** link to open Google Cloud Console

#### **Step 4: Access Service Account Keys**

1. In the **Google Cloud Console**, find your Firebase Admin SDK service account (format: `firebase-adminsdk-xxxxx@your-project.iam.gserviceaccount.com`)
2. Click on it to view details, then go to the **Keys** tab at the top

#### **Step 5: Create and Download JSON Key**

1. Click **Add key → Create new key**
2. Select **JSON** as the key type (recommended) and click **Create**
3. A JSON file containing your private key will be automatically downloaded
4. **⚠️ Store this file securely** - it can't be recovered if lost!

#### **Step 6: Get Bundle ID**

1. Go to **Project settings → General tab → Your apps** section
2. Find your iOS app's identifier (e.g., `com.yourcompany.yourapp`)
3. This is your **Bundle ID** for iOS

**💡 Pro Tip**: You can register multiple iOS apps under the same Firebase project and reuse the same service account credentials.

**⚠️ Security Warning**: Service account keys grant full access to your Firebase project. Never commit them to version control, share them publicly, or embed them in client-side code. Use the Workload Identity Google Cloud feature or rotate keys regularly for production environments.

#### **Step 7: Upload JSON File to app.polargx.com**

1. Go to [https://app.polargx.com](https://app.polargx.com)
2. Navigate to **CONFIGURATIONS > Push Services**
3. Click **+ New Push Service** and select **Google Cloud Messaging (GCM)**
4. Fill in the required information:
   * **Service Name**: Enter a descriptive name
   * **Bundle ID - iOS**: Enter your iOS app's Bundle ID (from Step 6)
   * **Upload your GCM service account file**: Upload the JSON file you downloaded (from Step 5)
5. The system will automatically string encode it for you
6. Click **Create** or **Save** to complete the setup

#### **Step 8: Add iOS App to Firebase (Required for FCM token in app)**

To use FCM tokens in your iOS app, you need to:

1. In your Firebase project, click **Add app** and select **iOS**
2. Enter your iOS app's **Bundle ID** (must match your Xcode project's Bundle Identifier)
3. Download the `GoogleService-Info.plist` file
4. Add the `GoogleService-Info.plist` file to your Xcode project
5. Install Firebase SDK (see implementation section below)

### **4.1.4. APNS Implementation in Your App**

#### **Configure Push Notifications Capability**

1. In Xcode, open target settings. In **Signing & Capabilities** tab, click **+ Capability**.
2. Add **Push Notifications** capability.

#### **In Swift**

In **AppDelegate.swift**:

```swift
import PolarGX

func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    // ... your existing code ...
    
    // Register for remote notifications
    UIApplication.shared.registerForRemoteNotifications()
    
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

#### **In Objective-C**

In **AppDelegate.m**:

```objc
@import PolarGX;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // ... your existing code ...
    
    // Register for remote notifications
    [[UIApplication sharedApplication] registerForRemoteNotifications];
    
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

### **4.1.5. GCM/FCM Implementation in Your App**

If you're using Firebase Cloud Messaging, you can register the FCM token with PolarGX SDK.

#### **Initialize Firebase in Your App**

**In Swift - AppDelegate.swift:**

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
        
        // ... your existing PolarGX initialization code ...
        
        return true
    }
    
    // ... rest of your code ...
}
```

**In Objective-C - AppDelegate.m:**

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
    
    // ... your existing PolarGX initialization code ...
    
    return YES;
}

// ... rest of your code ...
@end
```

#### **Register FCM Token with PolarGX SDK**

**In Swift:**

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

**In Objective-C:**

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

### **4.1.6. How Push Tokens Work**

* The SDK automatically registers push tokens with the PolarGX backend when:
  * A user is set via `updateUser(userID:attributes:)`
  * A push token is registered via `setAPNS(deviceToken:)` or `setGCM(fcmToken:)`
* The SDK automatically deregisters push tokens when:
  * A user logs out (when `updateUser(userID: nil, attributes: nil)` is called)
  * A different user is set
* Push tokens are stored and retried automatically if registration fails

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
                onLinkClickHandler:^(NSURL * _Nonnull url, NSDictionary<NSString *,id> * _Nullable attributes, NSError * _Nullable error) {
        NSLog(@"[POLAR] link=%@ data=%@ error=%@", url, attributes, error);
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

### **Step 7 — Setup Push Notifications**

For push notification setup in Objective-C, see [Push Notifications](#41-push-notifications) section above.

## 4.3. Using the SDK in Swift

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
