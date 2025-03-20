import Foundation

actor TrackingEventQueue {
    private let fileUrl: URL
    private let apiService: APIService
    private var events: [TrackEventModel]
    private(set) var isReady = false
    private(set) var isRunning = false
    
    private lazy var encoder = JSONEncoder()
    
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
    
    func setReady() {
        let wasReady = isReady;
        self.isReady = true
        
        if !wasReady {
            save()
        }
    }
    
    func setRunning(_ isRunning: Bool) {
        self.isRunning = isRunning
    }
    
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
                if let status = error.apiError?.httpStatus, status >= 500 {  //Server error: stop sending, keep elements
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
