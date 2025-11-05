
import Foundation

enum PushToken {
    case apns(String)
    case gcm(String)
}

struct RegisterPushModel: Codable {
    let organizationUnid: String
    let userUnid: String
    let bundleID: String
    let platform: String
    let token: String
    let data: DictionaryModel?
    
    init(organizationUnid: String, userUnid: String, bundleID: String, pushToken: PushToken, data: [String: Any]) {
        self.organizationUnid = organizationUnid
        self.userUnid = userUnid
        self.bundleID = bundleID
        switch pushToken {
        case .apns(let token):
            self.platform = "APNS"
            self.token = token
        case .gcm(let token):
            self.platform = "GCM"
            self.token = token
        }
        self.data = DictionaryModel(content: data)
    }
}
