#if DEBUG
import Foundation
import SwiftData

struct MockDataManager {
    
    static func injectIfNeeded(modelContext: ModelContext, allEntries: [JoyEntry]) {
        let arguments = ProcessInfo.processInfo.arguments

        guard arguments.contains(where: { $0.hasPrefix("-UI_TESTING") }) else { return }
        
        if arguments.contains("-UI_TESTING_CALENDAR") {
            let today = Date()
            let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: today)!
            let manyDaysAgo = Calendar.current.date(byAdding: .day, value: -32, to: today)!
            
            modelContext.insert(JoyEntry(text: "I ate a lot of chips and it was amazing!", date: yesterday, dateKey: yesterday.stringKey))
            modelContext.insert(JoyEntry(text: "Watched a beautiful sunset", date: manyDaysAgo, dateKey: manyDaysAgo.stringKey))
        }
        
        if arguments.contains("-UI_TESTING_10_RECORDS") {
            let baseDate = Date()
            let dateString = baseDate.stringKey
            
            let todaysEntriesCount = allEntries.filter { $0.dateKey == dateString }.count
            if todaysEntriesCount == 0 {
                for i in 0..<10 {
                    let recordDate = Calendar.current.date(byAdding: .second, value: i, to: baseDate)!
                    modelContext.insert(JoyEntry(text: "Record #\(i)", date: recordDate, dateKey: dateString))
                }
                try? modelContext.save()
            }
        }
        
        if arguments.contains("-UI_TESTING_PAST_MONTHS_AVAILABLE") {
            let today = Date()
            let manyDaysAgo = Calendar.current.date(byAdding: .day, value: -62, to: today)!

            modelContext.insert(JoyEntry(text: "Watched a beautiful sunset", date: manyDaysAgo, dateKey: manyDaysAgo.stringKey))
        }
        
        if arguments.contains("-UI_TESTING_PAST_MONTH_ONE_JOY") {
            if allEntries.isEmpty {
                let pastDate = Calendar.current.date(byAdding: .month, value: -1, to: Date())!
                let recordDate = Calendar.current.date(byAdding: .day, value: 0, to: pastDate)!
                modelContext.insert(JoyEntry(text: "Past test record", date: recordDate, dateKey: recordDate.stringKey))
            }
        }
        
        if arguments.contains("-UI_TESTING_PAST_MONTH_MANY_JOYS") {
            if allEntries.isEmpty {
                let pastDateBase = Calendar.current.date(byAdding: .month, value: -1, to: Date())!
                for dayOffset in 0..<5 {
                    let date = Calendar.current.date(byAdding: .day, value: -dayOffset, to: pastDateBase)!
                    for i in 0..<3 {
                        let recordDate = Calendar.current.date(byAdding: .hour, value: -i, to: date)!
                        modelContext.insert(JoyEntry(text: "Past Many Mock \(dayOffset)-\(i)", date: recordDate, dateKey: recordDate.stringKey))
                    }
                }
                try? modelContext.save()
            }
        }
        
        if arguments.contains("-UI_TESTING_4_DAYS_FILLED") {
            if allEntries.isEmpty {
                let today = Date()
                let calendar = Calendar.current
                
                var midMonthComps = calendar.dateComponents([.year, .month], from: today)
                midMonthComps.day = 15
                let baseDate = calendar.date(from: midMonthComps) ?? today

                for dayOffset in 0..<4 {
                    guard let date = calendar.date(byAdding: .day, value: -dayOffset, to: baseDate) else { continue }

                    var components = calendar.dateComponents([.year, .month, .day], from: date)
                    components.hour = 20
                    components.minute = 15
                    
                    if let recordDate = calendar.date(from: components) {
                        modelContext.insert(JoyEntry(
                            text: "Evening mock moment \(dayOffset + 1)",
                            date: recordDate,
                            dateKey: recordDate.stringKey
                        ))
                    }
                }
                try? modelContext.save()
            }
        }
    }
}
#endif
