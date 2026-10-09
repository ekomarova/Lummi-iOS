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
enum PeriodTab: Hashable {
    case month
    case allTime
}

// "Month"/"All Time" switcher used at the top of Trends and All Joys. It is the system segmented control, which gets
// the Liquid Glass look on iOS 26.
struct PeriodTabPicker: View {
    @Binding var selection: PeriodTab

    var body: some View {
        Picker(selection: $selection) {
            Text(LocalizedStringResource("Month")).tag(PeriodTab.month)
            Text(LocalizedStringResource("All Time")).tag(PeriodTab.allTime)
        } label: {
            EmptyView()
        }
        .pickerStyle(.segmented)
    }
}

#if DEBUG
#Preview {
    PeriodTabPicker(selection: .constant(.month))
        .padding(20)
        .previewEnvironment()
}
#endif
