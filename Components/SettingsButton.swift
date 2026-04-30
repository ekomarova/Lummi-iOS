import SwiftUI

struct SettingsButton: View {
    @EnvironmentObject var themeManager: ThemeManager
    var isActive: Bool
    var onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            Image(systemName: isActive ? "gearshape.fill" : "gearshape")
                .font(.lummiFont(size: 27))
                .foregroundColor(themeManager.currentTheme.textColor.opacity(0.8))
                .frame(width: 44, height: 44)
        }
        .buttonStyle(.plain)
        .accessibilityIdentifier(isActive ? "SettingsButton_Active" : "SettingsButton_Inactive")
    }
}
