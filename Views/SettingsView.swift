import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var themeManager: ThemeManager

    var body: some View {
        VStack(alignment: .leading, spacing: 30) {
            Text("Settings")
                .textCase(.uppercase)
                .font(.lummiFont(size: 24))
                .foregroundColor(themeManager.currentTheme.textColor)
                .padding(.top, 10)

            HStack {
                Text("Appearance")
                    .textCase(.uppercase)
                    .font(.lummiFont(size: 18))
                    .foregroundColor(themeManager.currentTheme.textColor)
                
                Spacer()
                
                HStack(spacing: 0) {
                    CompactThemeButton(
                        title: "Light",
                        icon: "sun.max.fill",
                        isSelected: !themeManager.isDark,
                        action: { withAnimation(.spring()) { themeManager.isDark = false } }
                    )
                    
                    CompactThemeButton(
                        title: "Dark",
                        icon: "moon.stars.fill",
                        isSelected: themeManager.isDark,
                        action: { withAnimation(.spring()) { themeManager.isDark = true } }
                    )
                }
                .background(
                    Capsule()
                        .fill(themeManager.currentTheme.textColor.opacity(0.05))
                )
                .overlay(
                    Capsule()
                        .stroke(themeManager.currentTheme.textColor.opacity(0.1), lineWidth: 1)
                )
            }
            
            Spacer()
        }
        .padding(.horizontal, 20)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}


struct CompactThemeButton: View {
    @EnvironmentObject var themeManager: ThemeManager
    
    let title: String
    let icon: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.lummiFont(size: 14))
                Text(title)
                    .font(.lummiFont(size: 14))
                    .lineLimit(1)
                    .fixedSize(horizontal: true, vertical: false)
            }
            .padding(.vertical, 8)
            .padding(.horizontal, 16)
            .foregroundColor(isSelected ? themeManager.currentTheme.backgroundColor : themeManager.currentTheme.textColor.opacity(0.5))
            .background(
                Capsule()
                    .fill(isSelected ? themeManager.currentTheme.textColor : Color.clear)
            )
        }
        .buttonStyle(.plain)
        .accessibilityIdentifier("\(title)ThemeButton")
        .accessibilityValue(isSelected ? "Selected" : "Unselected")
    }
}
