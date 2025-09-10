
import Foundation

class Logger {
    
    static func log(_ sf: @autoclosure () -> String) {
        if PolarApp.isLoggingEnabled {
            print("\n[\(Configuration.Brand)/Debug] \(sf())\n")
        }
    }

    static func rlog(_ sf: @autoclosure () -> String) {
        print("\n[\(Configuration.Brand)] \(sf())\n")
    }

}
