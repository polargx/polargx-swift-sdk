import Foundation

internal struct PolarConstants {
    internal static let LinkMineTypePrefix = "com.polargx.link."
    internal static var DeplayToUpdateProfileDuration: UInt64 { Configuration.Env.isDebugging ? 0 : 1_000_000_000 }
    internal static var DeplayToRetryAPIRequestIfServerError: UInt64 { Configuration.Env.isDebugging ? 10_000_000_000 : 300_000_000_000 }
    internal static var DeplayToRetryAPIRequestIfTimeLimits: UInt64 { 5_000_000_000 }
    
    internal static var BackendDateTimeMsFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
}

public struct PolarEventKey {
    public static let Email: String = "email"
    public static let Name: String = "name"
    public static let FirstName: String = "firstname"
    public static let LastName: String = "lastname"
    public static let phone: String = "phone"
}
