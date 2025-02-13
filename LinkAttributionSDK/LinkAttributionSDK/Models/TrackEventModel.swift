import Foundation

struct TrackEventModel: Codable {
    let organizationUnid: String
    let eventName: String
    let eventTime: String
    let data: [String: String]
    
    init(organizationUnid: String, eventName: String, eventTime: Date, data: [String : String]) {
        self.organizationUnid = organizationUnid
        self.eventName = eventName
        self.eventTime = Formatter.BackendDateTimeMsFormatter.string(from: eventTime)
        self.data = data
    }
}
