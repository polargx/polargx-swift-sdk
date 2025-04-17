import Foundation

extension APIService {
    
    @discardableResult
    func registerAPNS(_ apns: RegisterAPNSModel) async throws -> EmptyModel? {
        return try await request(
            method: .POST,
            path: "/sdk/v1/users/registerDeviceToken",
            headers: [:],
            queries: [:],
            body: apns,
            result: EmptyModel.self
        )
    }
    
    @discardableResult
    func deregisterAPNS(_ apns: DeregisterAPNSModel) async throws -> EmptyModel? {
        return try await request(
            method: .POST,
            path: "/sdk/v1/users/deregisterDeviceToken",
            headers: [:],
            queries: [:],
            body: apns,
            result: EmptyModel.self
        )
    }
    
    @discardableResult
    func registerFCM(_ fcm: RegisterFCMModel) async throws -> EmptyModel? {
        return try await request(
            method: .POST,
            path: "/sdk/v1/users/registerFcmToken",
            headers: [:],
            queries: [:],
            body: fcm,
            result: EmptyModel.self
        )
    }
    
    @discardableResult
    func deregisterFCM(_ fcm: DeregisterFCMModel) async throws -> EmptyModel? {
        return try await request(
            method: .POST,
            path: "/sdk/v1/users/deregisterFcmToken",
            headers: [:],
            queries: [:],
            body: fcm,
            result: EmptyModel.self
        )
    }
}
