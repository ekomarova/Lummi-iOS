//
//  Copyright (c) 2026, Evseniia Komarova.
//  All rights reserved.
//
//  Licensed under the PolyForm Noncommercial License 1.0.0.
//  See the LICENSE file in the repository root for full terms.
//  <https://polyformproject.org/licenses/noncommercial/1.0.0>
//

import SwiftUI

// One tappable row per calendar year, used by the "All Time" tab of Trends and All Joys.
struct YearsListView: View {
    let years: [Int]
    // Prefix of each row's accessibility identifier; the year is appended, e.g. "TrendsYearRow_2026".
    let accessibilityIDPrefix: String
    let onSelect: (Int) -> Void

    var body: some View {
        VStack(spacing: 12) {
            ForEach(years, id: \.self) { year in
                DisclosureRow(
                    systemImage: "calendar",
                    iconColor: AccentColors.yearRow,
                    title: LocalizedStringResource(stringLiteral: String(year)),
                    accessibilityID: "\(accessibilityIDPrefix)_\(year)"
                ) {
                    onSelect(year)
                }
            }
        }
    }
}

#if DEBUG
#Preview {
    YearsListView(years: [2026, 2025], accessibilityIDPrefix: "PreviewYearRow", onSelect: { _ in })
        .padding(20)
        .previewEnvironment()
}
#endif
