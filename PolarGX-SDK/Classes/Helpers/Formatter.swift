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
    
    static func validateSupportingURL(_ url: URL) -> (subDomain: String, slug: String)? {
        let supportDomains = Configuration.SupportedBaseDomains
        
        let pathComponents = url.path.split(separator: "/").filter({ !$0.isEmpty })
        guard pathComponents.count < 2 else {
            return nil
        }
        let slug = pathComponents.first ?? ""
        
        let host = url.host ?? ""
        for supportDomain in supportDomains {
            if host.hasSuffix("." + supportDomain) {
                let subDomain = host[..<host.index(host.endIndex, offsetBy: -supportDomain.count - 1)]
                if !subDomain.isEmpty {
                    return (String(subDomain), String(slug))
                }
            }
        }
        
        return nil
    }
}

extension Locale {
    static let en_US_POSIX: Locale = Locale(identifier: "en_US_POSIX")
}

extension TimeZone {
    static let UTC: TimeZone = TimeZone(identifier: "UTC")!
}
