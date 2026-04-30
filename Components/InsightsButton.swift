import SwiftUI

struct InsightsButton: View {
    @EnvironmentObject var themeManager: ThemeManager
    
    var isActive: Bool
    var onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            Image(systemName: isActive ? "chart.pie.fill" : "chart.pie")
                .font(.lummiFont(size: 27))
                .foregroundColor(themeManager.currentTheme.textColor.opacity(0.8))
                .frame(width: 44, height: 44)
        }
        .buttonStyle(.plain)
        .accessibilityIdentifier(isActive ? "InsightsButton_Active" : "InsightsButton_Inactive")
    }
}
