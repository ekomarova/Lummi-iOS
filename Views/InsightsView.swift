import SwiftUI
import SwiftData

struct InsightsView: View {
    @EnvironmentObject var themeManager: ThemeManager
    @Query private var allEntries: [JoyEntry]
    @State private var selectedMonth: Date = Date().startOfMonth

    private var monthlyEntries: [JoyEntry] {
        let calendar = Calendar.current
        return allEntries.filter { calendar.isDate($0.date, equalTo: selectedMonth, toGranularity: .month) }
    }

    private var monthStreak: Int {
        InsightsCalculator.longestStreak(in: monthlyEntries)
    }

    private var isCurrentMonth: Bool {
        Calendar.current.isDate(selectedMonth, equalTo: Date(), toGranularity: .month)
    }
    
    private var isOldestMonth: Bool {
        guard let oldestEntry = allEntries.min(by: { $0.date < $1.date }) else { return true }
        
        let oldestMonth = oldestEntry.date.startOfMonth
        return selectedMonth <= oldestMonth
    }

    var body: some View {
        GeometryReader { geometry in
            VStack(alignment: .leading, spacing: AdaptiveLayout.getSize(for: 20)) {

                Text("Insights")
                    .textCase(.uppercase)
                    .font(.lummiFont(size: 24))
                    .foregroundColor(themeManager.currentTheme.textColor)
                    .padding(.top, 10)
                    .frame(maxWidth: .infinity, alignment: .center)

                HStack(spacing: 20) {
                    Button(action: { changeMonth(by: -1) }) {
                        Image(systemName: "chevron.left")
                            .font(.lummiFont(size: 18))
                            .foregroundColor(themeManager.currentTheme.textColor.opacity(isOldestMonth ? 0.2 : 0.8))
                    }
                    .disabled(isOldestMonth)
                    .accessibilityIdentifier("PreviousMonthButton")
                    
                    Text(formatMonth(selectedMonth))
                        .font(.lummiFont(size: 20))
                        .foregroundColor(themeManager.currentTheme.textColor.opacity(0.7))
                        .frame(minWidth: 160, alignment: .center)
                        .accessibilityIdentifier("CurrentMonthLabel")
                    
                    Button(action: { changeMonth(by: 1) }) {
                        Image(systemName: "chevron.right")
                            .font(.lummiFont(size: 18))
                            .foregroundColor(themeManager.currentTheme.textColor.opacity(isCurrentMonth ? 0.2 : 0.8))
                    }
                    .disabled(isCurrentMonth)
                    .accessibilityIdentifier("NextMonthButton")
                }
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.bottom, 10)

                ScrollView(showsIndicators: false) {
                    VStack(spacing: AdaptiveLayout.getSize(for: 40)) {
                        
                        let itemSize = geometry.size.width * 0.42

                        // Monthly Entries
                        HStack(alignment: .center, spacing: 15) {
                            Text(InsightsCalculator.getMonthlyJoysMessage(count: monthlyEntries.count, isCurrentMonth: isCurrentMonth))
                                .textCase(.uppercase)
                                .font(.lummiFont(size: 15))
                                .foregroundColor(themeManager.currentTheme.textColor.opacity(0.8))
                                .lineSpacing(8)
                                .multilineTextAlignment(.center)
                                .frame(maxWidth: .infinity, alignment: .center)
                                .accessibilityIdentifier("MonthlyJoysMessage")
                            
                            AmbientStatBadge(
                                value: "\(monthlyEntries.count)",
                                colors: [Color(red: 1.0, green: 0.7, blue: 0.75), Color(red: 0.95, green: 0.4, blue: 0.55)]
                            )
                            .frame(width: itemSize, height: itemSize)
                        }
                        
                        // Month Streak
                        HStack(alignment: .center, spacing: 15) {
                            AmbientStatBadge(
                                value: "\(monthStreak)",
                                colors: [.yellow, .orange, .red]
                            )
                            .frame(width: itemSize, height: itemSize)
                            
                            Text(InsightsCalculator.getMonthlyStreakMessage(streak: monthStreak, isCurrentMonth: isCurrentMonth))
                                .textCase(.uppercase)
                                .font(.lummiFont(size: 15))
                                .foregroundColor(themeManager.currentTheme.textColor.opacity(0.8))
                                .lineSpacing(8)
                                .multilineTextAlignment(.center)
                                .frame(maxWidth: .infinity, alignment: .center)
                                .accessibilityIdentifier("MonthlyStreakMessage")
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 100)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .onAppear {
            selectedMonth = Date().startOfMonth
        }
    }
    
    // MARK: - Helpers
    
    private func changeMonth(by value: Int) {
        if let newMonth = Calendar.current.date(byAdding: .month, value: value, to: selectedMonth) {
            withAnimation(.spring(response: 0.35, dampingFraction: 0.82)) {
                selectedMonth = newMonth
            }
        }
    }
    
    private func formatMonth(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: date).uppercased()
    }
}

struct AmbientStatBadge: View {
    @EnvironmentObject var themeManager: ThemeManager
    
    let value: String
    let colors: [Color]
    
    var body: some View {
        ZStack {
            Circle()
                .fill(
                    LinearGradient(colors: colors, startPoint: .topLeading, endPoint: .bottomTrailing)
                )
                .scaleEffect(0.6)
                .blur(radius: 14)
                .opacity(0.85)
            
            Text(value)
                .font(.lummiFont(size: 30))
                .minimumScaleFactor(0.5)
                .lineLimit(1)
                .foregroundColor(themeManager.currentTheme.textColor.opacity(0.8))
                .padding(.horizontal, 10)
        }
    }
}
