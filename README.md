## PolarGX Swift SDK Installation Guide
### 1. Create and setup Polar app: 
- Register PolarGX account at https://app.polargx.com, after signup `unnamed` app has been created automatically.
- Setting your app in _App Settings > App Information_
- Create an API Key in _App Settings > API Keys_ with _Mobile apps / frontend_ purpose
- Configure your domain in _Link Attribution > Configuration > Link domain section_ with:
  + Default link domain.
  + Alternate link domain.
- Configure your iOS Redirects in _Link Attribution > Configuration > Required Redirects section > iOS Redirects_ with:
  + App Store Search / AppStore Id or Custom URL: Help your link redirects to AppStore or your custom url if your app hasn't been installed.
  + Universal Links: Help your link opens app immediately if your app was installed.
    - Open https://developer.apple.com. Locate your app identifier in `Certificates, Identifiers & Profiles > Identifiers`
    - Use _App ID Prefix_ for _Apple App Prefix_
    - Use _Bundle ID_ for _Bundle Identifiers_
  + Scheme URL (depredicated way): Help your link opens app if your app was installed and can't be opened by _Universal Links_.
    Ex: `yourapp_schemeurl://`
  
### 2. Adding PolarGX SDK
#### 2.1. Use CocoaPods
- Install CocoaPods: please follow this [Guide: getting started](https://guides.cocoapods.org/using/getting-started.html).
- Set up CocoaPods in your project: please follow this [Guide: using cocoapods](https://guides.cocoapods.org/using/using-cocoapods.html),
- To Add PolarGX dependency, run:
    ```
    pod 'PolarGX'
    ```
#### 2.2. Use Swift Package Manager
- Comming soon

### 3. Configure Associated Domains:
- In Xcode, open target settings. In _Signing & Capabilities_ tab, enable _Associated Domains_ capability.
- In _Associated Domains_, add your app domains in **(1)** into Domains section with following format:
  ```
  applinks:{subdomain}.app.link
  applinks:{subdomain}-alternate.app.link
  ```
### 3. Configure URL Scheme:
- In Xcode, open target settings. In _Info_ tab, scroll down to _URL Types_ section.
- In _URL Types_ section, Add an URL Type with _URL Schemes_ set to _Scheme URL_ in **(1)**
  Ex: `yourapp_schemeurl`

### 4. Use PolarGX SDK
#### 4.1. In Swift Project
- Get _App Id_ and _API Key_ from https://app.polargx.com
- In _AppDelegate.swift_
  ```
  //Add: Import PolarGX
  import PolarGX
  
  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
      //Your existing code

      Add: Initialize Polar app
      PolarApp.initialize(appId: YOUR_APP_ID, apiKey: YOUR_API_KEY) { link, data, error in
          print("\n[POLAR] detect link clicked: \(link), data: \(data), error: \(error)\n")
          //Handle link clicked. This callback will be called in the main queue.
      }

      return true
  }


  func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([any UIUserActivityRestoring]?) -> Void) -> Bool {
      //Add: Polar app handles the user activity
      return PolarApp.shared.continueUserActivity(userActivity)
  }
  
  func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
      //Add: Polar app handles the opening url
      return PolarApp.shared.openUrl(url)
  }
  ```
- In _SceneDelegate.swift_
  ```
  //Add: Import PolarGX
  import PolarGX

  func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
      //Your existing code

      //Add: Polar app handles the user activity
      if let userActivity = connectionOptions.userActivities.first {
          _ = PolarApp.shared.continueUserActivity(userActivity)
      }

      //Add: Polar app handles the opening url
      if let url = connectionOptions.urlContexts.first?.url {
          _ = PolarApp.shared.openUrl(url)
      }
  }

  func scene(_ scene: UIScene, continue userActivity: NSUserActivity) {
      //Add: Polar app handles the user activity
      _ = PolarApp.shared.continueUserActivity(userActivity)
  }
  
  func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
      //Add: Polar app handles the opening url
      if let url = URLContexts.first?.url {
          _ = PolarApp.shared.openUrl(url)
      }
  }
  ```

