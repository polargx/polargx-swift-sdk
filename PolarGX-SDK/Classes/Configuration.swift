

import Foundation

class ReleaseConfigutation {
    static let Brand = "Polar"
    class var Server: String { "https://lydxigat68.execute-api.us-east-1.amazonaws.com/prod" }
    class var SupportedBaseDomains: [String] { ["gxlnk.com"] }
}

//#if DEBUG
class Configuration: ReleaseConfigutation {
    override class var Server: String { "https://lydxigat68.execute-api.us-east-1.amazonaws.com/dev" }
    override class var SupportedBaseDomains: [String] { ["makelabs.ai"] }
}
//#else
//typealias Configuration = ReleaseConfigutation
//#endif
