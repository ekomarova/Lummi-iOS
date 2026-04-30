import Foundation
import SwiftData

@Model
final class JoyEntry {
    // Unic ID for each record
    var id: UUID = UUID()
    
    // Record text
    var text: String = ""
    
    // Date of record creation
    var date: Date = Date()
    
    // String key
    var dateKey: String = ""
    
    init(text: String, date: Date, dateKey: String) {
        self.text = text
        self.date = date
        self.dateKey = dateKey
    }
}
