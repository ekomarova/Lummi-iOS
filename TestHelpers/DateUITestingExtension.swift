import Foundation

// Matches the app's own `Date.stringKey` format ("yyyy-MM-dd"); duplicated here since UI tests
// cannot `@testable import` the app target to reuse it directly.
extension Date {
    var uiTestDateKey: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: self)
    }
}
