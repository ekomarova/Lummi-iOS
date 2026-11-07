//
//  Required Notice: Copyright Evseniia Komarova (https://github.com/ekomarova)
//
//  Licensed under the PolyForm Noncommercial License 1.0.0.
//  See the LICENSE file in the repository root for full terms.
//  <https://polyformproject.org/licenses/noncommercial/1.0.0>
//

import SwiftUI

// A section header with the cards or rows that belong to it, spaced the same way on every screen.
struct SectionBlock<Content: View>: View {
    let title: LocalizedStringResource
    var headerAccessibilityID: String?
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            SectionHeader(title: title)
                .accessibilityIdentifier(headerAccessibilityID ?? "")

            content
        }
    }
}

#if DEBUG
#Preview {
    SectionBlock(title: "Recap") {
        DisclosureRow(title: "Show All Joys", accessibilityID: "SeeAllJoysButton") { }
    }
    .padding(20)
    .previewEnvironment()
}
#endif
