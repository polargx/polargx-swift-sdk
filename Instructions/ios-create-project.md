#### Create and configure Polar project in PolarGX Admin Portal

* Register your PolarGX account at [https://app.polargx.com](https://app.polargx.com).
* Create your project.
* Setting your project in [Project Settings](https://app.polargx.com/app/settings)
* Manage your API Keys in [API Keys Configuration](https://app.polargx.com/configuration/api-keys-configuration)
* Configure your link domain in [Link Configuration](https://app.polargx.com/configuration/link-configuration) > Required Redirects section > iOS Redirects with:
  * App Store Search / AppStore Id or Custom URL: Help your link redirects to AppStore or your custom url if your app hasn't been installed.
  * Universal Links: Help your link opens app immediately if your app was installed.
    * Open [https://developer.apple.com](https://developer.apple.com). Locate your app identifier in `Certificates, Identifiers & Profiles > Identifiers`
    * Use *App ID Prefix* for *Apple App Prefix*
    * Use *Bundle ID* for *Bundle Identifiers*
  * Scheme URI (deprecated way): Help your link opens app if your app was installed and can't be opened by *Universal Links*.
    Example: `yourapp_schemeurl://`