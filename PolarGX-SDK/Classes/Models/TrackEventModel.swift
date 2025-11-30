import Foundation

struct TrackEventModel: Codable {
    let clobberMatchingAttributes: Bool
    let organizationUnid: String
    let userID: String
    let eventName: String
    let eventTime: String
    let data: DictionaryModel
    
    var eventUnid: String?
    
    init(organizationUnid: String, userID: String, eventName: String, eventTime: Date, data: [String: Any]) {
        self.clobberMatchingAttributes = false
        self.organizationUnid = organizationUnid
        self.userID = userID
        self.eventName = eventName
        self.eventTime = Formatter.BackendDateTimeMsFormatter.string(from: eventTime)
        self.data = DictionaryModel(content: data)
    }
    
    func toJsonDictionary() -> [String: Any] {
        return [
            "organizationUnid": organizationUnid,
            "userID": userID,
            "clobberMatchingAttributes": clobberMatchingAttributes,
            "eventName": eventName,
            "eventTime": eventTime,
            "data": data.content
        ]
    }
}
