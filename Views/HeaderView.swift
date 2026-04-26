import SwiftUI

struct HeaderView: View {
    @EnvironmentObject var themeManager: ThemeManager

    let date: Date
    let isExpanded: Bool
    let onTap: () -> Void

    private var headerDateText: String {
            let month = date.formatted(.dateTime.month(.wide)).uppercased()
            let year = date.formatted(.dateTime.year())
            
            if isExpanded {
                return "\(month) \(year)"
            } else {
                let day = Calendar.current.component(.day, from: date)
                return "\(day) \(month) \(year)"
            }
        }

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 6) {
                Text(headerDateText)
                    .font(.system(size: 24, weight: .black, design: .monospaced))
                    .foregroundColor(themeManager.currentTheme.textColor)

                Image(systemName: "chevron.down")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(themeManager.currentTheme.textColor)
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
