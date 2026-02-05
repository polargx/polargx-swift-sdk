import Foundation

private let ErrorDomain = "\(Configuration.Brand)SDKErrorDomain"


extension Error {
    
    var userInfo: [String: Any] {
        (self as NSError).userInfo
    }
    
    var apiError: APIErrorResponse? {
        userInfo["\(Configuration.Brand)APIError"] as? APIErrorResponse
    }
}

struct Errors {
    static func with(message: String) -> Error {
        return NSError(domain: ErrorDomain, code: 0, userInfo: [NSLocalizedDescriptionKey: message]) as Error
    }
    
    static func unexpectedError() -> Error {
        with(message: "Unexpected error.")
    }
    
    static func apiError(_ error: APIErrorResponse) -> Error {
        return NSError(
            domain: ErrorDomain,
            code: error.statusCode ?? -1,
            userInfo: [
                NSLocalizedDescriptionKey: error.message + " #\(error.code ?? "NaN")",
                "\(Configuration.Brand)APIError": error
            ]
        ) as Error
    }
}

