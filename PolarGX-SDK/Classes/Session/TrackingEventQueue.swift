import Foundation

#if canImport(PolarGXCore)
@_exported import PolarGXCore
#endif

/// Pupurse: fetch events from disk and manage events
actor TrackingEventQueue {
    private let fileUrl: URL
    private let apiService: APIService
    private(set) var events: [TrackEventModel]
    private(set) var isReady = false
    private(set) var isRunning = false
    
    private lazy var encoder = JSONEncoder()
    
    private var scheduledRetrySendingEventsWorkItem: DispatchWorkItem?
    
    /// Fetch unsent events from fileUrl
    init(fileUrl: URL, apiService: APIService) {
        self.fileUrl = fileUrl
        self.apiService = apiService
        
        do {
            let data = try Data(contentsOf: fileUrl)
            self.events = try JSONDecoder().decode([TrackEventModel].self, from: data)
        }catch _ {
            self.events = []
        }
    }
    
    /// Set isReady flag
    /// If isReady sets  to True, Events will be saved to disk, The queue is ready to send data to backend
    /// If isReady sets to False, Events is not saved to the disk.
    func setReady(_ newReady: Bool) {
        let wasReady = isReady;
        self.isReady = newReady
        
        if !wasReady {
            save()
        }
    }
    
    /// Event still pushed to the queue if queue is not ready.
    func push(_ newEvents: [TrackEventModel]) {
        events.append(contentsOf: newEvents)
        save()
    }
    
    private func willPop() -> TrackEventModel? {
        events.first
    }
    
    private func pop() {
        if !events.isEmpty {
            events.removeFirst()
            save()
        }
    }
    
    private func save() {
        guard isReady else { return }
        
        do {
            let data = try encoder.encode(events)
            try data.write(to: fileUrl, options: .atomic)
        }catch let error {
            assertionFailure("??? \(error)")
        }
    }
    
    /// Sending Event progress, Only one progress need to be ran at the time.
    func sendEventsIfNeeded() async {
        guard isReady && !isRunning else {
            return
        }
        
        scheduledRetrySendingEventsWorkItem?.cancel()
        isRunning = true
        
        while let event = willPop() {
            do {
                try await apiService.trackEvent(event)
                pop()
                
            }catch let error where error is URLError { //Network error: stop sending, schedule to retry
                Logger.log("Tracking: failed ⛔️ + stopped ⛔️: \(error)")
                scheduleTaskToRetrySendingEvents(duration: 5_000_000_000) //5s
                break
                
            }catch let error where error is EncodingError { //Encoding error: stop sending, schedule to retry
                Logger.log("Tracking: failed ⛔️ + stopped ⛔️: \(error)")
                scheduleTaskToRetrySendingEvents(duration: PolarConstants.DeplayToRetryAPIRequestIfServerError) //5m
                break
                
            }catch let error {
                Logger.log("Tracking: failed ⛔️ + stopped ⛔️: \(error)")
                scheduleTaskToRetrySendingEvents(duration: PolarConstants.DeplayToRetryAPIRequestIfServerError) //5m
                break
            }
        }

        isRunning = false
    }
    
    /// Schedule to retry sending events with sepecified time.
    /// If call `sendEventsIfNeeded` during the wait time, `sendEventsIfNeeded` will be continue and cancel this scheduing.
    func scheduleTaskToRetrySendingEvents(duration: UInt64) {
        let newWorkItem = DispatchWorkItem { [weak self] in
            Task {
                await self?.sendEventsIfNeeded()
            }
        }
        scheduledRetrySendingEventsWorkItem?.cancel()
        scheduledRetrySendingEventsWorkItem = newWorkItem
        DispatchQueue.global().asyncAfter(wallDeadline: .now() + Double(duration)/1_000_000_000 + 0.1, execute: newWorkItem)
    }
}
