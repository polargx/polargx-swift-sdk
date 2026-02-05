# PolarGX NotificationServiceExtension

Lightweight SDK for tracking push notification delivery in your iOS NotificationServiceExtension.

## Features

- ✅ Track `push_delivered` events automatically
- ✅ Read configuration from App Groups (no duplicate setup needed)
- ✅ Extract Polar-specific push data (`$polar`, `$pl_cpid`)
- 🔜 Rich media attachment support (coming soon)

## Installation

### Swift Package Manager

Add both products to your project:

```swift
dependencies: [
    .package(url: "https://github.com/polargx/polargx-swift-sdk.git", from: "3.2.0")
]

// In your app target
.product(name: "PolarGX", package: "polargx-swift-sdk")

// In your NotificationServiceExtension target
.product(name: "PolarGXNotificationService", package: "polargx-swift-sdk")
```

### CocoaPods

```ruby
# In your Podfile

# Main app target
target 'YourApp' do
  pod 'PolarGX', '~> 3.2.0'
end

# NotificationServiceExtension target
target 'YourNotificationServiceExtension' do
  pod 'PolarGX/NotificationServiceExtension', '~> 3.2.0'
end
```

## Setup

### Step 1: Configure App Groups

#### Enable App Groups Capability

1. Select your **main app target** in Xcode
2. Go to **Signing & Capabilities**
3. Click **+ Capability** and add **App Groups**
4. Create a new App Group: `group.com.yourcompany.polargx` (use your own identifier)

5. Repeat for your **NotificationServiceExtension target**

#### Update Main App

In your `AppDelegate.swift`:

```swift
import PolarGX

func application(_ application: UIApplication, didFinishLaunchingWithOptions...) -> Bool {
    // Configure App Group BEFORE initializing PolarApp
    AppGroupStorage.appGroupIdentifier = "group.com.yourcompany.polargx"

    // Initialize PolarApp as usual
    PolarApp.initialize(appId: "your-app-id", apiKey: "your-api-key") { link, data, error in
        // Handle deep links
    }

    // Update user
    PolarApp.shared.updateUser(userID: "user-123", attributes: [
        PolarEventKey.Email: "user@example.com"
    ])

    return true
}
```

### Step 2: Implement NotificationServiceExtension

In your `NotificationService.swift`:

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

        // Configure App Group (must match main app)
        PolarNotificationService.appGroupIdentifier = "group.com.yourcompany.polargx"

        // Optional: Enable logging for debugging
        PolarNotificationService.isLoggingEnabled = true

        if let bestAttemptContent = bestAttemptContent {
            // Let PolarGX handle the notification
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
        // Called just before extension will be terminated
        if let contentHandler = contentHandler, let bestAttemptContent = bestAttemptContent {
            contentHandler(bestAttemptContent)
        }
    }
}
```

## How It Works

1. **Main App** saves configuration to App Groups:
   - `organizationUnid` (appId)
   - `apiKey`
   - `userUnid` (current user)
   - `environment` (prod/dev/deb)

2. **NotificationServiceExtension** reads from App Groups and:
   - Checks if notification is a Polar push (`$polar: true`)
   - Extracts campaign ID (`$pl_cpid`)
   - Tracks `push_delivered` event to PolarGX backend

3. **User taps notification** → Main app tracks `push_open` event

## Events Tracked

| Event | Where | When |
|-------|-------|------|
| `push_delivered` | NotificationServiceExtension | When notification is delivered to device |
| `push_open` | Main App | When user taps notification |

## Troubleshooting

### No delivery events tracked

1. **Check App Group identifier** matches in both targets
2. **Verify main app** has called `AppGroupStorage.appGroupIdentifier = "..."`
3. **Ensure user is logged in** (`updateUser` called with valid `userID`)
4. **Enable logging** to see what's happening:
   ```swift
   PolarNotificationService.isLoggingEnabled = true
   ```
5. **Check device logs** in Xcode:
   - Device window → Open Console
   - Filter for "PolarNotificationService"

### App Group not working

- Make sure both targets have **the same App Group identifier**
- Check that App Group is enabled in **Apple Developer Portal** for your App ID
- Clean build folder (Cmd+Shift+K) and rebuild

### Events not showing in backend

- Verify API key is correct in main app
- Check that `organizationUnid` matches your PolarGX dashboard
- Ensure device has internet connectivity
- Look for HTTP errors in logs (403 = invalid credentials, 400 = bad request)

## Advanced Usage

### Custom Logic Before/After Tracking

The SDK handles tracking automatically, but you can add custom logic:

```swift
PolarNotificationService.handleNotification(
    request: request,
    bestAttemptContent: bestAttemptContent
) { modifiedContent in
    // Delivery event has been tracked at this point

    // Add custom logic here
    if let category = modifiedContent.categoryIdentifier, category == "PROMO" {
        modifiedContent.badge = NSNumber(value: 1)
    }

    contentHandler(modifiedContent)
}
```

## Testing

### Send Test Push via PolarGX Dashboard

Ensure your push payload includes:

```json
{
  "aps": {
    "alert": {
      "title": "Test Title",
      "body": "Test Body"
    },
    "mutable-content": 1
  },
  "$polar": true,
  "$pl_cpid": "campaign-123"
}
```

**Important:** `"mutable-content": 1` is required for the extension to run!

### Verify Delivery Tracking

1. Send test push from dashboard
2. Check device logs for `[PolarNotificationService]` messages
3. Verify `push_delivered` event in PolarGX analytics

## Support

For issues or questions:
- GitHub: https://github.com/polargx/polargx-swift-sdk/issues
- Documentation: https://docs.polargx.com
