import Foundation
import UIKit

@MainActor
struct SystemInfo {
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
    
    static func getTrackingDeviceInfo() -> [String: Any] {
        return [
            "OSName": osName,
            "OSVersion": osVersion,
            "model": deviceModel,
            "SDKVersion": sdkVersion,
            "appVersion": appVersion
        ]
    }
}
