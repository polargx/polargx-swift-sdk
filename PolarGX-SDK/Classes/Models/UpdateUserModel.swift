import Foundation

#if canImport(PolarGXCore)
@_exported import PolarGXCore
#endif

struct UpdateUserModel: Codable {
    let clobberMatchingAttributes: Bool
    let organizationUnid: String
    let userID: String
    let data: DictionaryModel
    
    init(organizationUnid: String, userID: String, data: [String: Any]) {
        self.clobberMatchingAttributes = true //merging enabled
        self.organizationUnid = organizationUnid
        self.userID = userID
        self.data = DictionaryModel(content: data)
    }
    
    func toJsonDictionary() -> [String: Any] {
        return [
            "organizationUnid": organizationUnid,
            "userID": userID,
            "clobberMatchingAttributes": clobberMatchingAttributes,
            "data": data.content
        ]
    }
}
