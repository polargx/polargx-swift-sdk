import Foundation

extension APIService {
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
    func trackLinkClick(_ click: LinkClickModel) async throws -> EmptyModel? {
        return try await request(
            method: .POST,
            path: "/sdk/v1/links/track",
            headers: [:],
            queries: [:],
            body: click,
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
        )?.appLinkData
    }
}
