//
// Helper for working with dates
//

import Foundation

extension Date {
    // Converts the date to a unique key string "yyyy-MM-dd"
    var stringKey: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: self)
    }
    
    // Get the beginning of the month for a specific date
    var startOfMonth: Date {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month], from: self)
        return calendar.date(from: components) ?? self
    }
    
    //  Get the previous month
    func previousMonth() -> Date {
        return Calendar.current.date(byAdding: .month, value: -1, to: self) ?? self
    }
}
