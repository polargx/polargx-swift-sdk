
import Foundation

enum PushEvent: String {
    case opened = "opened"
    case delivered = "delivered"
}

struct PushEventModel: Codable {
    let organizationUnid: String
    let pushUnid: String
    let action: String
    
    init(organizationUnid: String, pushUnid: String, action: PushEvent) {
        self.organizationUnid = organizationUnid
        self.pushUnid = pushUnid
        self.action = action.rawValue
    }
    
    func toJsonDictionary() -> [String: Any] {
        return [
            "organizationUnid": organizationUnid,
            "pushUnid": pushUnid,
            "action": action
        ]
    }
}
