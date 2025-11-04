import Foundation

extension APIService {
    
    @discardableResult
    func getLinkData(domain: String, slug: String) async throws -> LinkDataModel? {
        return try await request(
            method: .GET,
            path: "/api/v1/links/resolve",
            headers: [:],
            queries: ["domain": domain, "slug": slug],
            body: {nil},
            result: LinkDataResponseModel.self
        )?.sdkLinkData
    }
    
    @discardableResult
    func trackLinkClick(_ click: LinkClickModel) async throws -> LinkClickResultModel? {
        return try await request(
            method: .POST,
            path: "/api/v1/links/clicks",
            headers: [:],
            queries: [:],
            body: {click},
            result: LinkClickResponseModel.self
        )?.linkClick
    }
    
    @discardableResult
    func updateLinkClick(clickUnid: String, sdkUsed: Bool) async throws -> EmptyModel? {
        return try await request(
            method: .PUT,
            path: "/api/v1/links/clicks/\(clickUnid)",
            headers: [:],
            queries: [:],
            body: {["SdkUsed": sdkUsed]},
            logResult: false,
            result: EmptyModel.self
        )
    }
    
    @discardableResult
    func matchLinkClick(fingerprint: String) async throws -> LinkClickResponseModel? {
        return try await request(
            method: .GET,
            path: "/api/v1/links/clicks/match",
            headers: [:],
            queries: ["fingerprint": fingerprint],
            body: {nil},
            logResult: true,
            result: LinkClickResponseModel.self
        )
    }
}
