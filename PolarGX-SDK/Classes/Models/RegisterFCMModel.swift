
import Foundation

struct RegisterFCMModel: Codable {
    let organizationUnid: String
    let userID: String
    let fcmToken: String
    
    init(organizationUnid: String, userID: String, fcmToken: String) {
        self.organizationUnid = organizationUnid
        self.userID = userID
        self.fcmToken = fcmToken
    }
}

typealias DeregisterFCMModel = RegisterFCMModel

/*
{
  "fcmToken": "string",
  "organizationUnid": "string",
  "userID": "string"
}*/
