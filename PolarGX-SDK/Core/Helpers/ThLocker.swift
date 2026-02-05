import Foundation

actor ThLocker {
    private var isLocked = false
    private var continuations: [CheckedContinuation<Void, Never>] = []
    
    /// Wait until the locker is unlocked
    func waitForUnlock() async {
        guard isLocked else { return }
        
        await withCheckedContinuation { continuation in
            continuations.append(continuation)
        }
    }
    
    /// Unlock and resume all waiting tasks
    func unlock() {
        guard isLocked else { return }
        isLocked = false
        
        // Resume all waiting continuations
        for continuation in continuations {
            continuation.resume()
        }
        continuations.removeAll()
    }
    
    /// Lock again (if needed)
    func lock() {
        isLocked = true
    }
    
    /// Check if currently locked
    var locked: Bool {
        isLocked
    }
}
