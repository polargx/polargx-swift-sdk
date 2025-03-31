

import Foundation

protocol EnvConfigrationDescribe {
    var name: String { get }
    var server: String { get }
    var supportedBaseDomains: [String] { get }
}

struct ProdEnvConfigutation: EnvConfigrationDescribe {
    var name: String { "Production" }
    var server: String { "https://lydxigat68.execute-api.us-east-1.amazonaws.com/prod" }
    var supportedBaseDomains: [String] { ["gxlnk.com"] }
}

class DevEnvConfigutation: EnvConfigrationDescribe {
    var name: String { "Development" }
    var server: String { "https://lydxigat68.execute-api.us-east-1.amazonaws.com/dev" }
    var supportedBaseDomains: [String] { ["makelabs.ai"] }
}

struct Configuration {
    static let Brand = "Polar"
    static var Env: EnvConfigrationDescribe = ProdEnvConfigutation()
}
