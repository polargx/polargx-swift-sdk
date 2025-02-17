import Foundation
import UIKit

@MainActor
struct SystemInfo {
    static var osName: String {
        UIDevice.current.systemName
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
}
