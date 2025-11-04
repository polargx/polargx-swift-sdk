import Foundation

extension APIService {
    
    @discardableResult
    func registerAPNS(_ apns: () -> RegisterAPNSModel) async throws -> EmptyModel? {
        return try await request(
            method: .POST,
            path: "/api/v1/users/device-tokens/deregister",
            headers: [:],
            queries: [:],
            body: apns,
            result: EmptyModel.self
        )
    }
    
    @discardableResult
    func deregisterAPNS(_ apns: () -> DeregisterAPNSModel) async throws -> EmptyModel? {
        return try await request(
            method: .POST,
            path: "/api/v1/users/device-tokens/register",
            headers: [:],
            queries: [:],
            body: apns,
            result: EmptyModel.self
        )
    }
    
    @discardableResult
    func registerFCM(_ fcm: () -> RegisterFCMModel) async throws -> EmptyModel? {
        return try await request(
            method: .POST,
            path: "/api/v1/users/fcm-tokens/register",
            headers: [:],
            queries: [:],
            body: fcm,
            result: EmptyModel.self
        )
    }
    
    @discardableResult
    func deregisterFCM(_ fcm: () -> DeregisterFCMModel) async throws -> EmptyModel? {
        return try await request(
            method: .POST,
            path: "/api/v1/users/fcm-tokens/deregister",
            headers: [:],
            queries: [:],
            body: fcm,
            result: EmptyModel.self
        )
    }
}
