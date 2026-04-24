import SwiftUI

struct BottomPanel<Content: View>: View {
    let theme: AppTheme
    @ViewBuilder let content: () -> Content

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 24)
                .fill(theme.bottomPanelBackground)
                .overlay(
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(theme.bottomPanelBorder, lineWidth: 1)
                )
                .frame(height: 68)

            HStack(spacing: 12) {
                content()
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 8)
    }
}
