import SwiftUI

struct InsightsView: View {
    @EnvironmentObject var themeManager: ThemeManager

    var body: some View {
        VStack(alignment: .leading, spacing: 30) {
            Text("Insights")
                .textCase(.uppercase)
                .font(.lummiFont(size: 24))
                .foregroundColor(themeManager.currentTheme.textColor)
                .padding(.top, 10)

            Spacer()
        }
        .padding(.horizontal, 20)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
