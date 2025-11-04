import Foundation

/// Purpose: create user if needed by calling UpdateUser api.
/// Manage events since userId to be set and send to backend.
/// One UserSession instance will be created for only one user (userID)
actor UserSession {
    let organizationUnid: String
    let userID: String
    let apiService: APIService
    let trackingStorageURL: URL
    
    private var isValid = true
    
    private var attributes = [String: Any]()
    private var attributesVersion: UInt64 = 0
    private var attributesIsSending = false
    private var scheduledRetryUpdatingUserWorkItem: DispatchWorkItem?
    
    private var pendingRegisterPushToken: (apns: String?, fcm: String?)?
    private var lastRegisteredAPNSToken: String?
    private var lastRegisteredFCMToken: String?

    lazy var trackingEventQueue = TrackingEventQueue(fileUrl: trackingStorageURL, apiService: apiService)
    
    init(organizationUnid: String, userID: String, apiService: APIService, trackingStorageURL: URL) {
        self.organizationUnid = organizationUnid
        self.userID = userID
        self.apiService = apiService
        self.trackingStorageURL = trackingStorageURL
    }
    
    /// Keep all user attributes for next sending. I don't make sure server supports to merging existing user attributes and the new attributues
    /// First setAttributes/user session will be send immediately
    func setAttributes(_ attributes: [String: Any]) {
        guard isValid else { return }
        
        let immediateSend = self.attributesVersion == 0
        self.attributes = self.attributes.merging(attributes, uniquingKeysWith: { $1 })
        self.attributesVersion += 1
        
        Task {
            await startToUpdateUser(immediate: immediateSend)
        }
    }
    
    func setPushToken(apns: String?, fcm: String?) {
        guard isValid else { return }
        Task {
            pendingRegisterPushToken = (apns, fcm)
            await startToRegisterPushToken()
        }
    }
    
    func invalidate() {
        guard isValid else { return }
        isValid = false
        
        Logger.rlog("Invalidate user session: \(userID)")
        
        Task {
            await startToDeregisterPushToken()
        }
    }
    
    private func getAttributes() -> (attributes: [String: Any], version: UInt64) {
        return (attributes, attributesVersion)
    }
    
    /// Sending user attributes and user id to backend. This API call will create an user if need. After succesful, we need to make `trackingEventQueue` to be ready and sending events if needed.
    /// Stop sending retrying process if server retuns status code #403.
    /// Retry when network connection issue, server returns status code #400 ...
    private func startToUpdateUser(immediate: Bool) async {
        //Make sure once startToUpdateUser running per user session
        guard !attributesIsSending else {
            return;
        }
        
        scheduledRetryUpdatingUserWorkItem?.cancel();
        attributesIsSending = true
        
        var waitTime: UInt64 = immediate ? 0 : PolarConstants.DeplayToUpdateProfileDuration
        var retry = false
        var submitError: Error? = nil

        repeat {
            retry = false
            submitError = nil

            do {
                //Delay for collecting enough information - prevent multiple api calls
                //Use the newest attributes at time the API calls.
                //After successful, compare sent attributes version with the newest attributes version to decide run the sending again.
                try? await Task.sleep(nanoseconds: waitTime)
                
                var attributesVersion: UInt64? = nil
                try await apiService.updateUser({ [weak self] in
                    guard let self = self else { throw Errors.unexpectedError() }
                    
                    let (organizationUnid, userID, attributes, version) = await (
                        self.organizationUnid,
                        self.userID,
                        self.attributes,
                        self.attributesVersion
                    )
                    attributesVersion = version
                    return UpdateUserModel(organizationUnid: organizationUnid, userID: userID, data: attributes)
                })
                submitError = nil;
                
                if attributesVersion != self.attributesVersion {
                    waitTime = PolarConstants.DeplayToUpdateProfileDuration;
                    retry = true
                }
                
            }catch let error where error is URLError { //Network error: stop sending, schedule to retry
                Logger.log("UpdateUser: failed ⛔️ + stopped ⛔️: \(error)")
                submitError = error
                scheduleTaskToRetryUpdatingUser(duration: 5_000_000_000) //5s
                retry = false
                
            }catch let error where error is EncodingError { //Encoding error: stop sending, schedule to retry
                Logger.log("UpdateUser: failed ⛔️ + stopped ⛔️: \(error)")
                submitError = error
                scheduleTaskToRetryUpdatingUser(duration: PolarConstants.DeplayToRetryAPIRequestIfServerError) //5m
                retry = false
                
            }catch let error {
                submitError = error

                if error.apiError?.httpStatus == 403 {
                    Logger.rlog("UpdateUser: ⛔️⛔️⛔️ INVALID appId OR apiKey! ⛔️⛔️⛔️")
                    retry = false
                    
                }else{
                    Logger.log("UpdateUser: failed ⛔️ + stopped ⛔️: \(error)")
                    scheduleTaskToRetryUpdatingUser(duration: PolarConstants.DeplayToRetryAPIRequestIfServerError) //5m
                    retry = false
                }
            }
            
        }while retry
        
        if submitError == nil {
            await trackingEventQueue.setReady()
            await trackingEventQueue.sendEventsIfNeeded()
        }
        
        //Mark startToUpdateUser is not running
        attributesIsSending = false
    }
    
    /// Schedule to retry sending events with sepecified time.
    /// If call `startToUpdateUser` during the wait time, `startToUpdateUser` will be continue and cancel this scheduing.
    func scheduleTaskToRetryUpdatingUser(duration: UInt64) {
        let newWorkItem = DispatchWorkItem { [weak self] in
            Task {
                await self?.startToUpdateUser(immediate: false)
            }
        }
        scheduledRetryUpdatingUserWorkItem?.cancel()
        scheduledRetryUpdatingUserWorkItem = newWorkItem
        DispatchQueue.global().asyncAfter(wallDeadline: .now() + Double(duration)/1_000_000_000, execute: newWorkItem)
    }
    
    /// Stop sending retrying process if server retuns status code #403.
    /// Retry when network connection issue, server returns status code #400 ...
    private func startToRegisterPushToken() async {
        var submitError: Error? = nil
        
        repeat {
            submitError = nil
            do {
                let registeringPushToken = self.pendingRegisterPushToken
                if let token = registeringPushToken?.apns {
                    let apns = RegisterAPNSModel(organizationUnid: organizationUnid, userID: userID, deviceToken: token)
                    try await apiService.registerAPNS({ [weak self] in
                        if await self?.isValid == true, let r1 = registeringPushToken, let r2 = await self?.pendingRegisterPushToken, r1 == r2 {
                            return apns
                        }
                        throw CancellationError()
                    })
                    lastRegisteredAPNSToken = token
                    
                }else if let token = registeringPushToken?.fcm {
                    let fcm = RegisterFCMModel(organizationUnid: organizationUnid, userID: userID, fcmToken: token)
                    try await apiService.registerFCM({ [weak self] in
                        if await self?.isValid == true, let r1 = registeringPushToken, let r2 = await self?.pendingRegisterPushToken, r1 == r2 {
                            return fcm
                        }
                        throw CancellationError()
                    })
                    lastRegisteredFCMToken = token
                }
                
                if let r1 = registeringPushToken, let r2 = pendingRegisterPushToken, r1 == r2 {
                    pendingRegisterPushToken = nil
                }
                
                submitError = nil
                
            }catch let error {
                if error.apiError?.httpStatus == 403 {
                    Logger.rlog("RegisterPushToken: ⛔️⛔️⛔️ INVALID appId OR apiKey! ⛔️⛔️⛔️")
                    submitError = nil
                    
                }else if error is EncodingError {
                    Logger.rlog("RegisterPushToken: ⛔️⛔️⛔️ failed + stopped ⛔️: \(error)")
                    submitError = nil
                    
                }else{
                    Logger.log("RegisterPushToken: failed ⛔️ + retrying 🔁: \(error)")
                    try? await Task.sleep(nanoseconds: 5_000_0000_000)
                    submitError = error
                }
            }
            
        }while submitError != nil
        
        if !isValid {
            await startToDeregisterPushToken()
        }
    }
    
    private func startToDeregisterPushToken() async {
        var submitError: Error? = nil
        
        repeat {
            submitError = nil
            do {
                if let token = lastRegisteredAPNSToken {
                    let apns = DeregisterAPNSModel(organizationUnid: organizationUnid, userID: userID, deviceToken: token)
                    try await apiService.deregisterAPNS({apns})
                    lastRegisteredAPNSToken = nil
                    
                }
                
                if let token = lastRegisteredFCMToken {
                    let fcm = DeregisterFCMModel(organizationUnid: organizationUnid, userID: userID, fcmToken: token)
                    try await apiService.deregisterFCM({fcm})
                    lastRegisteredFCMToken = nil
                }
                
            }catch let error {
                if error.apiError?.httpStatus == 403 {
                    Logger.rlog("DeregisterPushToken: ⛔️⛔️⛔️ INVALID appId OR apiKey! ⛔️⛔️⛔️")
                    submitError = nil
                    
                }else if error is EncodingError {
                    Logger.rlog("DeregisterPushToken: ⛔️⛔️⛔️ failed + stopped ⛔️: \(error)")
                    submitError = nil
                    
                }else{
                    Logger.log("DeregisterPushToken: failed ⛔️ + retrying 🔁: \(error)")
                    try? await Task.sleep(nanoseconds: 5_000_0000_000)
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
