import Foundation

extension APIService {
    static var count = 0
    @discardableResult
    func updateUser(_ user: () async throws -> UpdateUserModel) async throws -> EmptyModel? {
        if Self.count > 0 {
            //throw Errors.with(message: "unkww1")
        }
        
        Self.count += 1

        return try await request(
            method: .POST,
            path: "/api/v1/users/profile",
            headers: [:],
            queries: [:],
            body: { try await user().toJsonDictionary() },
            result: EmptyModel.self
        )
    }
    
    @discardableResult
    func trackEvent(_ event: TrackEventModel) async throws -> EmptyModel? {
        //throw Errors.with(message: "unkww2")
        return try await request(
            method: .POST,
            path: "/api/v1/events",
            headers: [:],
            queries: [:],
            body: { event.toJsonDictionary() },
            logResult: false,
            result: EmptyModel.self
        )
    }
}
