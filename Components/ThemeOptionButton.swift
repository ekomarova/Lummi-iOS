//
//  Required Notice: Copyright Evseniia Komarova (https://github.com/ekomarova)
//
//  Licensed under the PolyForm Noncommercial License 1.0.0.
//  See the LICENSE file in the repository root for full terms.
//  <https://polyformproject.org/licenses/noncommercial/1.0.0>
//

import SwiftUI

// Labeled checkmark option used to choose between the light, dark and auto theme in Settings.
struct ThemeOptionButton: View {
    @Environment(ThemeManager.self) private var themeManager

    let title: LocalizedStringResource
    let isSelected: Bool
    let accessibilityID: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 12) {
                Text(title)
                    .lummiScaledFont(size: 16, relativeTo: .callout)
                    .foregroundColor(themeManager.currentTheme.textColor)

                ZStack {
                    Circle()
                        .fill(isSelected ? Color.blue : Color.clear)
                        .overlay(
                            Circle()
                                .stroke(themeManager.currentTheme.textColor.opacity(isSelected ? 0 : 0.3), lineWidth: 1.5)
                        )

                    Image(systemName: "checkmark")
                        .lummiScaledFont(size: 13, weight: .bold, relativeTo: .footnote)
                        .foregroundColor(.white)
                        .opacity(isSelected ? 1 : 0)
                }
                .frame(width: 26, height: 26)
            }
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(.plain)
        .accessibilityIdentifier(accessibilityID)
        .accessibilityValue(isSelected ? Text("Selected") : Text("Unselected"))
    }
}

#if DEBUG
#Preview {
    @Previewable @State var mode = AppearanceMode.dark

    // Same three options as the Settings screen (Light, Dark, Auto). Local state only, so the saved theme stays untouched.
    HStack(spacing: 0) {
        ThemeOptionButton(title: "Light", isSelected: mode == .light, accessibilityID: "PreviewLightThemeButton", action: { mode = .light })
        ThemeOptionButton(title: "Dark", isSelected: mode == .dark, accessibilityID: "PreviewDarkThemeButton", action: { mode = .dark })
        ThemeOptionButton(title: "Auto", isSelected: mode == .auto, accessibilityID: "PreviewAutoThemeButton", action: { mode = .auto })
    }
    .padding()
    .previewEnvironment()
}
#endif
