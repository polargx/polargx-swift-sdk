import Foundation
import UIKit
import UserNotifications

#if canImport(PolarGXCore)
@_exported import PolarGXCore
#endif

@MainActor
public struct SystemInfo {
    static var osName: String {
        UIDevice.current.systemName
    }
    
    static var osVersion: String {
        UIDevice.current.systemVersion
    }
    
    static var deviceModel: String {
        UIDevice.current.model
    }
    
    static var screenSize: CGSize {
        UIScreen.main.bounds.size
    }
    
    static var screenScale: CGFloat {
        UIScreen.main.scale
    }
    
    static var sdkVersion: String {
        let bundle = Bundle(for: InternalPolarApp.self)
        let version = bundle.infoDictionary?["CFBundleShortVersionString"] as? String
        return version ?? ""
    }
    
    static var appVersion: String {
        let bundle = Bundle.main
        let version = bundle.infoDictionary?["CFBundleShortVersionString"] as? String
        return version ?? ""
    }
    
    static var appBundleId: String {
        let bundle = Bundle.main
        return bundle.bundleIdentifier ?? ""
    }
    
    static func notificationEnabled() async -> Bool {
        let settings = await UNUserNotificationCenter.current().notificationSettings()
        guard settings.authorizationStatus == .authorized else {
            return false
        }
        
        return settings.alertSetting == .enabled || settings.lockScreenSetting == .enabled || settings.notificationCenterSetting == .enabled
    }
    
    static func getTrackingDeviceInfo() async -> [String: Any] {
        return [
            "OSName": osName,
            "OSVersion": osVersion,
            "model": deviceModel,
            "SDKVersion": sdkVersion,
            "appVersion": appVersion,
            "pushSandbox": isAPSSandBox,
            "appBundleId": appBundleId,
            "notificationEnabled": await notificationEnabled()
        ]
    }
    
    public static let isAPSSandBox: Bool = {
        guard let embeddedProfile = getEmbeddedMobileProvisionProfile() else {
            return false
        }
        
        let entitlements = embeddedProfile["Entitlements"] as? [String: Any]
        let apsEnvironment = entitlements?["aps-environment"] as? String
        
        return apsEnvironment == "development"
    }()
    
}

extension SystemInfo {
    static func getEmbeddedMobileProvisionProfile() -> [String: Any]? {
        guard let profilePath = Bundle.main.path(forResource: "embedded", ofType: "mobileprovision") else {
            return nil
        }
        
        func extractPlistData(from provisioningData: Data) -> Data {
            // Extract plist from provisioning profile
            guard let startRange = provisioningData.range(of: "<?xml".data(using: .utf8)!),
                  let endRange = provisioningData.range(of: "</plist>".data(using: .utf8)!) else {
                return Data()
            }
            return provisioningData[startRange.lowerBound..<endRange.upperBound]
        }
        
        do {
            let profileData = try Data(contentsOf: URL(fileURLWithPath: profilePath))
            let profile = try PropertyListSerialization.propertyList(from: extractPlistData(from: profileData), options: [], format: nil) as? [String: Any]
            return profile
            
        }catch let e {
            Logger.log("SystemInfo: can't read embedded.mobileprovision: \(e)")
            return nil
        }
    }
}
