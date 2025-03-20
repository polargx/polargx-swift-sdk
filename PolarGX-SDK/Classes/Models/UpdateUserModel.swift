import Foundation

struct UpdateUserModel: Codable {
    let organizationUnid: String
    let userID: String
    let data: [String: String]
    
    init(organizationUnid: String, userID: String, data: [String : String]) {
        self.organizationUnid = organizationUnid
        self.userID = userID
        self.data = data
    }
}
