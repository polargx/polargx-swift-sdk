import Foundation

#if canImport(PolarGXCore)
@_exported import PolarGXCore
#endif

extension APIService {
    
    @discardableResult
    func registerPushToken(_ body: () async throws -> RegisterPushModel) async throws -> EmptyModel? {
        return try await request(
            method: .POST,
            path: "/api/v1/users/device-tokens",
            headers: [:],
            queries: [:],
            body: body,
            result: EmptyModel.self
        )
    }
    
    @discardableResult
    func deregisterPushToken(_ registerPush: RegisterPushModel) async throws -> EmptyModel? {
        return try await request(
            method: .DELETE,
            path: "/api/v1/users/device-tokens",
            headers: [:],
            queries: [
                "organizationUnid": registerPush.organizationUnid,
                "userUnid": registerPush.userUnid,
                "token": registerPush.token,
                "platform": registerPush.platform,
                "bundleID": registerPush.bundleID,
            ],
            body: {nil},
            result: EmptyModel.self
        )
    }
    
}
