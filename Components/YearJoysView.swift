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
    let onBack: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            ScreenHeader(
                title: LocalizedStringResource(stringLiteral: String(year)),
                leftButton: {
                    NavigationIconButton(
                        systemImage: "chevron.left",
                        accessibilityLabel: "Back",
                        accessibilityID: "YearJoysBackButton",
                        action: onBack
                    )
                }
            )
            .scrollHeaderBackground()

            ScrollView(showsIndicators: false) {
                JoysListView(range: .year, year: year)
                    .padding(.top, 18)
                    .padding(.horizontal, 10)
                    .padding(.bottom, 30)
            }
            .scrollsUnderHeader()
            .ignoresSafeArea(.container, edges: .bottom)
        }
        .transition(.move(edge: .trailing).combined(with: .opacity))
    }
}

#if DEBUG
#Preview {
    YearJoysView(year: Calendar.current.component(.year, from: Date()), onBack: {})
        .previewEnvironment()
}
#endif
