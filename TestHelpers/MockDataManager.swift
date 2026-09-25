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

    // Calendar arithmetic that falls back to the original date instead of force unwrapping.
    private static func shiftedDate(_ date: Date, by value: Int, _ component: Calendar.Component) -> Date {
        Calendar.current.date(byAdding: component, value: value, to: date) ?? date
    }

    // Each UI-testing launch argument maps to one data scenario. `isStoreEmpty` is read once before any of
    // them runs, so scenarios that need an empty store do not see each other's unsaved inserts.
    private typealias Scenario = (flag: String, insert: (ModelContext, _ isStoreEmpty: Bool) -> Void)

    private static let scenarios: [Scenario] = [
        ("-UI_TESTING_CALENDAR", { context, _ in insertCalendarEntries(context) }),
        ("-UI_TESTING_10_RECORDS", { context, _ in insertTenRecordsToday(context) }),
        ("-UI_TESTING_PAST_MONTHS_AVAILABLE", { context, _ in insertEntryTwoMonthsAgo(context) }),
        ("-UI_TESTING_PAST_MONTH_ONE_JOY", { context, isEmpty in if isEmpty { insertOneEntryLastMonth(context) } }),
        ("-UI_TESTING_PAST_MONTH_MANY_JOYS", { context, isEmpty in if isEmpty { insertManyEntriesLastMonth(context) } }),
        ("-UI_TESTING_INSIGHTS_TWO_MONTHS", { context, isEmpty in if isEmpty { insertTwoMonthsOfEntries(context) } }),
        ("-UI_TESTING_5K_ENTRIES", { context, isEmpty in if isEmpty { insertFiveThousandEntries(context) } }),
        ("-UI_TESTING_4_DAYS_FILLED", { context, isEmpty in if isEmpty { insertFourFilledDays(context) } })
    ]

    static func injectIfNeeded(modelContext: ModelContext) {
        let arguments = ProcessInfo.processInfo.arguments

        if isScreenshotsMode {
            injectScreenshotData(modelContext: modelContext)
            return
        }

        guard arguments.contains(where: { $0.hasPrefix("-UI_TESTING") }) else { return }

        // Read from the store on demand, so the root view does not keep a live query over every entry.
        let isStoreEmpty = ((try? modelContext.fetchCount(FetchDescriptor<JoyEntry>())) ?? 0) == 0

        for scenario in scenarios where arguments.contains(scenario.flag) {
            scenario.insert(modelContext, isStoreEmpty)
        }
    }

    // MARK: - UI testing scenarios

    private static func insertCalendarEntries(_ context: ModelContext) {
        let today = Date()
        context.insert(JoyEntry(text: "I ate a lot of chips and it was amazing!", date: shiftedDate(today, by: -1, .day)))
        context.insert(JoyEntry(text: "Watched a beautiful sunset", date: shiftedDate(today, by: -32, .day)))
    }

    private static func insertTenRecordsToday(_ context: ModelContext) {
        let baseDate = Date()
        let todaysEntriesCount = (try? context.fetchCount(
            FetchDescriptor<JoyEntry>(predicate: JoyEntry.dayPredicate(for: baseDate))
        )) ?? 0
        guard todaysEntriesCount == 0 else { return }
        for index in 0..<10 {
            context.insert(JoyEntry(text: "Record #\(index)", date: shiftedDate(baseDate, by: index, .second)))
        }
        try? context.save()
    }

    private static func insertEntryTwoMonthsAgo(_ context: ModelContext) {
        context.insert(JoyEntry(text: "Watched a beautiful sunset", date: shiftedDate(Date(), by: -62, .day)))
    }

    private static func insertOneEntryLastMonth(_ context: ModelContext) {
        context.insert(JoyEntry(text: "Past test record", date: shiftedDate(Date(), by: -1, .month)))
    }

    private static func insertManyEntriesLastMonth(_ context: ModelContext) {
        let pastDateBase = shiftedDate(Date(), by: -1, .month)
        for dayOffset in 0..<5 {
            let day = shiftedDate(pastDateBase, by: -dayOffset, .day)
            for index in 0..<3 {
                let recordDate = shiftedDate(day, by: -index, .hour)
                context.insert(JoyEntry(text: "Past Many Mock \(dayOffset)-\(index)", date: recordDate))
            }
        }
        try? context.save()
    }

    // Insights month switching: 2 entries today and 5 entries on the 10th of the previous month.
    // Fixed day-of-month for the past ones keeps them in one month whatever today's date is.
    private static func insertTwoMonthsOfEntries(_ context: ModelContext) {
        let calendar = Calendar.current
        let now = Date()
        for index in 1...2 {
            guard let date = calendar.date(bySettingHour: 8 + index, minute: 0, second: 0, of: now) else { continue }
            context.insert(JoyEntry(text: "Current month joy \(index)", date: date))
        }
        if let previous = calendar.date(byAdding: .month, value: -1, to: now) {
            var components = calendar.dateComponents([.year, .month], from: previous)
            components.day = 10
            for index in 1...5 {
                components.hour = 8 + index
                if let date = calendar.date(from: components) {
                    context.insert(JoyEntry(text: "Previous month joy \(index)", date: date))
                }
            }
        }
        try? context.save()
    }

    // Performance runs: 5,000 entries spread over five years (about 2.7 per day, ending today)
    private static func insertFiveThousandEntries(_ context: ModelContext) {
        let calendar = Calendar.current
        let startOfToday = calendar.startOfDay(for: Date())
        let entryCount = 5_000
        let dayCount = 1_825
        for index in 0..<entryCount {
            let dayOffset = index * dayCount / entryCount
            guard let day = calendar.date(byAdding: .day, value: -dayOffset, to: startOfToday),
                  let recordDate = calendar.date(byAdding: .hour, value: 8 + index % 12, to: day) else { continue }
            context.insert(JoyEntry(text: "Perf record #\(index): a small joy worth remembering", date: recordDate))
        }
        try? context.save()
    }

    private static func insertFourFilledDays(_ context: ModelContext) {
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
                context.insert(JoyEntry(text: "Evening mock moment \(dayOffset + 1)", date: recordDate))
            }
        }
        try? context.save()
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
            if let entryDate = date(dayOffset: 0, hour: time.0, minute: time.1) {
                modelContext.insert(JoyEntry(text: texts.today[index], date: entryDate))
            }
        }

        // Earlier days of the current month (skipped if they fall into the previous month)
        let currentMonthDays = [1, 2, 4, 5, 7, 9, 12, 15]
        for (index, offset) in currentMonthDays.enumerated() {
            if let entryDate = date(dayOffset: offset, hour: 10 + index % 8, minute: 15) {
                modelContext.insert(JoyEntry(text: texts.currentMonth[index % texts.currentMonth.count], date: entryDate))
            }
        }

        // Previous month
        let pastMonthDays = [3, 8, 14, 21, 26]
        for (index, day) in pastMonthDays.enumerated() {
            if let entryDate = date(dayOffset: day, monthOffset: -1, hour: 19, minute: 30) {
                modelContext.insert(JoyEntry(text: texts.pastMonth[index % texts.pastMonth.count], date: entryDate))
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
