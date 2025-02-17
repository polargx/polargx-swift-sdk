import Foundation

actor TrackingEventQueue {
    private var fileUrl: URL
    private var events: [TrackEventModel]
    private(set) var trackingQueueIsRunning: Bool? = false
    
    private lazy var encoder = JSONEncoder()
    
    init(fileUrl: URL) {
        self.fileUrl = fileUrl
        do {
            let data = try Data(contentsOf: fileUrl)
            self.events = try JSONDecoder().decode([TrackEventModel].self, from: data)
        }catch let error {
            self.events = []
        }
    }
    
    func setTrackingQueueIsRunning(_ isRunning: Bool?) {
        trackingQueueIsRunning = isRunning
    }
    
    func push(_ event: TrackEventModel) {
        events.append(event)
        save()
    }
    
    func willPop() -> TrackEventModel? {
        events.first
    }
    
    func pop() {
        if !events.isEmpty {
            events.removeFirst()
            save()
        }
    }
    
    private func save() {
        do {
            let data = try encoder.encode(events)
            try data.write(to: fileUrl, options: .atomic)
        }catch let error {
            assertionFailure("???")
        }
    }
}
