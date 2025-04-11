
import Foundation

struct UpdateFCMModel: Codable {
    let organizationUnid: String
    let userID: String
    let fcmToken: String
    
    init(organizationUnid: String, userID: String, fcmToken: String) {
        self.organizationUnid = organizationUnid
        self.userID = userID
        self.fcmToken = fcmToken
    }
}


/*
{
  "fcmToken": "string",
  "organizationUnid": "string",
  "userID": "string"
}*/
