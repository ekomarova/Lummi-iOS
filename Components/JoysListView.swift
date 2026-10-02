//
//  Copyright (c) 2026, Evseniia Komarova.
//  All rights reserved.
//
//  Licensed under the PolyForm Noncommercial License 1.0.0.
//  See the LICENSE file in the repository root for full terms.
//  <https://polyformproject.org/licenses/noncommercial/1.0.0>
//

import SwiftUI
import SwiftData

// Every joy inside a date window, newest first; the "no entries" placeholder when the window is empty.
// Shared by All Joys' "Month" tab and each year's page, so both list entries identically. Only the latest entry
// of each day carries the date; the rest of that day's entries line up beneath it without one.
struct JoysListView: View {
    // Only the entries of `range`, fetched by the store instead of filtered from the whole journal.
    @Query private var entries: [JoyEntry]

    // `year` is ignored for `.month`, which always covers the current calendar month. `now` is taken once here,
    // like `TrendsChartsView`, so the window is computed in this `init` and not in every parent `body`.
    init(range: TrendsRange, year: Int) {
        _entries = Query(
            filter: JoyEntry.predicate(in: TrendsCalculator.dateRange(for: range, year: year, now: Date())),
            sort: \JoyEntry.date,
            order: .reverse
        )
    }

    var body: some View {
        if entries.isEmpty {
            NoEntriesView()
        } else {
            LazyVStack(spacing: 12) {
                ForEach(Array(entries.enumerated()), id: \.element.id) { index, entry in
                    MonthlyMomentCell(
                        entry: entry,
                        showsDate: Self.showsDate(for: entry.date, after: index > 0 ? entries[index - 1].date : nil)
                    )
                }
            }
        }
    }

    // The list is newest first, so an entry is its day's latest exactly when the entry above it falls on another day
    // (or it is the first one). Checked per cell, so a lazily rendered long list only compares what is on screen.
    static func showsDate(for date: Date, after previousDate: Date?, calendar: Calendar = .current) -> Bool {
        guard let previousDate else { return true }
        return !calendar.isDate(date, inSameDayAs: previousDate)
    }
}

#if DEBUG
#Preview {
    ScrollView {
        JoysListView(range: .month, year: Calendar.current.component(.year, from: Date()))
    }
    .previewEnvironment()
}
#endif
