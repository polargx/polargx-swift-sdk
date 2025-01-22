

import Foundation

class ReleaseConfigutation {
    class var Server: String { "https://????" }
}

#if DEBUG
class Configuration: ReleaseConfigutation {
    override class var Server: String { "http://52.70.12.200:1323/api" }
}
#else
typealias Configuration = ReleaseConfigutation
#endif
