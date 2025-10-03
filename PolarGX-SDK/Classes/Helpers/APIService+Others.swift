import Foundation

extension APIService {
    @discardableResult
    func getClientInfo() async throws -> ClientInfoModel? {
        return try await request(
            method: .GET,
            url: URL(string: appLinkServer + "/api/client-info")!,
            headers: [:],
            queries: [:],
            body: nil,
            logResult: false,
            result: ClientInfoModel.self
        )
    }
    
    func getClientIP() async throws -> String? {
        do {
            let (ipifyData, ipifyResponse) = try await URLSession(configuration: .default).data(for: URLRequest(url: URL(string: "https://api64.ipify.org/")!))
            guard let status = (ipifyResponse as? HTTPURLResponse)?.statusCode, status >= 200, status <= 299 else {
                throw Errors.with(message: "Failed with response: \(ipifyResponse)")
            }
            
            guard let ipifyIp = String(data: ipifyData, encoding: .utf8) else {
                throw Errors.with(message: "Failed to convert to utf8 string with response: \(ipifyResponse)")
            }
            
            return ipifyIp
            
        }catch let e {
            Logger.rlog("[ERROR] Can't get ipv6 from ipify.org: \(e)")
            return try await getClientInfo()?.ip
        }
    }
}
