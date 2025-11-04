import Foundation

internal struct PolarConstants {
    internal static let LinkMineTypePrefix = "com.polargx.link."
    internal static var DeplayToUpdateProfileDuration: UInt64 { Configuration.Env.isDevelopment ? 0 : 1_000_000_000 }
    internal static var DeplayToRetryAPIRequestIfServerError: UInt64 { Configuration.Env.isDevelopment ? 10_000_000_000 : 300_000_000_000 }
    internal static var DeplayToRetryAPIRequestIfTimeLimits: UInt64 { 5_000_000_000 }
}

public struct PolarEventKey {
    public static let Email: String = "email"
    public static let Name: String = "name"
    public static let FirstName: String = "firstName"
    public static let LastName: String = "lastName"
}
