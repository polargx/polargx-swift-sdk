

import Foundation

protocol EnvConfigrationDescribe {
    var server: String { get }
    var supportedBaseDomains: [String] { get }
}

struct ProdEnvConfigutation: EnvConfigrationDescribe {
    var server: String { "https://lydxigat68.execute-api.us-east-1.amazonaws.com/prod" }
    var supportedBaseDomains: [String] { ["gxlnk.com"] }
}

class DevEnvConfigutation: EnvConfigrationDescribe {
    var server: String { "https://lydxigat68.execute-api.us-east-1.amazonaws.com/dev" }
    var supportedBaseDomains: [String] { ["makelabs.ai"] }
}

struct Configuration {
    static let Brand = "Polar"
    static let Env: EnvConfigrationDescribe = PolarApp.isDevelopmentEnabled ? DevEnvConfigutation() : ProdEnvConfigutation()
}
