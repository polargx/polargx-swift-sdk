import Foundation

struct TrackEventModel: Codable {
    let organizationUnid: String
    let eventName: String
    let timestamp: TimeInterval
    let data: [String: String]
}
