//
//  Required Notice: Copyright Evseniia Komarova (https://github.com/ekomarova)
//
//  Licensed under the PolyForm Noncommercial License 1.0.0.
//  See the LICENSE file in the repository root for full terms.
//  <https://polyformproject.org/licenses/noncommercial/1.0.0>
//

import SwiftUI

// Single day in the calendar grid, with a star when the day has entries and a stronger color for today.
struct DayCell: View {
    @Environment(ThemeManager.self) private var themeManager
    static let height: CGFloat = 34

    let day: Int
    let isFilled: Bool
    let isToday: Bool
    let dateKey: String
    
    var body: some View {
        ZStack {
            VStack(spacing: 2) {
                if isFilled {
                    Image(systemName: "star.fill")
                        .font(.system(size: 8, weight: .bold))
                        .foregroundColor(themeManager.currentTheme.dayFilledColor)
                        .frame(width: 12, height: 12)
                } else {
                    Color.clear
                        .frame(width: 12, height: 12)
                }

                Text("\(day)")
                    .font(.lummiFont(size: 14))
                    .foregroundColor(
                        isToday ? themeManager.currentTheme.textColor :
                            (isFilled ? themeManager.currentTheme.dayFilledColor :
                                themeManager.currentTheme.textColor
                                .opacity(themeManager.currentTheme.inactiveOpacity))
                    )
            }
        }
        .frame(height: Self.height)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(day)")
        .accessibilityIdentifier("DayCell_\(dateKey)")
        .accessibilityValue(isFilled ? Text("Filled") : Text("Empty"))
    }
}

#if DEBUG
#Preview {
    HStack {
        DayCell(day: 12, isFilled: true, isToday: false, dateKey: "2026-03-12")
        DayCell(day: 13, isFilled: false, isToday: true, dateKey: "2026-03-13")
    }
    .previewEnvironment()
}
#endif
