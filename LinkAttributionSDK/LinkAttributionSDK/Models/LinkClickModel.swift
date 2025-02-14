import Foundation

struct LinkClickModel: Codable {
    let domain: String
    let slug: String
    let trackType: String
    let clickTime: String
    let fingerprint: String
    let deviceData: [String: String]
    let additionalData: [String: String]
    
    init(trackClick domain: String, slug: String, clickTime: Date, deviceData: [String: String], additionalData: [String: String]) {
        self.domain = domain
        self.slug = slug
        self.trackType = "app_click"
        self.clickTime = Formatter.BackendDateTimeMsFormatter.string(from: clickTime)
        self.fingerprint = "SwiftSDK"
        self.deviceData = deviceData
        self.additionalData = additionalData
    }
}
