import Foundation

struct Formatter {
    static let BackendDateTimeMsFormatter = dateFormatter(format: "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'", in: .UTC)
    
    static func dateFormatter(format: String, in timeZone: TimeZone) -> DateFormatter {
        let dateFormatter = DateFormatter();
        dateFormatter.locale = .en_US_POSIX;
        dateFormatter.dateFormat = format;
        dateFormatter.timeZone = timeZone;
        return dateFormatter;
    }
}

extension Locale {
    static let en_US_POSIX: Locale = Locale(identifier: "en_US_POSIX")
}

extension TimeZone {
    static let UTC: TimeZone = TimeZone(identifier: "UTC")!
}
