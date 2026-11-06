//
//  Required Notice: Copyright Evseniia Komarova (https://github.com/ekomarova)
//
//  Licensed under the PolyForm Noncommercial License 1.0.0.
//  See the LICENSE file in the repository root for full terms.
//  <https://polyformproject.org/licenses/noncommercial/1.0.0>
//

import SwiftUI

// Frame of a tab's root page: a title that stays above the content, and the content below it.
// With `scrolls` the content sits in a ScrollView that runs under the tab bar; without it the content manages its own
// scrolling (Home's list of entries).
struct TabPage<Header: View, Content: View>: View {
    private let scrolls: Bool
    private let header: Header
    private let content: Content

    init(scrolls: Bool = true, @ViewBuilder header: () -> Header, @ViewBuilder content: () -> Content) {
        self.scrolls = scrolls
        self.header = header()
        self.content = content()
    }

    var body: some View {
        // The title's protected zone takes 12pt of the old 20pt gap (see `scrollHeaderBackground`).
        VStack(alignment: .leading, spacing: 8) {
            header
                .scrollHeaderBackground(alignment: .leading)

            if scrolls {
                ScrollView(showsIndicators: false) {
                    content
                        .padding(.horizontal, 20)
                        .padding(.bottom, 100)
                }
                .scrollClipDisabled()
                .ignoresSafeArea(.container, edges: .bottom)
            } else {
                content
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

extension TabPage where Header == TabPageTitle {
    // A scrolling page with a localized title.
    init(title: LocalizedStringResource, @ViewBuilder content: () -> Content) {
        self.init(header: { TabPageTitle(title) }, content: content)
    }
}

#if DEBUG
#Preview {
    TabPage(title: "Insights") {
        VStack(alignment: .leading, spacing: 15) {
            SectionHeader(title: "Highlights")
            ForEach(0..<20, id: \.self) { index in
                CapsuleRow { Text(verbatim: "Row \(index)") }
            }
        }
    }
    .previewEnvironment()
}
#endif
