#if DEBUG
import Foundation
import SwiftData

struct MockDataManager {
    
    // Launch argument that fills the app with demo data for App Store screenshots.
    // Deliberately does not start with "-UI_TESTING", so UI tests never trigger it.
    static let screenshotsFlag = "-SCREENSHOTS_DATA"

    static var isScreenshotsMode: Bool {
        ProcessInfo.processInfo.arguments.contains(screenshotsFlag)
    }

    static func injectIfNeeded(modelContext: ModelContext) {
        let arguments = ProcessInfo.processInfo.arguments

        if isScreenshotsMode {
            injectScreenshotData(modelContext: modelContext)
            return
        }

        guard arguments.contains(where: { $0.hasPrefix("-UI_TESTING") }) else { return }

        // Read from the store on demand, so the root view does not keep a live query over every entry.
        let isStoreEmpty = ((try? modelContext.fetchCount(FetchDescriptor<JoyEntry>())) ?? 0) == 0
        
        if arguments.contains("-UI_TESTING_CALENDAR") {
            let today = Date()
            let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: today)!
            let manyDaysAgo = Calendar.current.date(byAdding: .day, value: -32, to: today)!
            
            modelContext.insert(JoyEntry(text: "I ate a lot of chips and it was amazing!", date: yesterday))
            modelContext.insert(JoyEntry(text: "Watched a beautiful sunset", date: manyDaysAgo))
        }
        
        if arguments.contains("-UI_TESTING_10_RECORDS") {
            let baseDate = Date()
            let todaysEntriesCount = (try? modelContext.fetchCount(
                FetchDescriptor<JoyEntry>(predicate: JoyEntry.dayPredicate(for: baseDate))
            )) ?? 0
            if todaysEntriesCount == 0 {
                for i in 0..<10 {
                    let recordDate = Calendar.current.date(byAdding: .second, value: i, to: baseDate)!
                    modelContext.insert(JoyEntry(text: "Record #\(i)", date: recordDate))
                }
                try? modelContext.save()
            }
        }
        
        if arguments.contains("-UI_TESTING_PAST_MONTHS_AVAILABLE") {
            let today = Date()
            let manyDaysAgo = Calendar.current.date(byAdding: .day, value: -62, to: today)!

            modelContext.insert(JoyEntry(text: "Watched a beautiful sunset", date: manyDaysAgo))
        }
        
        if arguments.contains("-UI_TESTING_PAST_MONTH_ONE_JOY") {
            if isStoreEmpty {
                let pastDate = Calendar.current.date(byAdding: .month, value: -1, to: Date())!
                let recordDate = Calendar.current.date(byAdding: .day, value: 0, to: pastDate)!
                modelContext.insert(JoyEntry(text: "Past test record", date: recordDate))
            }
        }
        
        if arguments.contains("-UI_TESTING_PAST_MONTH_MANY_JOYS") {
            if isStoreEmpty {
                let pastDateBase = Calendar.current.date(byAdding: .month, value: -1, to: Date())!
                for dayOffset in 0..<5 {
                    let date = Calendar.current.date(byAdding: .day, value: -dayOffset, to: pastDateBase)!
                    for i in 0..<3 {
                        let recordDate = Calendar.current.date(byAdding: .hour, value: -i, to: date)!
                        modelContext.insert(JoyEntry(text: "Past Many Mock \(dayOffset)-\(i)", date: recordDate))
                    }
                }
                try? modelContext.save()
            }
        }
        
        // Insights month switching: 2 entries today and 5 entries on the 10th of the previous month.
        // Fixed day-of-month for the past ones keeps them in one month whatever today's date is.
        if arguments.contains("-UI_TESTING_INSIGHTS_TWO_MONTHS") {
            if isStoreEmpty {
                let calendar = Calendar.current
                let now = Date()
                for index in 1...2 {
                    guard let date = calendar.date(bySettingHour: 8 + index, minute: 0, second: 0, of: now) else { continue }
                    modelContext.insert(JoyEntry(text: "Current month joy \(index)", date: date))
                }
                if let previous = calendar.date(byAdding: .month, value: -1, to: now) {
                    var components = calendar.dateComponents([.year, .month], from: previous)
                    components.day = 10
                    for index in 1...5 {
                        components.hour = 8 + index
                        if let date = calendar.date(from: components) {
                            modelContext.insert(JoyEntry(text: "Previous month joy \(index)", date: date))
                        }
                    }
                }
                try? modelContext.save()
            }
        }

