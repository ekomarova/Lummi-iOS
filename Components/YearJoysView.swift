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
        ScrollView(showsIndicators: false) {
            JoysListView(range: .year, year: year)
                .padding(.top, 18)
                .padding(.horizontal, 20)
                .padding(.bottom, 30)
        }
        .ignoresSafeArea(.container, edges: .bottom)
        .lummiNavigationTitle(LocalizedStringResource(stringLiteral: String(year)))
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
