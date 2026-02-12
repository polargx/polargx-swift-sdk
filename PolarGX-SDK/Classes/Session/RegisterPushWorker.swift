import Foundation

#if canImport(PolarGXCore)
@_exported import PolarGXCore
#endif

actor RegisterPushWorker {
    private let apiService: APIService
    private var pendingRegisterPushToken: RegisterPushModel?
    private(set) var isReady = false
    private(set) var isRunning = false
    
    private var scheduledRetryRegisteringPushTokenWorkItem: DispatchWorkItem?

    init(apiService: APIService) {
        self.apiService = apiService
    }

    func setReady(_ newReady: Bool) {
        self.isReady = newReady
        
        if !newReady {
            scheduledRetryRegisteringPushTokenWorkItem?.cancel()
        }
    }
    
    /// Event still pushed to the queue if queue is not ready.
    func set(_ push: RegisterPushModel) {
        pendingRegisterPushToken = push
    }
    
    func startToRegisterPushToken() async {
        guard isReady && !isRunning else {
            return
        }
        
        scheduledRetryRegisteringPushTokenWorkItem?.cancel()
        isRunning = true
        
        var retry: Bool
        repeat {
            retry = false
            
            do {
                var registeringPushToken: RegisterPushModel? = nil
                try await apiService.registerPushToken { [weak self] in
                    if await self?.isReady == true, let pushToken = await self?.pendingRegisterPushToken {
                        registeringPushToken = pushToken
                        return pushToken
                    }
                    throw CancellationError()
                }
                
                if let r1 = registeringPushToken, let r2 = pendingRegisterPushToken, r1.platform == r2.platform, r1.token == r2.token {
                    pendingRegisterPushToken = nil
                }
                
                retry = pendingRegisterPushToken != nil
                
            }catch let error where error is CancellationError {
                retry = false
                
            }catch let error where error is URLError { //Network error: stop sending, schedule to retry
                Logger.log("RegisterPush: failed ⛔️ + stopped ⛔️: \(error)")
                scheduleTaskToRetryRegisterPushToken(duration: 5_000_000_000) //5s
                retry = false
                
            }catch let error where error is EncodingError { //Encoding error: stop sending, schedule to retry
                Logger.log("RegisterPush: failed ⛔️ + stopped ⛔️: \(error)")
                scheduleTaskToRetryRegisterPushToken(duration: PolarConstants.DeplayToRetryAPIRequestIfServerError) //5m
                retry = false
                
            }catch let error {
                Logger.log("RegisterPush: failed ⛔️ + stopped ⛔️: \(error)")
                scheduleTaskToRetryRegisterPushToken(duration: PolarConstants.DeplayToRetryAPIRequestIfServerError) //5m
                retry = false
            }
            
        }while retry
        
        isRunning = false
    }
    
    /// Schedule to retry sending events with sepecified time.
    /// If call `startToUpdateUser` during the wait time, `startToUpdateUser` will be continue and cancel this scheduing.
    func scheduleTaskToRetryRegisterPushToken(duration: UInt64) {
        let newWorkItem = DispatchWorkItem { [weak self] in
            Task {
                await self?.startToRegisterPushToken()
            }
        }
        scheduledRetryRegisteringPushTokenWorkItem?.cancel()
        scheduledRetryRegisteringPushTokenWorkItem = newWorkItem
        DispatchQueue.global().asyncAfter(wallDeadline: .now() + Double(duration)/1_000_000_000, execute: newWorkItem)
    }
}
