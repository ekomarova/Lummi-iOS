import SwiftUI

struct RecordButton: View {
    @EnvironmentObject var themeManager: ThemeManager
    
    let selectedDay: Int?
    let today: Int
    let joyEntries: [Int: [String]]
    var onTap: () -> Void

    
    var body: some View {
        Group {
            if selectedDay != nil { 
                Button(action: onTap) {
                    Image(systemName: "star.fill")
                        .font(.system(size: 32, weight: .black))
                        .foregroundColor(themeManager.currentTheme.bottomPanelStarIconColor)
                        .frame(maxWidth: .infinity, minHeight: 48)
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Record the joy")
            } else {
                EmptyView()
            }
        }
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: selectedDay)
    }
}
