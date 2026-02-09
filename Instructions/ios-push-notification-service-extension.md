#### Configure Push Notification Service Extension:

To enable rich push notifications and track notification delivery events, add a Notification Service Extension:

1. **Create Notification Service Extension:**
   * In Xcode, go to **File > New > Target**.
   * Select **Notification Service Extension**.

2. **Configure App Groups:**

   Add the **same app group** to both your main app and notification service extension targets:

   * Go to target settings > **Signing & Capabilities**.
   * Add **App Groups** capability.
   * Add app group: `group.{your-bundle-id}` (e.g., `group.com.yourcompany.yourapp`)

   Your `.entitlements` files should include:
   ```xml
   <key>com.apple.security.application-groups</key>
   <array>
       <string>group.{your-bundle-id}</string>
   </array>
   ```

3. **Add PolarGX Notification Extension SDK:**

   Use `PolarGX_NotificationServiceExtension` for the extension target:

   * **CocoaPods:** Add to `Podfile`:
     ```ruby
     target 'YourApp-NotificationService' do
       pod 'PolarGX_NotificationServiceExtension'
     end
     ```

   * **Swift Package Manager:**
     - Select notification service extension target.
     - Go to **General > Frameworks and Libraries**.
     - Add **PolarGX_NotificationServiceExtension**.

4. **Implement Notification Service:**

   **Swift:**

   Replace `NotificationService.swift` content:

   ```swift
   import UserNotifications
   import PolarGX_NotificationServiceExtension

   class NotificationService: PolarNotificationService {
       override init() {
           super.init()
           PolarSettings.appGroupIdentifier = "group.{your-bundle-id}"
       }
   }
   ```

   **Objective-C:**

   Replace `NotificationService.h`:

   ```objc
   #import <PolarGX_NotificationServiceExtension/PolarGX_NotificationServiceExtension-Swift.h>

   @interface NotificationService : PolarNotificationService

   @end
   ```

   Replace `NotificationService.m`:

   ```objc
   #import "NotificationService.h"

   @implementation NotificationService

   - (instancetype)init {
       self = [super init];
       if (self) {
           PolarSettings.appGroupIdentifier = @"group.{your-bundle-id}";
       }
       return self;
   }

   @end
   ```

5. **Configure Main App:**

   Set the app group in your main app initialization. See:
   * [Swift setup instructions](ios-swift.md)
   * [Objective-C setup instructions](ios-objectivec.md)
