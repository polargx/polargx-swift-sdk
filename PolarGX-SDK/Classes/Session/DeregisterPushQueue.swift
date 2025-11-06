import Foundation

/// Pupurse: fetch events from disk and manage events
actor DeregisterPushQueue {
    private let fileUrl: URL
    private let apiService: APIService
    private let organizationUnid: String
    private(set) var userUnids: [String]
    private(set) var pushToken: PushToken?
    private(set) var isRunning = false
    
    private var isReady: Bool { pushToken != nil }

    private lazy var encoder = JSONEncoder()
    
    private var appBundleId: String?
    
    private var scheduledRetryDeregisteringPushWorkItem: DispatchWorkItem?
    
    /// Fetch underegistered userUnids from fileUrl
    init(organizationUnid: String, fileUrl: URL, apiService: APIService) {
        self.organizationUnid = organizationUnid
        self.fileUrl = fileUrl
        self.apiService = apiService
        
        do {
            let data = try Data(contentsOf: fileUrl)
            self.userUnids = try JSONDecoder().decode([String].self, from: data)
        }catch _ {
            self.userUnids = []
        }
    }
    
    func setPushToken(_ pushToken: PushToken) {
        self.pushToken = pushToken
        Task {
            await startDeregisteringPushIfNeeded()
        }
    }
    
    func push(_ userUnid: String) {
        userUnids.append(userUnid)
        save()
    }
    
    private func willPop() -> String? {
        userUnids.first
    }
    
    private func pop() {
        if !userUnids.isEmpty {
            userUnids.removeFirst()
            save()
        }
    }
    
    private func save() {
        do {
            let data = try encoder.encode(userUnids)
            try data.write(to: fileUrl, options: .atomic)
        }catch let error {
            assertionFailure("??? \(error)")
        }
    }
    
    /// Sending Event progress, Only one progress need to be ran at the time.
    func startDeregisteringPushIfNeeded() async {
        guard isReady, !isRunning, let pushToken = pushToken else {
            return
        }
        
        scheduledRetryDeregisteringPushWorkItem?.cancel()
        isRunning = true

        if appBundleId == nil  {
            appBundleId = await SystemInfo.appBundleId
        }
        let bundleId = appBundleId ?? ""
        let sandbox = await SystemInfo.isAPSSandBox
        
        while let userUnid = willPop() {
            do {
                let registerPush = RegisterPushModel(
                    organizationUnid: organizationUnid,
                    userUnid: userUnid,
                    bundleID: bundleId,
                    sandbox: sandbox,
                    pushToken: pushToken,
                    data: [:]
                )
                try await apiService.deregisterPushToken(registerPush)
                pop()
                
            }catch let error where error is URLError { //Network error: stop sending, schedule to retry
                Logger.log("Tracking: failed ⛔️ + stopped ⛔️: \(error)")
                scheduleTaskToRetryDeregisteringPush(duration: 5_000_000_000) //5s
                break
                
            }catch let error where error is EncodingError { //Encoding error: stop sending, schedule to retry
                Logger.log("Tracking: failed ⛔️ + stopped ⛔️: \(error)")
                scheduleTaskToRetryDeregisteringPush(duration: PolarConstants.DeplayToRetryAPIRequestIfServerError) //5m
                break
                
            }catch let error {
                Logger.log("Tracking: failed ⛔️ + stopped ⛔️: \(error)")
                scheduleTaskToRetryDeregisteringPush(duration: PolarConstants.DeplayToRetryAPIRequestIfServerError) //5m
                break
            }
        }

        isRunning = false
    }
    
    /// Schedule to retry sending events with sepecified time.
    /// If call `sendEventsIfNeeded` during the wait time, `sendEventsIfNeeded` will be continue and cancel this scheduing.
    func scheduleTaskToRetryDeregisteringPush(duration: UInt64) {
        let newWorkItem = DispatchWorkItem { [weak self] in
            Task {
                await self?.startDeregisteringPushIfNeeded()
            }
        }
        scheduledRetryDeregisteringPushWorkItem?.cancel()
        scheduledRetryDeregisteringPushWorkItem = newWorkItem
        DispatchQueue.global().asyncAfter(wallDeadline: .now() + Double(duration)/1_000_000_000 + 0.1, execute: newWorkItem)
    }
}
