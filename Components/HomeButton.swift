import SwiftUI

struct HomeButton: View {
    @EnvironmentObject var themeManager: ThemeManager
    let isActive: Bool
    var onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            Image(systemName: isActive ? "house.fill" : "house")
                .font(.lummiFont(size: 25))
                .foregroundColor(themeManager.currentTheme.textColor.opacity(0.8))
                .frame(width: 44, height: 44)
        }
        .buttonStyle(.plain)
        .accessibilityIdentifier(isActive ? "HomeButton_Active" : "HomeButton_Inactive")
    }
}
