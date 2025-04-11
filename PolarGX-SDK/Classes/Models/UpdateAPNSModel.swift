
import Foundation

struct UpdateAPNSModel: Codable {
    let organizationUnid: String
    let userID: String
    let deviceToken: String
    
    init(organizationUnid: String, userID: String, deviceToken: String) {
        self.organizationUnid = organizationUnid
        self.userID = userID
        self.deviceToken = deviceToken
    }
}


/*
{
  "fcmToken": "string",
  "organizationUnid": "string",
  "userID": "string"
}*/

