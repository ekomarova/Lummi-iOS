import XCTest
import SwiftData
@testable import Lummi

// Measures the Trends calculations on a 5,000-entry in-memory store, with no UI involved.
// Compares three ways, for the Month tab and for a year's page:
//   legacy     the old `TrendsChartsView`: every card and chart filters the whole journal again (7 passes);
//   singlePass `TrendsPerformanceStats` over the whole journal: the calculation alone, one pass;
//   asInApp    what `TrendsChartsView` does today: the store returns only the entries of the range
//              (`JoyEntry.predicate(in:)`, like its `@Query`), then `TrendsPerformanceStats` makes one pass over them.
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
    private func legacyStats(range: TrendsRange, year: Int) -> Int {
        func ranged() -> [JoyEntry] { TrendsCalculator.entries(entries, in: range, year: year) }
        var checksum = ranged().count
        checksum += InsightsCalculator.uniqueDaysCount(in: ranged())
        checksum += InsightsCalculator.longestStreak(in: ranged())
        if range == .year { checksum += InsightsCalculator.calculateGoldenHours(entries: ranged(), locale: locale).count }
        checksum += TrendsCalculator.dataPoints(for: ranged(), range: range, year: year).count
        checksum += TrendsCalculator.weekdayCounts(in: ranged(), calendar: .lummiCalendar(locale: locale)).count
        checksum += ranged().count
        return checksum
    }

    private func singlePassStats(range: TrendsRange, year: Int) -> Int {
        checksum(of: TrendsPerformanceStats.make(from: entries, range: range, year: year, locale: locale))
    }

    // The current `TrendsChartsView`: the store fetches only the range (sorted like its `@Query`), then one pass.
    private func asInAppStats(range: TrendsRange, year: Int) throws -> Int {
        let now = Date()
        let descriptor = FetchDescriptor<JoyEntry>(
            predicate: JoyEntry.predicate(in: TrendsCalculator.dateRange(for: range, year: year, now: now)),
            sortBy: [SortDescriptor(\.date)]
        )
        let rangedEntries = try context.fetch(descriptor)
        return checksum(of: TrendsPerformanceStats.make(from: rangedEntries, range: range, year: year, locale: locale, now: now))
    }

    // Same sum as `legacyStats`, so the variants can be compared.
    private func checksum(of stats: TrendsPerformanceStats) -> Int {
        stats.entryCount + stats.daysJournaled + stats.bestStreak + (stats.joyfulHours?.count ?? 0)
            + stats.dataPoints.count + stats.weekdayCounts.count + stats.entryCount
    }

    func test_Perf_TrendsMonth_legacy() {
        measure(metrics: metrics, options: options) {
            XCTAssertGreaterThan(legacyStats(range: .month, year: currentYear), 0)
        }
    }

    func test_Perf_TrendsMonth_singlePass() {
        measure(metrics: metrics, options: options) {
            XCTAssertGreaterThan(singlePassStats(range: .month, year: currentYear), 0)
        }
    }

    func test_Perf_TrendsYear_legacy() {
        measure(metrics: metrics, options: options) {
            XCTAssertGreaterThan(legacyStats(range: .year, year: currentYear), 0)
        }
    }

    func test_Perf_TrendsYear_singlePass() {
        measure(metrics: metrics, options: options) {
            XCTAssertGreaterThan(singlePassStats(range: .year, year: currentYear), 0)
        }
    }

    func test_Perf_TrendsMonth_asInApp() throws {
        measure(metrics: metrics, options: options) {
            XCTAssertGreaterThan((try? asInAppStats(range: .month, year: currentYear)) ?? 0, 0)
        }
    }

    func test_Perf_TrendsYear_asInApp() throws {
        measure(metrics: metrics, options: options) {
            XCTAssertGreaterThan((try? asInAppStats(range: .year, year: currentYear)) ?? 0, 0)
        }
    }

    // All ways must show the same numbers, otherwise the comparison above is meaningless.
    func test_Perf_AllWaysGiveTheSameResult() throws {
        for range in [TrendsRange.month, .year] {
            let legacy = legacyStats(range: range, year: currentYear)
            XCTAssertEqual(legacy, singlePassStats(range: range, year: currentYear))
            XCTAssertEqual(legacy, try asInAppStats(range: range, year: currentYear))
        }
    }
}
