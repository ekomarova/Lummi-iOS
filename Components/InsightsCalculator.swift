import Foundation

struct InsightsCalculator {

    static func longestStreak(in entries: [JoyEntry]) -> Int {
        guard !entries.isEmpty else { return 0 }
        
        let calendar = Calendar.current
        let uniqueDays = Set(entries.map { calendar.startOfDay(for: $0.date) }).sorted(by: <)
        
        var currentStreak = 1
        var maxStreak = 1
        
        for i in 1..<uniqueDays.count {
            let difference = calendar.dateComponents([.day], from: uniqueDays[i-1], to: uniqueDays[i]).day ?? 0
            
            if difference == 1 {
                currentStreak += 1
                maxStreak = max(maxStreak, currentStreak)
            } else {
                currentStreak = 1
            }
        }
        return maxStreak
    }

    static func getMonthlyJoysMessage(count: Int, isCurrentMonth: Bool) -> String {
        if count == 0 {
            return isCurrentMonth ? "Your journey of joy starts here. Record a moment to begin!" : "A quiet month with no recorded moments"
        } else if count < 10 {
            return isCurrentMonth ? "Beautiful moments collected so far! Keep your eyes open for more!" : "Beautiful moments collected during this month"
        } else {
            return isCurrentMonth ? "Beautiful moments experienced so far! Look at you go!" : "Beautiful moments experienced during this month!"
        }
    }

    static func getMonthlyStreakMessage(streak: Int, isCurrentMonth: Bool) -> String {
        switch streak {
        case 0:
            return isCurrentMonth ? "Ready for some joy? Record a moment today to start your streak!" : "No daily streaks were built this month"
        case 1:
            // Кружок показывает "1", а текст рядом говорит: "Day of joy down!..."
            return isCurrentMonth ? "Day of joy down! Come back tomorrow to keep it going" : "Day of joy found. Every moment counts!"
        default:
            // Кружок показывает "5", а текст рядом: "Days of joy in a row!..."
            return isCurrentMonth ? "Days of joy in a row! Keep this beautiful momentum going!" : "Days of joy in a row! That was your best streak"
        }
    }
}
