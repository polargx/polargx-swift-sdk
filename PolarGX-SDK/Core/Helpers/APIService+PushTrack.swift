import Foundation

extension APIService {
    
    @discardableResult
    func trackPushEvent(_ body: () async throws -> PushEventModel) async throws -> EmptyModel? {
        return try await request(
            method: .POST,
            path: "/api/v1/users/push-track",
            headers: [:],
            queries: [:],
            body: body,
            result: EmptyModel.self
        )
    }
    
}
