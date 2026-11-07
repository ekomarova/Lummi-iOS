import XCTest
import SwiftData
@testable import Lummi

// Measures `JoyEntryStore.clearAll` on a 5,000-entry store, with no UI involved. Each run builds a fresh store, fills it
// and measures only the clearing.
//   inMemory  the store lives in memory;
//   onDisk    a SQLite file in the temporary directory, closer to the app's real store (still without CloudKit);
//   batch     NOT what the app does: one `delete(model:)` call in the same kind of scratch context, for comparison.
//
// Manual only: every test is skipped unless RUN_PERFORMANCE_TESTS=1 is set. From the terminal:
//   TEST_RUNNER_RUN_PERFORMANCE_TESTS=1 xcodebuild test -scheme Lummi -destination 'platform=iOS Simulator,name=iPhone 17' \
//     -only-testing:LummiTests/JoyEntryStorePerformanceTests
// In Xcode, add RUN_PERFORMANCE_TESTS=1 under Edit Scheme > Test > Arguments > Environment Variables (do not commit it).
@MainActor
final class JoyEntryStorePerformanceTests: XCTestCase {

    private let entryCount = 5_000

    override func setUpWithError() throws {
        try XCTSkipUnless(
            ProcessInfo.processInfo.environment["RUN_PERFORMANCE_TESTS"] == "1",
            "Performance tests are manual: set RUN_PERFORMANCE_TESTS=1 to run them"
        )
        continueAfterFailure = false
    }

    private var options: XCTMeasureOptions {
        let options = XCTMeasureOptions()
        options.iterationCount = 5
        options.invocationOptions = [.manuallyStart, .manuallyStop]
        return options
    }

    private func makeContainer(onDisk: Bool) throws -> (container: ModelContainer, directory: URL?) {
        guard onDisk else {
            let configuration = ModelConfiguration(isStoredInMemoryOnly: true, cloudKitDatabase: .none)
            return (try ModelContainer(for: JoyEntry.self, configurations: configuration), nil)
        }
        let directory = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        let configuration = ModelConfiguration(url: directory.appendingPathComponent("perf.store"), cloudKitDatabase: .none)
        return (try ModelContainer(for: JoyEntry.self, configurations: configuration), directory)
    }

    private func fill(_ context: ModelContext) throws {
        let startOfToday = Calendar.current.startOfDay(for: Date())
        for index in 0..<entryCount {
            let date = startOfToday.addingTimeInterval(-Double(index) * 60)
            context.insert(JoyEntry(text: "Perf record #\(index): a small joy worth remembering", date: date))
        }
        try context.save()
    }

    private func measureClearing(onDisk: Bool, clear: @escaping (ModelContext) throws -> Void) {
        measure(metrics: [XCTClockMetric()], options: options) {
            do {
                let (container, directory) = try makeContainer(onDisk: onDisk)
                defer { directory.map { try? FileManager.default.removeItem(at: $0) } }
                let context = ModelContext(container)
                try fill(context)
                XCTAssertEqual(try context.fetchCount(FetchDescriptor<JoyEntry>()), entryCount)

                startMeasuring()
                try clear(context)
                stopMeasuring()

                XCTAssertEqual(try context.fetchCount(FetchDescriptor<JoyEntry>()), 0)
            } catch {
                XCTFail("\(error)")
            }
        }
    }

    private func clearAllLikeTheApp(_ context: ModelContext) throws {
        try JoyEntryStore(context: context, save: { try $0.save() }).clearAll()
    }

    private func clearAllInOneCall(_ context: ModelContext) throws {
        let scratch = ModelContext(context.container)
        scratch.autosaveEnabled = false
        try scratch.delete(model: JoyEntry.self)
        try scratch.save()
    }

    func test_Perf_ClearAll_inMemory() {
        measureClearing(onDisk: false, clear: clearAllLikeTheApp)
    }

    func test_Perf_ClearAll_onDisk() {
        measureClearing(onDisk: true, clear: clearAllLikeTheApp)
    }

    func test_Perf_ClearAll_batch_inMemory() {
        measureClearing(onDisk: false, clear: clearAllInOneCall)
    }

    func test_Perf_ClearAll_batch_onDisk() {
        measureClearing(onDisk: true, clear: clearAllInOneCall)
    }
}
