#### For APNS (Apple Push Notification Service)

Follow these detailed steps to obtain the required information from Apple Developer Portal. You'll need an active **Apple Developer Program membership**.

**Step 1: Access Apple Developer Portal**

1. Visit [https://developer.apple.com/account](https://developer.apple.com/account) and sign in with your Apple Developer credentials
2. Make sure you have **admin** or **account holder** access to create authentication keys

**Step 2: Navigate to Keys Section**

1. From the left sidebar, select **Certificates, Identifiers & Profiles**
2. Click on **Keys** - this is where you'll manage your APNs authentication keys

**Step 3: Create New APNs Key**

1. Click the **+** button to create a new key
2. Enter a descriptive name (e.g., "Production Push Notifications")
3. Check the **Apple Push Notifications service (APNs)** checkbox
4. Click **Continue** and then **Register** to complete the creation

**Step 4: Download Authentication Key**

1. Click **Download** to save the `.p8` file to your computer
2. Keep this file secure as it provides access to your APNs service

**⚠️ Important**: _This file can only be downloaded once. If you lose it, you'll need to create a new key_

**Step 5: Record Key ID and Team ID**

1. After creating the key, you'll see a **Key ID** (a 10-character string like `ABC123DEFG`) - copy this value
2. For your **Team ID**, go to the **Membership** section in your account settings - it's displayed at the top right (also a 10-character string)

**Step 6: Get Your App Bundle ID**

1. Navigate to **Identifiers** and select your app
2. The **Bundle ID** is shown in the format `com.yourcompany.yourapp`
3. This identifier must match exactly what's configured in your iOS app's Xcode project

**💡 Pro Tip**: _You can use the same `.p8` authentication key for multiple apps within your team. However, each app must have its own unique Bundle ID._

**Step 7: Upload APNS Credentials to PolarGX**

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