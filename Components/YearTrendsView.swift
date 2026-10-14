//
//  Required Notice: Copyright Evseniia Komarova (https://github.com/ekomarova)
//
//  Licensed under the PolyForm Noncommercial License 1.0.0.
//  See the LICENSE file in the repository root for full terms.
//  <https://polyformproject.org/licenses/noncommercial/1.0.0>
//

import SwiftUI

// One calendar year's trends, opened by tapping a year in Trends' "All Time" list.
struct YearTrendsView: View {
    let year: Int

    var body: some View {
        ScrollView(showsIndicators: false) {
            TrendsChartsView(range: .year, year: year)
                .padding(.horizontal, 20)
                .padding(.top, 13)
                .padding(.bottom, 30)
        }
        .ignoresSafeArea(.container, edges: .bottom)
        .lummiNavigationTitle(LocalizedStringResource(stringLiteral: String(year)))
    }
}

#if DEBUG
#Preview {
    NavigationStack {
        YearTrendsView(year: Calendar.current.component(.year, from: Date()))
    }
    .previewEnvironment()
}
#endif
