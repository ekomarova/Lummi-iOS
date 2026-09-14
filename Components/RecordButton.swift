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
                    Image(systemName: "star.fill")
                        .font(.lummiFont(size: 43))
                        .foregroundColor(themeManager.currentTheme.bottomPanelStarIconColor)
                        .frame(maxWidth: .infinity, minHeight: 48)
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
