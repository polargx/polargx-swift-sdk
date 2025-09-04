
import Foundation

struct APIResponseModel<DATA: Decodable>: Decodable {
    let data: DATA?
    let error: APIErrorResponse?
}


struct APIErrorResponse: Decodable {
    var httpStatus: Int!
    let code: String
    let message: String
    let statusCode: Int
    
    enum CodingKeys: CodingKey {
        case code
        case message
        case statusCode
    }
}
