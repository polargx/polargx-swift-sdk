import Foundation
import UIKit
import WebKit

#if canImport(PolarGXCore)
@_exported import PolarGXCore
#endif

class FingerprintGenerator {
    private lazy var webView = WKWebView(frame: UIScreen.main.bounds)
    
    @MainActor
    func generateFingerprint(ip: String) async -> String {
        _ = webView;
        
        let deviceType = "ios"
        let webkitFingerprint = (try? await getWebKitFingerprint()) ?? ""
        
        let fingerprint = "\(deviceType)#ip:\(ip)" + webkitFingerprint
        return fingerprint
    }
    
    private func getWebKitVersion() -> String {
        let userAgent = webView.value(forKey: "userAgent") as? String ?? ""
        
        if let range = userAgent.range(of: "AppleWebKit/") {
            let startIndex = range.upperBound
            let substring = userAgent[startIndex...]
            if let spaceRange = substring.range(of: " ") {
                return String(substring[..<spaceRange.lowerBound])
            }
        }
        
        return "_"
    }
    
    @MainActor
    private func getWebKitFingerprint() async throws -> String? {
        let jsScript = """
        (() => {
                const timeZone = Intl.DateTimeFormat().resolvedOptions().timeZone
                const locale = Intl.DateTimeFormat().resolvedOptions().locale
                const language = navigator.language
                const languages = navigator.languages?.join(',') || navigator.language
                const platform = navigator.platform
                const userAgent = navigator.userAgent
                const webkitVersion = userAgent.match(/AppleWebKit\\/([^\\s]+)/)?.[1] || ''
                const devicePixelRatio = window.devicePixelRatio
                return `#tz:${timeZone}#locale:${locale}#lang:${language}#langs:${languages}#platform:${platform}#webkit:${webkitVersion}#dpr:${devicePixelRatio}`
        })()
        """
        return try await webView.evaluateJavaScript(jsScript) as? String
    }
    
    private func getWebKitLocale() async throws -> String? {
        let jsScript = "Intl.DateTimeFormat().resolvedOptions().locale;"
        return try await webView.evaluateJavaScript(jsScript) as? String
    }
    
    private func getPlatform() -> String {
        switch UIDevice.current.userInterfaceIdiom {
        case .phone:
            return "iPhone"
        case .pad:
            return "iPad"
        default:
            return "\(UIDevice.current.userInterfaceIdiom)"
        }
    }
}
