import Foundation

extension APIService {
    @discardableResult
    func updateUser(_ user: UpdateUserModel) async throws -> EmptyModel? {
        return try await request(
            method: .POST,
            path: "/sdk/v1/users/profileUpdate",
            headers: [:],
            queries: [:],
            body: user,
            result: EmptyModel.self
        )
    }
    
    @discardableResult
    func trackEvent(_ event: TrackEventModel) async throws -> EmptyModel? {
        return try await request(
            method: .POST,
            path: "/sdk/v1/events/track",
            headers: [:],
            queries: [:],
            body: event,
            logResult: false,
            result: EmptyModel.self
        )
    }
    
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
