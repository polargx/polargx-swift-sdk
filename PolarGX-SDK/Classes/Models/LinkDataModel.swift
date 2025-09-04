import Foundation

struct LinkDataResponseModel: Decodable {
    let sdkLinkData: LinkDataModel
}

struct LinkDataModel: Decodable {
    let analyticsTags: DictionaryModel?
    let socialMediaTags: DictionaryModel?
    let data: DictionaryModel?
    let slug: String?
    let url: String?
}
