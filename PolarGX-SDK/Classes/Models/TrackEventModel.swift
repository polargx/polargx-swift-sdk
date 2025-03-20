import Foundation

struct TrackEventModel: Codable {
    let organizationUnid: String
    let userID: String
    let eventName: String
    let eventTime: String
    let data: [String: String]
    
    var eventUnid: String?
    
    init(organizationUnid: String, userID: String, eventName: String, eventTime: Date, data: [String : String]) {
        self.organizationUnid = organizationUnid
        self.userID = userID
        self.eventName = eventName
        self.eventTime = Formatter.BackendDateTimeMsFormatter.string(from: eventTime)
        self.data = data
    }
}
