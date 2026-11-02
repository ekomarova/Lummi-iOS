//
//  Required Notice: Copyright Evseniia Komarova (https://github.com/ekomarova)
//
//  Licensed under the PolyForm Noncommercial License 1.0.0.
//  See the LICENSE file in the repository root for full terms.
//  <https://polyformproject.org/licenses/noncommercial/1.0.0>
//

import SwiftUI

// One joy in a list: the day on the left and the entry in a bubble next to it.
struct MonthlyMomentCell: View {
    @Environment(ThemeManager.self) private var themeManager
    @Environment(\.locale) var locale
    let entry: JoyEntry
    // False for all but the latest entry of a day: the date column stays as empty space so the bubbles still align.
    var showsDate = true
    // Grows with the text size, so the two-digit day never gets cut off.
    @ScaledMetric(relativeTo: .body) private var dateColumnWidth: CGFloat = 35

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            dateLabel
                .frame(width: dateColumnWidth)
                .padding(.top, 4)
                .opacity(showsDate ? 1 : 0)
                .accessibilityHidden(!showsDate)

            NoteBubble(sharpCorner: .topLeading) {
                Text(entry.text)
                    .lummiScaledFont(size: 17, relativeTo: .body)
            }
        }
        .padding(.leading, 4)
        .padding(.trailing, 15)
    }

    private var dateLabel: some View {
        VStack(alignment: .center, spacing: 2) {
            Text(entry.date.format("dd", locale: locale))
                .lummiScaledFont(size: 18, relativeTo: .body)
                .foregroundColor(themeManager.currentTheme.textColor)

            Text(entry.date.format("MMM", locale: locale).capitalizedFirstLetter)
                .lummiScaledFont(size: 11, relativeTo: .caption2)
                .foregroundColor(themeManager.currentTheme.secondaryTextColor)
        }
    }
}

#if DEBUG
#Preview {
    VStack(alignment: .leading, spacing: 12) {
        MonthlyMomentCell(entry: JoyEntry(text: "Coffee on the balcony", date: Date()))
        MonthlyMomentCell(entry: JoyEntry(text: "A long walk with music", date: Date()), showsDate: false)
    }
    .previewEnvironment()
}
#endif
