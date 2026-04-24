import SwiftUI

struct HeaderView: View {
    @EnvironmentObject var themeManager: ThemeManager

    let date: Date
    let isExpanded: Bool
    let onTap: () -> Void

    private var headerDateText: String {
        let calendar = Calendar.current
        let day = calendar.component(.day, from: date)
        let month = date.formatted(.dateTime.month(.wide)).uppercased()
        let year = date.formatted(.dateTime.year())
        return "\(day) \(month) \(year)"
    }

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 6) {
                Text(headerDateText)
                    .font(.system(size: 18, weight: .regular, design: .rounded))
                    .foregroundColor(themeManager.currentTheme.textColor.opacity(0.72))

                Image(systemName: "chevron.down")
                    .font(.system(size: 18, weight: .regular))
                    .foregroundColor(themeManager.currentTheme.textColor.opacity(0.72))
                    .rotationEffect(.degrees(isExpanded ? 180 : 0))
                    .offset(y: 1)
            }
            .contentShape(Rectangle())
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(.plain)
        .frame(maxWidth: .infinity, alignment: .center)
        .animation(.spring(response: 0.3, dampingFraction: 0.8), value: isExpanded)
    }
}
