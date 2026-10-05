//
//  Required Notice: Copyright Evseniia Komarova (https://github.com/ekomarova)
//
//  Licensed under the PolyForm Noncommercial License 1.0.0.
//  See the LICENSE file in the repository root for full terms.
//  <https://polyformproject.org/licenses/noncommercial/1.0.0>
//

import SwiftUI

// Full-width capsule row with a subtle fill and border, used for Settings rows and the "Show All Joys" button
struct CapsuleRow<Content: View>: View {
    @ViewBuilder var content: () -> Content

    var body: some View {
        content()
            .frame(maxWidth: .infinity, minHeight: 31, alignment: .leading)
            .padding(.horizontal, 20)
            .padding(.vertical, 14)
            .cardBackground(Capsule())
    }
}

// Capsule-shaped row with an optional leading icon, a title and a trailing chevron ("disclosure
// indicator"), used for list-style navigation entries in Insights, Trends and Settings. Built on
// top of `CapsuleRow` above, not a reimplementation of it.
struct DisclosureRow: View {
    @Environment(ThemeManager.self) private var themeManager

    var systemImage: String?
    var iconColor: Color = .clear
    let title: LocalizedStringResource
    let accessibilityID: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            CapsuleRow {
                HStack(spacing: 10) {
                    if let systemImage {
                        Image(systemName: systemImage)
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundColor(iconColor)
                    }

                    Text(title)
                        .font(.lummiFont(size: 17))
                        .foregroundColor(themeManager.currentTheme.textColor)

                    Spacer()

                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(themeManager.currentTheme.textColor.opacity(0.6))
                }
            }
        }
        .buttonStyle(.plain)
        .accessibilityIdentifier(accessibilityID)
    }
}

#if DEBUG
private struct CapsuleRowPreview: View {
    @Environment(ThemeManager.self) private var themeManager

    var body: some View {
        VStack(spacing: 12) {
            CapsuleRow {
                Text("Delete")
            }
            DisclosureRow(
                systemImage: "list.star",
                iconColor: AccentColors.activeDays,
                title: "Show All Joys",
                accessibilityID: "PreviewWithIcon",
                action: { }
            )
            DisclosureRow(title: "English", accessibilityID: "PreviewWithoutIcon", action: { })
        }
        .font(.lummiFont(size: 17))
        .foregroundColor(themeManager.currentTheme.textColor)
        .padding(.horizontal, 20)
    }
}

#Preview {
    CapsuleRowPreview()
        .previewEnvironment()
}
#endif
