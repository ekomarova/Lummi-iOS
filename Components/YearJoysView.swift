//
//  Required Notice: Copyright Evseniia Komarova (https://github.com/ekomarova)
//
//  Licensed under the PolyForm Noncommercial License 1.0.0.
//  See the LICENSE file in the repository root for full terms.
//  <https://polyformproject.org/licenses/noncommercial/1.0.0>
//

import SwiftUI

// Every joy of one calendar year, opened by tapping a year in All Joys' "All Time" list.
struct YearJoysView: View {
    let year: Int

    var body: some View {
        YearPage(year: year, top: PageSpacing.topBelowList) {
            JoysListView(range: .year(year))
        }
    }
}

#if DEBUG
#Preview {
    NavigationStack {
        YearJoysView(year: Calendar.current.component(.year, from: Date()))
    }
    .previewEnvironment()
}
#endif
