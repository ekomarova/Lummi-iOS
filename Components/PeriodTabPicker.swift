//
//  Required Notice: Copyright Evseniia Komarova (https://github.com/ekomarova)
//
//  Licensed under the PolyForm Noncommercial License 1.0.0.
//  See the LICENSE file in the repository root for full terms.
//  <https://polyformproject.org/licenses/noncommercial/1.0.0>
//

import SwiftUI

// The two top-level tabs shared by Trends and All Joys. Kept separate from `TrendsRange` (the chart calculator's
// own month-vs-year granularity), since picking "All Time" opens a year list rather than a chart directly.
enum PeriodTab: Equatable {
    case month
    case allTime
}

// "Month"/"All Time" capsule switcher used at the top of Trends and All Joys.
struct PeriodTabPicker: View {
    @Environment(ThemeManager.self) private var themeManager
    @Binding var selection: PeriodTab

    var body: some View {
        HStack(spacing: 4) {
            tabPill(title: "Month", tab: .month)
            tabPill(title: "All Time", tab: .allTime)
        }
        .padding(4)
        .cardBackground(Capsule())
    }

    private func tabPill(title: LocalizedStringResource, tab: PeriodTab) -> some View {
        let isSelected = selection == tab
        return Button {
            selection = tab
        } label: {
            Text(title)
                .font(.lummiFont(size: 13, weight: isSelected ? .bold : .regular))
                .foregroundColor(themeManager.currentTheme.textColor.opacity(isSelected ? 1 : 0.5))
                .minimumScaleFactor(0.8)
                .lineLimit(1)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                .background(Capsule().fill(themeManager.currentTheme.textColor.opacity(isSelected ? CardOpacity.fill * 3 : 0)))
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(isSelected ? [.isSelected] : [])
    }
}

#if DEBUG
#Preview {
    PeriodTabPicker(selection: .constant(.month))
        .padding(20)
        .previewEnvironment()
}
#endif
