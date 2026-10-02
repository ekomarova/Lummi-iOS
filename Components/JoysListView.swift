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
// Shared by All Joys' "Month" tab and each year's page, so both list entries identically.
struct JoysListView: View {
    // Only the entries of the window, fetched by the store instead of filtered from the whole journal.
    @Query private var entries: [JoyEntry]

    init(range: Range<Date>?) {
        _entries = Query(filter: JoyEntry.predicate(in: range), sort: \JoyEntry.date, order: .reverse)
    }

    var body: some View {
        if entries.isEmpty {
            NoEntriesView()
        } else {
            LazyVStack(spacing: 12) {
                ForEach(entries) { entry in
                    MonthlyMomentCell(entry: entry)
                }
            }
        }
    }
}

#if DEBUG
#Preview {
    ScrollView {
        JoysListView(range: TrendsCalculator.dateRange(for: .month, year: Calendar.current.component(.year, from: Date())))
    }
    .previewEnvironment()
}
#endif
