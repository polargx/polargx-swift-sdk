import Foundation

/// Pupurse: fetch events from disk and manage events
actor TrackingEventQueue {
    private let fileUrl: URL
    private let apiService: APIService
    private(set) var events: [TrackEventModel]
    private(set) var isReady = false
    private(set) var isRunning = false
    
    private lazy var encoder = JSONEncoder()
    
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
    func setReady() {
        let wasReady = isReady;
        self.isReady = true
        
        if !wasReady {
            save()
        }
    }
    
    /// Event still pushed to the queue if queue is not ready.
    func push(_ event: TrackEventModel) {
        events.append(event)
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
        
        isRunning = true
        
        while let event = willPop() {
            do {
                try await apiService.trackEvent(event)
                
            }catch let error where error is URLError { //Network error: stop sending, keep elements
                Logger.log("Tracking: failed ⛔️ + stopped ⛔️: \(error)")
                break
                
            }catch let error {
                if let status = error.apiError?.httpStatus, status >= 500 {  //Server error: stop sending, keep elements saved in the disk
                    Logger.log("Tracking: failed ⛔️ + stopped ⛔️: \(error)")
                    break
                }
                
                //Server error: ignore element and send next one.
                Logger.log("Tracking: failed ⛔️ + retry 🔁: \(error)")
            }
            pop()
        }

        isRunning = false
    }
}
