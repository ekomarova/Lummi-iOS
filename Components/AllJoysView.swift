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
            ZStack {
                Text("All joys")
                    .font(.lummiFont(size: 20, weight: .bold))
                    .foregroundColor(themeManager.currentTheme.textColor)
                    .frame(maxWidth: .infinity, alignment: .center)

                HStack {
                    Button(
                        action: {
                            withAnimation(.spring(response: 0.35, dampingFraction: 0.82)) {
                                isShowingAllJoys = false
                            }
                        },
                        label: {
                            Circle()
                                .fill(themeManager.currentTheme.textColor.opacity(0.05))
                                .adaptiveGlass(in: Circle())
                                .frame(width: 44, height: 44)
                                .overlay(
                                    Image(systemName: "arrow.left")
                                        .font(.lummiFont(size: 16, weight: .bold))
                                        .foregroundColor(themeManager.currentTheme.textColor)
                                )
                        }
                    )
                    .buttonStyle(.plain)
                    .accessibilityIdentifier("AllJoysBackButton")

                    Spacer()
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 10)

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
