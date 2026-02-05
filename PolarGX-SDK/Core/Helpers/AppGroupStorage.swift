import Foundation

class AppGroupStorage {
    public static let shared = AppGroupStorage()

    private init() {}

    private enum Keys {
        static let organizationUnid = "polargx.sdk.organizationUnid"
        static let apiKey = "polargx.sdk.apiKey"
        static let userUnid = "polargx.sdk.userUnid"
        static let environment = "polargx.sdk.environment"
        static let lastNotificationServiceResult = "polargx.sdk.lastNotificationServiceResult"
    }

    private var userDefaults: UserDefaults? {
        guard let appGroupIdentifier = PolarSettings.appGroupIdentifier else {
            Logger.wlog("PolarSettings.appGroupIdentifier not set. Data will not be shared with extensions.")
            return UserDefaults.standard
        }

        guard let userDefaults = UserDefaults(suiteName: appGroupIdentifier) else {
            Logger.wlog("Failed to create UserDefaults with suite name: \(appGroupIdentifier)")
            return nil
        }

        return userDefaults
    }

    public var organizationUnid: String? {
        get { userDefaults?.string(forKey: Keys.organizationUnid) }
        set {
            userDefaults?.set(newValue, forKey: Keys.organizationUnid)
            Logger.log("[AppGroupStorage] Set organizationUnid: \(newValue ?? "nil")")
        }
    }

    public var apiKey: String? {
        get { userDefaults?.string(forKey: Keys.apiKey) }
        set {
            userDefaults?.set(newValue, forKey: Keys.apiKey)
            Logger.log("[AppGroupStorage] Set apiKey: \(newValue != nil ? "***" : "nil")")
        }
    }

    public var userUnid: String? {
        get { userDefaults?.string(forKey: Keys.userUnid) }
        set {
            userDefaults?.set(newValue, forKey: Keys.userUnid)
            Logger.log("[AppGroupStorage] Set userUnid: \(newValue ?? "nil")")
        }
    }

    public var environment: String? {
        get { userDefaults?.string(forKey: Keys.environment) }
        set {
            userDefaults?.set(newValue, forKey: Keys.environment)
            Logger.log("[AppGroupStorage] Set environment: \(newValue ?? "nil")")
        }
    }
    
    public var lastNotificationServiceResult: String? {
        get { userDefaults?.string(forKey: Keys.lastNotificationServiceResult) }
        set {
            userDefaults?.set(newValue, forKey: Keys.lastNotificationServiceResult)
            Logger.log("[AppGroupStorage] Set lastNotificationServiceResult: \(newValue ?? "nil")")
        }
    }
    
    public func save() {
        userDefaults?.synchronize()
    }

    /// Clear all stored data
    public func clear() {
        userDefaults?.removeObject(forKey: Keys.organizationUnid)
        userDefaults?.removeObject(forKey: Keys.apiKey)
        userDefaults?.removeObject(forKey: Keys.userUnid)
        userDefaults?.removeObject(forKey: Keys.environment)
        Logger.log("[AppGroupStorage] Cleared all data")
    }
}
