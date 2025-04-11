import Foundation

/// Purpose: create user if needed by calling UpdateUser api.
/// Manage events since userId to be set and send to backend.
/// One UserSession instance will be created for only one user (userID)
actor UserSession {
    let organizationUnid: String
    let userID: String
    let apiService: APIService
    let trackingStorageURL: URL
    
    private var attributes = [String: Any]()
    private var pendingRegisterPushToken: (apns: String?, fcm: String?)?
    
    lazy var trackingEventQueue = TrackingEventQueue(fileUrl: trackingStorageURL, apiService: apiService)
    
    init(organizationUnid: String, userID: String, apiService: APIService, trackingStorageURL: URL) {
        self.organizationUnid = organizationUnid
        self.userID = userID
        self.apiService = apiService
        self.trackingStorageURL = trackingStorageURL
    }
    
    /// Keep all user attributes for next sending. I don't make sure server supports to merging existing user attributes and the new attributues
    func setAttributes(_ attributes: [String: Any]) {
        Task {
            self.attributes = self.attributes.merging(attributes, uniquingKeysWith: { $1 })
            await startToUpdateUser()
        }
    }
    
    func setPushToken(apns: String?, fcm: String?) {
        Task {
            pendingRegisterPushToken = (apns, fcm)
            await startToRegisterPushToken()
        }
    }
    
    /// Sending user attributes and user id to backend. This API call will create an user if need. After succesful, we need to make `trackingEventQueue` to be ready and sending events if needed.
    /// Stop sending retrying process if server retuns status code #403.
    /// Retry when network connection issue, server returns status code #400 ...
    private func startToUpdateUser() async {
        var submitError: Error? = nil
        
        repeat {
            do {
                let attributes = self.attributes
                let user = UpdateUserModel(organizationUnid: organizationUnid, userID: userID, data: attributes)
                try await apiService.updateUser(user)
                
            }catch let error {
                if error.apiError?.httpStatus == 403 {
                    Logger.rlog("UpdateUser: ⛔️⛔️⛔️ INVALID appId OR apiKey! ⛔️⛔️⛔️")
                    submitError = nil
                    
                }else if error is EncodingError {
                    Logger.rlog("UpdateUser: ⛔️⛔️⛔️ failed + stopped ⛔️: \(error)")
                    submitError = nil
                    
                }else{
                    Logger.log("UpdateUser: failed ⛔️ + retrying 🔁: \(error)")
                    try? await Task.sleep(nanoseconds: 1_000_0000_000)
                    submitError = error
                }
            }
            
        }while submitError != nil
        
        if submitError == nil {
            await trackingEventQueue.setReady()
            await trackingEventQueue.sendEventsIfNeeded()
        }
    }
    
    /// Stop sending retrying process if server retuns status code #403.
    /// Retry when network connection issue, server returns status code #400 ...
    private func startToRegisterPushToken() async {
        var submitError: Error? = nil
        
        repeat {
            do {
                if let token = pendingRegisterPushToken?.apns {
                    let apns = UpdateAPNSModel(organizationUnid: organizationUnid, userID: userID, deviceToken: token)
                    try await apiService.registerAPNS(apns)
                    
                }else if let token = pendingRegisterPushToken?.fcm {
                    let fcm = UpdateFCMModel(organizationUnid: organizationUnid, userID: userID, fcmToken: token)
                    try await apiService.registerFCM(fcm)
                }else {
                    //TODO: how to unregister?
                }
                
                pendingRegisterPushToken = nil
                
            }catch let error {
                if error.apiError?.httpStatus == 403 {
                    Logger.rlog("RegisterPushToken: ⛔️⛔️⛔️ INVALID appId OR apiKey! ⛔️⛔️⛔️")
                    submitError = nil
                    
                }else if error is EncodingError {
                    Logger.rlog("RegisterPushToken: ⛔️⛔️⛔️ failed + stopped ⛔️: \(error)")
                    submitError = nil
                    
                }else{
                    Logger.log("RegisterPushToken: failed ⛔️ + retrying 🔁: \(error)")
                    try? await Task.sleep(nanoseconds: 1_000_0000_000)
                    submitError = error
                }
            }
            
        }while submitError != nil
    }
    
    /// Track event for user.
    func trackEvents(_ events: [UntrackedEvent]) async {
        await trackingEventQueue.push(
            events.map{
                TrackEventModel(
                    organizationUnid: organizationUnid,
                    userID: userID,
                    eventName: $0.eventName,
                    eventTime: $0.date,
                    data: $0.attributes
                )
            }
        )
        await trackingEventQueue.sendEventsIfNeeded()
    }
}
