import Foundation

struct UpdateUserModel: Codable {
    let organizationUnid: String
    let userID: String
    let data: DictionaryModel
    
    init(organizationUnid: String, userID: String, data: [String: Any]) {
        self.organizationUnid = organizationUnid
        self.userID = userID
        self.data = DictionaryModel(content: data)
    }
}
