#### For GCM (Google Cloud Messaging)

Follow these detailed steps to obtain your Service Account JSON credentials. The token must be string encoded (JSON stringified) before passing to the API.

**Step 1: Enable Firebase Cloud Messaging API**

1. Go to [Firebase Console](https://console.firebase.google.com) and select your project
2. Ensure **Firebase Cloud Messaging API (V1)** is enabled
3. You can check the status on the **Status Dashboard** link shown in your project settings

**Step 2: Access Project Settings**

1. Click the **⚙️ gear icon** next to "Project Overview" and select **Project settings**
2. You'll see your **Sender ID** displayed - note this for reference

**Step 3: Navigate to Service Accounts**

1. In **Project settings**, go to the **Service accounts** tab
2. Here you'll see your service account email and options to manage it
3. Click on **Manage Service Accounts** link to open Google Cloud Console

**Step 4: Access Service Account Keys**

1. In the **Google Cloud Console**, find your Firebase Admin SDK service account (format: `firebase-adminsdk-xxxxx@your-project.iam.gserviceaccount.com`)
2. Click on it to view details, then go to the **Keys** tab at the top

**Step 5: Create and Download JSON Key**

1. Click **Add key → Create new key**
2. Select **JSON** as the key type (recommended) and click **Create**
3. A JSON file containing your private key will be automatically downloaded
4. **⚠️ Store this file securely** - it can't be recovered if lost!

**Step 6: Get Bundle ID**

1. Go to **Project settings → General tab → Your apps** section
2. Find your iOS app's identifier (e.g., `com.yourcompany.yourapp`)
3. This is your **Bundle ID** for iOS

**💡 Pro Tip**: You can register multiple iOS apps under the same Firebase project and reuse the same service account credentials.

**⚠️ Security Warning**: Service account keys grant full access to your Firebase project. Never commit them to version control, share them publicly, or embed them in client-side code. Use the Workload Identity Google Cloud feature or rotate keys regularly for production environments.

**Step 7: Upload JSON File to PolarGX**

1. Go to [https://app.polargx.com](https://app.polargx.com)
2. Navigate to **CONFIGURATIONS > Push Services**
3. Click **+ New Push Service** and select **Google Cloud Messaging (GCM)**
4. Fill in the required information:
   * **Service Name**: Enter a descriptive name
   * **Bundle ID - iOS**: Enter your iOS app's Bundle ID (from Step 6)
   * **Upload your GCM service account file**: Upload the JSON file you downloaded (from Step 5)
5. The system will automatically string encode it for you
6. Click **Create** or **Save** to complete the setup

**Step 8: Add iOS App to Firebase (Required for FCM token in app)**

To use FCM tokens in your iOS app, you need to:

1. In your Firebase project, click **Add app** and select **iOS**
2. Enter your iOS app's **Bundle ID** (must match your Xcode project's Bundle Identifier)
3. Download the `GoogleService-Info.plist` file
4. Add the `GoogleService-Info.plist` file to your Xcode project
5. Install Firebase SDK (see implementation section below)