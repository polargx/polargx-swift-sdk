import Foundation

struct LinkDataResponseModel: Decodable {
    let sdkLinkData: LinkDataModel
}

struct LinkDataModel: Decodable {
    let data: DictionaryModel?
}
