//
//  Copyright (c) 2026, Evseniia Komarova.
//  All rights reserved.
//
//  Licensed under the PolyForm Noncommercial License 1.0.0.
//  See the LICENSE file in the repository root for full terms.
//  <https://polyformproject.org/licenses/noncommercial/1.0.0>
//

import SwiftUI

// One calendar year's trends, opened by tapping a year in Trends' "All Time" list.
struct YearTrendsView: View {
    let year: Int
    let onBack: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            ScreenHeader(
                title: LocalizedStringKey(String(year)),
                leftButton: {
                    NavigationIconButton(systemImage: "arrow.left", accessibilityID: "YearTrendsBackButton", action: onBack)
                }
            )

            ScrollView(showsIndicators: false) {
                TrendsChartsView(range: .year, year: year)
                    .padding(.horizontal, 20)
                    .padding(.top, 25)
                    .padding(.bottom, 30)
            }
            .ignoresSafeArea(.container, edges: .bottom)
        }
        .transition(.move(edge: .trailing).combined(with: .opacity))
    }
}

#if DEBUG
#Preview {
    YearTrendsView(year: Calendar.current.component(.year, from: Date()), onBack: {})
        .previewEnvironment()
}
#endif
