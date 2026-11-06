//
//  Required Notice: Copyright Evseniia Komarova (https://github.com/ekomarova)
//
//  Licensed under the PolyForm Noncommercial License 1.0.0.
//  See the LICENSE file in the repository root for full terms.
//  <https://polyformproject.org/licenses/noncommercial/1.0.0>
//

import SwiftUI
import SwiftData

// The calendar years on record as tappable rows, or the empty state when the journal has no entries. Owns the query,
// so the "All Time" tab of All Joys and Trends do not each repeat it.
struct YearsListSection: View {
    // Prefix of each row's accessibility identifier, see `YearsListView`.
    let accessibilityIDPrefix: String
    // Opens a year's page on the tab's stack.
    let onOpenYear: (Int) -> Void

    // A single-entry fetch instead of every entry: the oldest one gives the year list and tells whether the journal
    // is empty.
    @Query(JoyEntry.oldestEntryDescriptor) private var oldestEntries: [JoyEntry]

    private var availableYears: [Int] {
        TrendsCalculator.availableYears(oldestEntryDate: oldestEntries.first?.date)
    }

    var body: some View {
        if oldestEntries.isEmpty {
            NoEntriesView()
        } else {
            YearsListView(years: availableYears, accessibilityIDPrefix: accessibilityIDPrefix, onSelect: onOpenYear)
                .padding(.horizontal, 20)
        }
    }
}

#if DEBUG
#Preview {
    YearsListSection(accessibilityIDPrefix: "PreviewYearRow", onOpenYear: { _ in })
        .previewEnvironment()
}
#endif
