//
//  Copyright (c) 2026, Evseniia Komarova.
//  All rights reserved.
//
//  Licensed under the PolyForm Noncommercial License 1.0.0.
//  See the LICENSE file in the repository root for full terms.
//  <https://polyformproject.org/licenses/noncommercial/1.0.0>
//

import SwiftUI

struct RecordButton: View {
    @Environment(ThemeManager.self) private var themeManager

    let selectedDate: Date?
    var onTap: () -> Void

    var body: some View {
        Group {
            if selectedDate != nil {
                Button(action: onTap) {
                    let size: CGFloat = 64

                    Circle()
                        .fill(themeManager.currentTheme.recordButtonColor.opacity(0.35))
                        .glassEffect(.clear.interactive(), in: Circle())
                        .frame(width: size, height: size)
                        .overlay(
                            Image(systemName: "plus")
                                .font(.lummiFont(size: 20, scaled: false))
                                .foregroundColor(themeManager.currentTheme.textColor)
                        )
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Record the joy")
                .accessibilityIdentifier("MainRecordButton")
            } else {
                EmptyView()
            }
        }
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: selectedDate)
    }
}
