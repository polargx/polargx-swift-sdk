import Foundation

private let ErrorDomain = "LinkAttributionSDKErrorDomain"


extension Error {
    
    var userInfo: [String: Any] {
        (self as NSError).userInfo
    }
    
    var apiError: APIErrorResponse? {
        userInfo["APIError"] as? APIErrorResponse
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
            code: 0,
            userInfo: [
                NSLocalizedDescriptionKey: error.message,
                "APIError": error
            ]
        ) as Error
    }
}

