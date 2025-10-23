
import Foundation

class Logger {
    static var initialTime = InitialTime()
    
    static func log(_ sf: @autoclosure () -> String) {
        if PolarApp.isLoggingEnabled {
            print("\n\(initialTime.currentIntervalString())-[\(Configuration.Brand)/Debug] \(sf())\n")
        }
    }

    static func rlog(_ sf: @autoclosure () -> String) {
        print("\n\(initialTime.currentIntervalString())-[\(Configuration.Brand)] \(sf())\n")
    }
    
    
    class InitialTime {
        var value = Date()
        
        func currentInterval() -> TimeInterval {
            return Date().timeIntervalSince(value)
        }
        
        func currentIntervalString() -> String {
            return String(format: "%.2lfs", currentInterval())
        }
    }

}
