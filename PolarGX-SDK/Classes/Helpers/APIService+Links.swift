import Foundation

extension APIService {
    
    @discardableResult
    func getLinkData(domain: String, slug: String) async throws -> LinkDataModel? {
        return try await request(
            method: .GET,
            path: "/sdk/v1/links/data",
            headers: [:],
            queries: ["domain": domain, "slug": slug],
            body: nil,
            result: LinkDataResponseModel.self
        )?.sdkLinkData
    }
    
    @discardableResult
    func trackLinkClick(_ click: LinkClickModel) async throws -> LinkClickResultModel? {
        return try await request(
            method: .POST,
            path: "/sdk/v1/links/track",
            headers: [:],
            queries: [:],
            body: click,
            result: LinkClickResponseModel.self
        )?.linkClick
    }
    
    @discardableResult
    func updateLinkClick(clickUnid: String, sdkUsed: Bool) async throws -> EmptyModel? {
        return try await request(
            method: .PUT,
            path: "/sdk/v1/links/clicks/\(clickUnid)",
            headers: [:],
            queries: [:],
            body: ["SdkUsed": sdkUsed],
            logResult: false,
            result: EmptyModel.self
        )
    }
}
