# PolarGX NotificationServiceExtension Setup Guide

This guide walks you through setting up the PolarGX NotificationServiceExtension to track push notification delivery events.

## Overview

The PolarGX NotificationServiceExtension allows you to:
- ✅ Track when push notifications are **delivered** to the device (not just opened)
- ✅ Share user context between your app and the extension via App Groups
- ✅ Extract Polar-specific push data automatically
- 🔜 Download rich media attachments (coming soon)

## Architecture

```
┌─────────────────────────────────────────────────┐
│              Main App (PolarGX)                 │
│  - Initialize SDK with appId & apiKey           │
│  - Update user (userID, attributes)             │
│  - Track push_open when user taps notification │
│  - Save config to App Groups ───────┐          │
└─────────────────────────────────────│───────────┘
                                      │
                              ┌───────▼──────┐
                              │  App Groups  │
                              │  (Shared)    │
                              └───────┬──────┘
                                      │
┌─────────────────────────────────────│───────────┐
│    NotificationServiceExtension     │           │
│  - Read config from App Groups ◄────┘           │
│  - Track push_delivered automatically           │
│  - Extract campaign data ($pl_cpid)             │
└─────────────────────────────────────────────────┘
```

## Prerequisites

- iOS 15.0+
- Xcode 13+
- PolarGX SDK 3.2.0+
- App Groups capability enabled in Apple Developer Portal

## Step-by-Step Setup

### 1. Add NotificationServiceExtension Target (if you don't have one)

1. In Xcode, select **File → New → Target**
2. Choose **Notification Service Extension**
3. Name it (e.g., `NotificationServiceExtension`)
4. Click **Finish**

### 2. Enable App Groups

#### In Apple Developer Portal

