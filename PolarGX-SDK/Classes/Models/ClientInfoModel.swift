import Foundation

#if canImport(PolarGXCore)
@_exported import PolarGXCore
#endif

struct ClientInfoModel: Decodable {
    let ip: String?
    let userAgent: String?
    let timestamp: String?
    
}
