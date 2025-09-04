import Foundation

extension APIService {
    @discardableResult
    func updateUser(_ user: UpdateUserModel) async throws -> EmptyModel? {
        return try await request(
            method: .POST,
            path: "/api/v1/users/profile",
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
            path: "/api/v1/events",
            headers: [:],
            queries: [:],
            body: event,
            logResult: false,
            result: EmptyModel.self
        )
    }
}
