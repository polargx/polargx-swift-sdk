
struct ClientActivityCreateModel: Codable {
    let appIdentifier: String
    let appVersion: String
    let sdkVersion: String
    let deviceModel: String
    let screenSize: ScreenSizeModel
    
    init(appIdentifier: String, appVersion: String, sdkVersion: String, deviceModel: String, screenSize: ScreenSizeModel) {
        self.appIdentifier = appIdentifier
        self.appVersion = appVersion
        self.sdkVersion = sdkVersion
        self.deviceModel = deviceModel
        self.screenSize = screenSize
    }
}

struct ScreenSizeModel: Codable {
    let width: Int
    let height: Int
    let resolution: String
}

struct ClientActivityModel: Codable {
    let unid: String
    let appIdentifier: String
    let appVersion: String
    let sdkVersion: String
    let deviceModel: String
    let screenSize: ScreenSizeModel
}
