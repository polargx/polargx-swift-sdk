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
            result: EmptyModel.self
        )
    }
}