1. Go to [developer.apple.com](https://developer.apple.com)
2. Navigate to **Certificates, Identifiers & Profiles**
3. Select your **App ID**
4. Enable **App Groups** capability
5. Create a new App Group: `group.com.yourcompany.polargx` (use your bundle ID)
6. **Repeat for your NotificationServiceExtension App ID**

#### In Xcode

**For Main App Target:**
1. Select your project in Xcode
2. Select your **main app target**
3. Go to **Signing & Capabilities** tab
4. Click **+ Capability**
5. Add **App Groups**
6. Check the App Group you created: `group.com.yourcompany.polargx`

**For NotificationServiceExtension Target:**
1. Select your **NotificationServiceExtension target**
2. Go to **Signing & Capabilities** tab
3. Click **+ Capability**
4. Add **App Groups**
5. Check **the same App Group**: `group.com.yourcompany.polargx`

⚠️ **IMPORTANT:** Both targets must use the **exact same** App Group identifier!

### 3. Install PolarGX NotificationServiceExtension Library

#### Swift Package Manager

1. In Xcode, go to **File → Add Packages**
2. Enter: `https://github.com/polargx/polargx-swift-sdk.git`
3. Version: `3.2.0` or later
4. **For Main App Target:** Add `PolarGX` library
5. **For NotificationServiceExtension Target:** Add `PolarGXNotificationService` library

#### CocoaPods

```ruby
# Podfile

target 'YourApp' do
  use_frameworks!
  pod 'PolarGX', '~> 3.2.0'
end

target 'NotificationServiceExtension' do
  use_frameworks!
  pod 'PolarGX/NotificationServiceExtension', '~> 3.2.0'
end
```

Then run:
```bash
pod install
```

### 4. Update Main App Code

In your `AppDelegate.swift`:

```swift
import UIKit
import PolarGX

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication,
                    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        // ⚠️ IMPORTANT: Set App Group BEFORE initializing PolarApp
        AppGroupStorage.appGroupIdentifier = "group.com.yourcompany.polargx"

        // Initialize PolarApp as usual
        PolarApp.isLoggingEnabled = true
        PolarApp.initialize(appId: "your-app-id", apiKey: "your-api-key") { link, data, error in
            print("Deep link opened: \(link)")
        }

        // Update user (this will be saved to App Groups automatically)
        PolarApp.shared.updateUser(userID: "user-123", attributes: [
            PolarEventKey.Email: "user@example.com",
            PolarEventKey.Name: "John Doe"
        ])

        // Request notification permissions
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            if granted {
                DispatchQueue.main.async {
                    UIApplication.shared.registerForRemoteNotifications()
                }
            }
        }

        return true
    }

    // Register device token
    func application(_ application: UIApplication,
                    didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        PolarApp.shared.setAPNS(deviceToken: deviceToken)
    }
}

// Handle notification taps
extension AppDelegate: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                               didReceive response: UNNotificationResponse) async {
        PolarApp.shared.pushClient.didReceive(response: response)
    }
}
```

### 5. Update NotificationService.swift

In your NotificationServiceExtension's `NotificationService.swift`:

```swift
import UserNotifications
import PolarGXNotificationService

class NotificationService: UNNotificationServiceExtension {

    var contentHandler: ((UNNotificationContent) -> Void)?
    var bestAttemptContent: UNMutableNotificationContent?

    override func didReceive(_ request: UNNotificationRequest,
                            withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void) {
        self.contentHandler = contentHandler
        bestAttemptContent = (request.content.mutableCopy() as? UNMutableNotificationContent)

        // ⚠️ IMPORTANT: Must match main app's App Group identifier
        PolarNotificationService.appGroupIdentifier = "group.com.yourcompany.polargx"

        // Optional: Enable logging for debugging
        #if DEBUG
        PolarNotificationService.isLoggingEnabled = true
        #endif

        if let bestAttemptContent = bestAttemptContent {
            PolarNotificationService.handleNotification(
                request: request,
                bestAttemptContent: bestAttemptContent
            ) { modifiedContent in
                contentHandler(modifiedContent)
            }
        } else {
            contentHandler(request.content)
        }
    }

    override func serviceExtensionTimeWillExpire() {
        if let contentHandler = contentHandler,
           let bestAttemptContent = bestAttemptContent {
            contentHandler(bestAttemptContent)
        }
    }
}
```

### 6. Update Push Notification Payload

Your push notifications **must** include `mutable-content: 1` to trigger the extension:

```json
{
  "aps": {
    "alert": {
      "title": "New Message",
      "body": "You have a new message!"
    },
    "mutable-content": 1,
    "badge": 1,
    "sound": "default"
  },
  "$polar": true,
  "$pl_cpid": "campaign-abc-123"
}
```

**Required fields:**
- `mutable-content: 1` - Triggers the NotificationServiceExtension
- `$polar: true` - Identifies this as a Polar push
- `$pl_cpid` - Campaign ID for tracking

## Testing

### 1. Build and Run

1. Build and run your **main app** on a physical device
2. Ensure `AppGroupStorage.appGroupIdentifier` is set
3. Log in a user via `updateUser()`
4. Register for push notifications

### 2. Send Test Push

Use your push notification provider (APNs, Firebase, etc.) or PolarGX dashboard to send:

```json
{
  "aps": {
    "alert": {
      "title": "Test",
      "body": "Testing delivery tracking"
    },
    "mutable-content": 1
  },
  "$polar": true,
  "$pl_cpid": "test-campaign"
}
```

### 3. Verify Logs

#### In Xcode Console:
```
[PolarNotificationService] Handling Polar push notification
[PolarNotificationService] Tracking delivery for user: user-123
[PolarNotificationService] Successfully tracked delivery event
```

#### In PolarGX Dashboard:
- Check your analytics for `push_delivered` events
- Verify campaign attribution

## Troubleshooting

### No delivery events tracked

**Possible causes:**

1. **App Group not configured properly**
   - Verify both targets have the **same** App Group identifier
   - Check App Groups are enabled in Apple Developer Portal
   - Ensure `AppGroupStorage.appGroupIdentifier` is set in **both** app and extension

2. **User not logged in**
   - Call `PolarApp.shared.updateUser(userID: "...")` before sending push
   - Check logs for "No userUnid in App Groups"

3. **Configuration not saved**
   - Ensure `AppGroupStorage.appGroupIdentifier` is set **before** `PolarApp.initialize()`
   - Verify `PolarApp.initialize()` was called

4. **Push notification format incorrect**
   - Must include `"mutable-content": 1` in `aps` object
   - Must include `"$polar": true`

### Extension not running

1. **Check push payload** includes `"mutable-content": 1`
2. **Test on physical device** (not simulator)
3. **Check extension target** has correct bundle ID and signing
4. **Verify** extension is included in build

### App Group data not accessible

1. **Clean build folder** (Cmd+Shift+K)
2. **Verify App Group identifier** in both targets
3. **Check provisioning profiles** include App Groups entitlement
4. **Try deleting** and re-adding App Groups capability

## Advanced

### Checking App Group Data Manually

You can verify data is being saved:

```swift
// In your main app or extension
if let userDefaults = UserDefaults(suiteName: "group.com.yourcompany.polargx") {
    print("organizationUnid:", userDefaults.string(forKey: "polar.organizationUnid") ?? "nil")
    print("userUnid:", userDefaults.string(forKey: "polar.userUnid") ?? "nil")
    print("apiKey:", userDefaults.string(forKey: "polar.apiKey") ?? "nil")
    print("environment:", userDefaults.string(forKey: "polar.environment") ?? "nil")
}
```

### Custom Event Attributes

The SDK automatically tracks these attributes:
- `$pl_cpid` - Campaign ID from push payload

Future versions will support custom attributes.

## Support

- **Documentation:** [https://docs.polargx.com](https://docs.polargx.com)
- **GitHub Issues:** [https://github.com/polargx/polargx-swift-sdk/issues](https://github.com/polargx/polargx-swift-sdk/issues)
- **Email:** support@polargx.com

## What's Next?

- 🔜 Rich media attachment support
- 🔜 Custom notification actions
- 🔜 Content modification based on user attributes
