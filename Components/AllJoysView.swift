//
//  Copyright (c) 2026, Evseniia Komarova.
//  All rights reserved.
//
//  Licensed under the PolyForm Noncommercial License 1.0.0.
//  See the LICENSE file in the repository root for full terms.
//  <https://polyformproject.org/licenses/noncommercial/1.0.0>
//

import SwiftUI

struct AllJoysView: View {
    @Environment(ThemeManager.self) private var themeManager
    let entries: [JoyEntry]
    @Binding var isShowingAllJoys: Bool

    var body: some View {
        VStack(spacing: 0) {
            ScreenHeader(
                title: "All joys",
                leftButton: {
                    NavigationIconButton(systemImage: "arrow.left", accessibilityID: "AllJoysBackButton") {
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.82)) {
                            isShowingAllJoys = false
                        }
                    }
                }
            )

            ScrollView(showsIndicators: false) {
                VStack(spacing: 12) {
                    ForEach(entries.sorted(by: { $0.date > $1.date })) { entry in
                        MonthlyMomentCell(entry: entry)
                    }
                }
                .padding(.top, 30)
                .padding(.horizontal, 10)
                .padding(.bottom, 100)
            }
            .ignoresSafeArea(.container, edges: .bottom)
        }
        .transition(.move(edge: .trailing).combined(with: .opacity))
    }
}

#if DEBUG
#Preview {
    AllJoysView(entries: [JoyEntry(text: "Coffee on the balcony", date: Date())], isShowingAllJoys: .constant(true))
        .previewEnvironment()
}
#endif
