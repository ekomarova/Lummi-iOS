import SwiftUI

struct BottomPanel<Content: View>: View {
    let theme: AppTheme
    @ViewBuilder let content: () -> Content

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 28)
                .fill(theme.bottomPanelBackground)
                .overlay(
                    RoundedRectangle(cornerRadius: 28)
                        .stroke(theme.bottomPanelBorder, lineWidth: 1)
                )
                .frame(height: 84)

            HStack(spacing: 12) {
                content()
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 8)
    }
}
