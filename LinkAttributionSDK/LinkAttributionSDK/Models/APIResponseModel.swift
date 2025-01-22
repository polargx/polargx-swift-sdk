
import Foundation

struct APIResponseModel<DATA: Decodable>: Decodable {
    let data: DATA?
    let code: Int?
    let message: String?
}


struct APIErrorResponse {
    let httpStatus: Int
    let code: Int
    let message: String
}
