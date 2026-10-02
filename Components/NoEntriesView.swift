//
//  Copyright (c) 2026, Evseniia Komarova.
//  All rights reserved.
//
//  Licensed under the PolyForm Noncommercial License 1.0.0.
//  See the LICENSE file in the repository root for full terms.
//  <https://polyformproject.org/licenses/noncommercial/1.0.0>
//

import SwiftUI

// Placeholder shown in place of a tab's or year's content when it has no entries, matching
// `SelectedDayDetailView`'s "No records for this day" placeholder.
struct NoEntriesView: View {
    @Environment(ThemeManager.self) private var themeManager

    var body: some View {
        Text("Add at least one joy")
            .font(.lummiFont(size: 16))
            .foregroundColor(themeManager.currentTheme.textColor.opacity(0.3))
            .frame(maxWidth: .infinity)
            .padding(.top, 40)
    }
}

#if DEBUG
#Preview {
    NoEntriesView()
        .previewEnvironment()
}
#endif
