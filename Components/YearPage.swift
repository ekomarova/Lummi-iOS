//
//  Required Notice: Copyright Evseniia Komarova (https://github.com/ekomarova)
//
//  Licensed under the PolyForm Noncommercial License 1.0.0.
//  See the LICENSE file in the repository root for full terms.
//  <https://polyformproject.org/licenses/noncommercial/1.0.0>
//

import SwiftUI

// A pushed page for one calendar year, titled with the year. `YearJoysView` and `YearTrendsView` differ only in
// what they show.
struct YearPage<Content: View>: View {
    let year: Int
    // Space above the content, from `PageSpacing`.
    let top: CGFloat
    @ViewBuilder let content: Content

    var body: some View {
        PushedScrollPage(title: LocalizedStringResource(stringLiteral: String(year)), top: top) {
            content
                .padding(.horizontal, 20)
        }
    }
}

#if DEBUG
#Preview {
    NavigationStack {
        YearPage(year: Calendar.current.component(.year, from: Date()), top: PageSpacing.topBelowList) {
            CapsuleRow { Text(verbatim: "Content") }
        }
    }
    .previewEnvironment()
}
#endif
