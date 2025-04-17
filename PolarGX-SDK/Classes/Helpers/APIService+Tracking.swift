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
}
