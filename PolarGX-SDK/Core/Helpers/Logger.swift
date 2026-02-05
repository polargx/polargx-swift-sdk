
import Foundation

class Logger {
    static var initialTime = InitialTime()
    
    static func log(_ sf: @autoclosure () -> String) {
        if PolarSettings.isLoggingEnabled {
            print("\n\(initialTime.currentIntervalString())-[\(Configuration.Brand)/Debug] \(sf())\n")
        }
    }

    static func rlog(_ sf: @autoclosure () -> String) {
        print("\n\(initialTime.currentIntervalString())-[\(Configuration.Brand)] \(sf())\n")
    }
    
    static func wlog(_ sf: @autoclosure () -> String) {
        print("\nWARN⚠️: \(initialTime.currentIntervalString())-[\(Configuration.Brand)] \(sf())\n")
    }
    
    static func elog(_ sf: @autoclosure () -> String) {
        print("\nERROR🅱️: \(initialTime.currentIntervalString())-[\(Configuration.Brand)] \(sf())\n")
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
