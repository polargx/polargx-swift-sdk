#### Configure Associated Domains:

* In Xcode, open target settings. In **Signing & Capabilities** tab, enable **Associated Domains** capability.
* In **Associated Domains**, add your link domain in **Create Polar project** step into Domains section with the following format:

  ```
  applinks:{subdomain}.gxlnk.com
  ```

#### Configure URL Scheme:

* In Xcode, open target settings. In **Info** tab, scroll to **URL Types** section.
* In **URL Types**, add a URL Type with **URL Schemes** set to the *Scheme URL* in **Create Polar project** step.
  Example: `yourapp_schemeurl`