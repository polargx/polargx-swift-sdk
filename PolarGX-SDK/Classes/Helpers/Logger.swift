
import Foundation

class Logger {
    
    static func log(_ sf: @autoclosure () -> String) {
        if PolarApp.isLoggingEnabled {
            print("[\(Configuration.Brand)/Debug] \(sf())")
        }
    }

    static func rlog(_ sf: @autoclosure () -> String) {
        print("[\(Configuration.Brand)] \(sf())")
    }

}