        // Performance runs: 5,000 entries spread over five years (about 2.7 per day, ending today)
        if arguments.contains("-UI_TESTING_5K_ENTRIES") {
            if isStoreEmpty {
                let calendar = Calendar.current
                let startOfToday = calendar.startOfDay(for: Date())
                let entryCount = 5_000
                let dayCount = 1_825
                for index in 0..<entryCount {
                    let dayOffset = index * dayCount / entryCount
                    guard let day = calendar.date(byAdding: .day, value: -dayOffset, to: startOfToday),
                          let recordDate = calendar.date(byAdding: .hour, value: 8 + index % 12, to: day) else { continue }
                    modelContext.insert(JoyEntry(text: "Perf record #\(index): a small joy worth remembering", date: recordDate))
                }
                try? modelContext.save()
            }
        }

        if arguments.contains("-UI_TESTING_4_DAYS_FILLED") {
            if isStoreEmpty {
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
                            date: recordDate
                        ))
                    }
                }
                try? modelContext.save()
            }
        }
    }

    // MARK: - App Store screenshots

    // Demo entries: several days of the current month, 4 entries today, several days of the previous month.
    private static func injectScreenshotData(modelContext: ModelContext) {
        guard ((try? modelContext.fetchCount(FetchDescriptor<JoyEntry>())) ?? 0) == 0 else { return }

        let calendar = Calendar.current
        let now = Date()
        let texts = screenshotTexts

        func date(dayOffset: Int, monthOffset: Int = 0, hour: Int, minute: Int = 0) -> Date? {
            guard let base = calendar.date(byAdding: .month, value: monthOffset, to: now) else { return nil }
            var components = calendar.dateComponents([.year, .month, .day], from: base)
            if monthOffset == 0 {
                guard let shifted = calendar.date(byAdding: .day, value: -dayOffset, to: now),
                      calendar.isDate(shifted, equalTo: now, toGranularity: .month) else { return nil }
                components = calendar.dateComponents([.year, .month, .day], from: shifted)
            } else {
                components.day = dayOffset
            }
            components.hour = hour
            components.minute = minute
            return calendar.date(from: components)
        }

        // Today: 4 meaningful entries at fixed evening times (not the launch time)
        for (index, time) in [(18, 5), (19, 20), (20, 40), (21, 30)].enumerated() {
            if let d = date(dayOffset: 0, hour: time.0, minute: time.1) {
                modelContext.insert(JoyEntry(text: texts.today[index], date: d))
            }
        }

        // Earlier days of the current month (skipped if they fall into the previous month)
        let currentMonthDays = [1, 2, 4, 5, 7, 9, 12, 15]
        for (index, offset) in currentMonthDays.enumerated() {
            if let d = date(dayOffset: offset, hour: 10 + index % 8, minute: 15) {
                modelContext.insert(JoyEntry(text: texts.currentMonth[index % texts.currentMonth.count], date: d))
            }
        }

        // Previous month
        let pastMonthDays = [3, 8, 14, 21, 26]
        for (index, day) in pastMonthDays.enumerated() {
            if let d = date(dayOffset: day, monthOffset: -1, hour: 19, minute: 30) {
                modelContext.insert(JoyEntry(text: texts.pastMonth[index % texts.pastMonth.count], date: d))
            }
        }

        try? modelContext.save()
    }

    private struct ScreenshotTexts {
        let today: [String]
        let currentMonth: [String]
        let pastMonth: [String]
    }

    private static let screenshotTexts = ScreenshotTexts(
        today: [
            "My colleague brought homemade cookies and we laughed over lunch for an hour",
            "Finally finished the chapter I was stuck on. It feels so good to move forward!",
            "Evening walk in the park: the sky turned pink and I just stood there, smiling",
            "Got a call from an old friend I hadn't heard from in years"
        ],
        currentMonth: [
            "Found a cozy little bakery on the way home.",
            "My cat fell asleep on my lap during a movie.",
            "Cycled along the river and the weather was perfect.",
            "Cooked a new recipe and it turned out delicious.",
            "Someone held the door and smiled at me. Small things matter.",
            "Read a book under a blanket while it rained outside.",
            "Sunday pancakes with the whole family."
        ],
        pastMonth: [
            "Watched a beautiful sunset from the rooftop.",
            "Surprise visit from my sister, we talked until midnight.",
            "Bought fresh flowers just because.",
            "Finished my first 5K run!",
            "A quiet evening with tea and my favorite album."
        ]
    )
}
#endif
