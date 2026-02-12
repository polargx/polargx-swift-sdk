import Foundation

#if canImport(PolarGXCore)
@_exported import PolarGXCore
#endif

actor ThSVariable<T> {
    private(set) var value: T
    
    init(_ value: T) {
        self.value = value
    }
    
    func set(_ value: T) {
        self.value = value
    }
    
    func set(_ newValue: T, if checker: (_ oldValue: T) -> Bool) {
        if checker(self.value) {
            self.value = newValue
        }
    }
}
