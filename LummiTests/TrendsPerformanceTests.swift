import XCTest
import SwiftData
@testable import Lummi

// Measures the Trends calculations on a 5,000-entry in-memory store, with no UI involved.
// Compares these ways, for a year's page:
//   legacy     the old `TrendsChartsView`: every card and chart filters the whole journal again (7 passes);
//   singlePass `TrendsPerformanceStats` over the whole journal: the calculation alone, one pass;
//   asInApp    what `TrendsChartsView` does today: the store returns only the entries of the range
//              (`JoyEntry.predicate(in:)`, like its `@Query`), then `TrendsPerformanceStats` makes one pass over them;
//   recompute  just that one pass over the year's entries, without the fetch: what each render of the page costs.
//
// Manual only: every test is skipped unless RUN_PERFORMANCE_TESTS=1 is set. From the terminal:
//   TEST_RUNNER_RUN_PERFORMANCE_TESTS=1 xcodebuild test -scheme Lummi -destination 'platform=iOS Simulator,name=iPhone 17' \
//     -only-testing:LummiTests/TrendsPerformanceTests
// In Xcode, add RUN_PERFORMANCE_TESTS=1 under Edit Scheme > Test > Arguments > Environment Variables (do not commit it).
@MainActor
final class TrendsPerformanceTests: XCTestCase {

    private var container: ModelContainer!
    private var context: ModelContext!
    private var entries: [JoyEntry] = []
    private let locale = Locale(identifier: "en_US")
    private let currentYear = Calendar.current.component(.year, from: Date())

    override func setUpWithError() throws {
        try XCTSkipUnless(
            ProcessInfo.processInfo.environment["RUN_PERFORMANCE_TESTS"] == "1",
            "Performance tests are manual: set RUN_PERFORMANCE_TESTS=1 to run them"
        )
        continueAfterFailure = false
        let configuration = ModelConfiguration(isStoredInMemoryOnly: true, cloudKitDatabase: .none)
        container = try ModelContainer(for: JoyEntry.self, configurations: configuration)
        context = ModelContext(container)
        insertFiveThousandEntries(into: context)
        // The whole journal, sorted by date: the input of the legacy and single-pass variants.
        entries = try context.fetch(FetchDescriptor<JoyEntry>(sortBy: [SortDescriptor(\.date)]))
        XCTAssertEqual(entries.count, 5_000)
    }

    override func tearDownWithError() throws {
        entries = []
        context = nil
        container = nil
    }

    private var options: XCTMeasureOptions {
        let options = XCTMeasureOptions()
        options.iterationCount = 10
        return options
    }

    private var metrics: [XCTMetric] { [XCTClockMetric(), XCTCPUMetric()] }

    // Same spread as the UI performance tests: 5,000 entries over five years.
    private func insertFiveThousandEntries(into context: ModelContext) {
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

    // The previous `TrendsChartsView`: each value filtered the whole journal again (7 passes).
    private func legacyStats(year: Int) -> Int {
        func ranged() -> [JoyEntry] { TrendsCalculator.entries(entries, in: .year(year)) }
        var checksum = ranged().count
        checksum += InsightsCalculator.uniqueDaysCount(in: ranged())
        checksum += InsightsCalculator.longestStreak(in: ranged())
        checksum += InsightsCalculator.joyfulHours(entries: ranged(), locale: locale).count
        checksum += TrendsCalculator.dataPoints(for: ranged(), year: year).count
        checksum += TrendsCalculator.weekdayCounts(in: ranged(), calendar: .lummiCalendar(locale: locale)).count
        checksum += ranged().count
        return checksum
    }

    private func singlePassStats(year: Int) -> Int {
        checksum(of: TrendsPerformanceStats.make(from: entries, year: year, locale: locale, calendar: .lummiCalendar(locale: locale)))
    }

    // The current `TrendsChartsView`: the store fetches only the range (sorted like its `@Query`), then one pass.
    private func asInAppStats(year: Int) throws -> Int {
        let now = Date()
        let descriptor = FetchDescriptor<JoyEntry>(
            predicate: JoyEntry.predicate(in: TrendsCalculator.dateRange(for: .year(year), now: now)),
            sortBy: [SortDescriptor(\.date)]
        )
        let rangedEntries = try context.fetch(descriptor)
        return checksum(of: TrendsPerformanceStats.make(
            from: rangedEntries,
            year: year,
            locale: locale,
            now: now,
            calendar: .lummiCalendar(locale: locale)
        ))
    }

    // Same sum as `legacyStats`, so the variants can be compared.
    private func checksum(of stats: TrendsPerformanceStats) -> Int {
        stats.entryCount + stats.daysJournaled + stats.bestStreak + stats.joyfulHours.count
            + stats.dataPoints.count + stats.weekdayCounts.count + stats.entryCount
    }

    // The entries of the current year, fetched like the page's `@Query` does (sorted by date).
    private func currentYearEntries() throws -> [JoyEntry] {
        let descriptor = FetchDescriptor<JoyEntry>(
            predicate: JoyEntry.predicate(in: TrendsCalculator.dateRange(for: .year(currentYear), now: Date())),
            sortBy: [SortDescriptor(\.date)]
        )
        return try context.fetch(descriptor)
    }

    private func makeYearStats(from yearEntries: [JoyEntry]) -> TrendsPerformanceStats {
        TrendsPerformanceStats.make(
            from: yearEntries,
            year: currentYear,
            locale: locale,
            calendar: .lummiCalendar(locale: locale)
        )
    }

    func test_Perf_TrendsYear_recompute() throws {
        let yearEntries = try currentYearEntries()
        measure(metrics: metrics, options: options) {
            XCTAssertGreaterThan(checksum(of: makeYearStats(from: yearEntries)), 0)
        }
    }

    func test_Perf_TrendsYear_legacy() {
        measure(metrics: metrics, options: options) {
            XCTAssertGreaterThan(legacyStats(year: currentYear), 0)
        }
    }

    func test_Perf_TrendsYear_singlePass() {
        measure(metrics: metrics, options: options) {
            XCTAssertGreaterThan(singlePassStats(year: currentYear), 0)
        }
    }

    func test_Perf_TrendsYear_asInApp() throws {
        measure(metrics: metrics, options: options) {
            XCTAssertGreaterThan((try? asInAppStats(year: currentYear)) ?? 0, 0)
        }
    }

    // All ways must show the same numbers, otherwise the comparison above is meaningless.
    func test_Perf_AllWaysGiveTheSameResult() throws {
        let legacy = legacyStats(year: currentYear)
        XCTAssertEqual(legacy, singlePassStats(year: currentYear))
        XCTAssertEqual(legacy, try asInAppStats(year: currentYear))
        XCTAssertEqual(legacy, checksum(of: makeYearStats(from: try currentYearEntries())))
    }
}
