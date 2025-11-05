

import Foundation

protocol EnvConfigrationDescribe {
    var name: String { get }
    var server: String { get }
    var supportedBaseDomains: [String] { get }
    
    var isDevelopment: Bool { get }
    var isDebugging: Bool { get }
}

extension EnvConfigrationDescribe {
    var appLinkServer: String {
        "https://___default.\(supportedBaseDomains.last!)"
    }
}

struct ProdEnvConfigutation: EnvConfigrationDescribe {
    var name: String { "Production" }
    var server: String { "https://8mr6rftgmb.execute-api.us-east-1.amazonaws.com/prod" }
    var appLinkServer: String { "https://___default.gxlnk.com" }
    var supportedBaseDomains: [String] { ["gxlnk.com"] }
    
    var isDevelopment: Bool { false }
    var isDebugging: Bool { false }
}

class DevEnvConfigutation: EnvConfigrationDescribe {
    var name: String { "Development" }
    var server: String { "https://8mr6rftgmb.execute-api.us-east-1.amazonaws.com/dev" }
    var appLinkServer: String { "https://___default.biglittlecookies.com" }
    var supportedBaseDomains: [String] { ["biglittlecookies.com"] }

    var isDevelopment: Bool { true }
    var isDebugging: Bool
    
    init(isDebugging: Bool) {
        self.isDebugging = isDebugging
    }
}

struct Configuration {
    static let Brand = "Polar"
    static var Env: EnvConfigrationDescribe = ProdEnvConfigutation()
}
