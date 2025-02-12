

import Foundation

class ReleaseConfigutation {
    static let Brand = "LinkAttribution"
    class var Server: String { "https://jw4xix6q44.execute-api.us-east-1.amazonaws.com/prod" }
}

#if DEBUG
class Configuration: ReleaseConfigutation {
    override class var Server: String { "https://jw4xix6q44.execute-api.us-east-1.amazonaws.com/dev" }
}
#else
typealias Configuration = ReleaseConfigutation
#endif
