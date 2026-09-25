//
//  Copyright (c) 2026, Evseniia Komarova.
//  All rights reserved.
//
//  Licensed under the PolyForm Noncommercial License 1.0.0.
//  See the LICENSE file in the repository root for full terms.
//  <https://polyformproject.org/licenses/noncommercial/1.0.0>
//

import Foundation
import SwiftData

// SwiftData model for a single joy record: its text and the date it was created.
@Model
final class JoyEntry {
    // Unique ID for each record
    var id: UUID = UUID()
    
    // Record text
    @Attribute(.allowsCloudEncryption)
    var text: String = ""
    
    // Date of record creation
    var date: Date = Date()
    
    var dateKey: String { date.stringKey }
    
    init(text: String, date: Date) {
        self.text = text
        self.date = date
    }
}

// Predicates and descriptors that let the store return only the entries a screen needs, instead of
// every entry being loaded and filtered in memory. They read only the stored `date`, so the persisted
// schema stays unchanged.
extension JoyEntry {

    // Entries whose date lies in `range` (start inclusive, end exclusive). A nil range, which happens when
    // the calendar cannot resolve a day or month, matches nothing.
    static func predicate(in range: Range<Date>?) -> Predicate<JoyEntry> {
        guard let range else { return #Predicate<JoyEntry> { _ in false } }
        let start = range.lowerBound
        let end = range.upperBound
        return #Predicate<JoyEntry> { $0.date >= start && $0.date < end }
    }

    static func dayPredicate(for date: Date, calendar: Calendar = .current) -> Predicate<JoyEntry> {
        predicate(in: calendar.dayRange(for: date))
    }

    static func monthPredicate(for date: Date, calendar: Calendar = .current) -> Predicate<JoyEntry> {
        predicate(in: calendar.monthRange(for: date))
    }

    // The single oldest entry, enough to know where the calendar and the Insights month picker start.
    static var oldestEntryDescriptor: FetchDescriptor<JoyEntry> {
        var descriptor = FetchDescriptor<JoyEntry>(sortBy: [SortDescriptor(\.date)])
        descriptor.fetchLimit = 1
        return descriptor
    }
}
