import Foundation

struct LinkDataResponseModel: Decodable {
    let appLinkData: LinkDataModel
}

struct LinkDataModel: Decodable {
    let data: DictionaryModel?
}
