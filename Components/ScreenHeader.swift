//
//  Copyright (c) 2026, Evseniia Komarova.
//  All rights reserved.
//
//  Licensed under the PolyForm Noncommercial License 1.0.0.
//  See the LICENSE file in the repository root for full terms.
//  <https://polyformproject.org/licenses/noncommercial/1.0.0>
//

import SwiftUI

// Header with a centered title and optional left/right buttons
struct ScreenHeader<Left: View, Right: View>: View {
    @Environment(ThemeManager.self) private var themeManager

    let title: LocalizedStringKey
    @ViewBuilder var leftButton: () -> Left
    @ViewBuilder var rightButton: () -> Right

    var body: some View {
        ZStack {
            Text(title)
                .font(.lummiFont(size: 20, weight: .bold))
                .foregroundColor(themeManager.currentTheme.textColor)
                .frame(maxWidth: .infinity, alignment: .center)

            HStack {
                leftButton()
                Spacer()
                rightButton()
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 10)
    }
}

extension ScreenHeader where Right == EmptyView {
    init(title: LocalizedStringKey, @ViewBuilder leftButton: @escaping () -> Left) {
        self.init(title: title, leftButton: leftButton, rightButton: { EmptyView() })
    }
}

#if DEBUG
#Preview {
    ScreenHeader(
        title: "New Joy",
        leftButton: { NavigationIconButton(systemImage: "chevron.left", accessibilityID: "PreviewBack", action: { }) },
        rightButton: { NavigationIconButton(systemImage: "checkmark", accessibilityID: "PreviewSave", action: { }) }
    )
    .previewEnvironment()
}
#endif
