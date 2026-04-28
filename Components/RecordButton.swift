import SwiftUI

struct RecordButton: View {
    @EnvironmentObject var themeManager: ThemeManager
    
    let selectedDate: Date?
    let joyEntries: [String: [String]]
    var onTap: () -> Void

    var body: some View {
        Group {
            if selectedDate != nil {
                Button(action: onTap) {
                    Image(systemName: "star.fill")
                        .font(.lummiFont(size: 43))
                        .foregroundColor(themeManager.currentTheme.bottomPanelStarIconColor)
                        .frame(maxWidth: .infinity, minHeight: 48)
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Record the joy")
                .accessibilityIdentifier("MainRecordButton")
            } else {
                EmptyView()
            }
        }
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: selectedDate)
    }
}
