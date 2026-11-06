import Testing
import Foundation
@testable import Lummi

struct TestLaunchArgumentsTests {

    // MARK: - Flags

    @Test func rawValuesAreUnique() {
        let rawValues = TestLaunchArguments.allCases.map(\.rawValue)
        #expect(Set(rawValues).count == rawValues.count)
    }

    @Test func everyFlagExceptScreenshotsIsAUITestingFlag() {
        for flag in TestLaunchArguments.allCases where flag != .screenshots {
            #expect(flag.rawValue.hasPrefix(TestLaunchArguments.uiTestingPrefix), "\(flag.rawValue)")
        }
    }

    // UI tests must never trigger the screenshots data, and the screenshots mode must not count as UI testing.
    @Test func screenshotsFlagIsNotAUITestingFlag() {
        #expect(!TestLaunchArguments.hasUITestingFlag(in: [TestLaunchArguments.screenshots.rawValue]))
    }

    @Test func flagsMatchTheStringsUITestsPass() {
        #expect(TestLaunchArguments.calendar.rawValue == "-UI_TESTING_CALENDAR")
        #expect(TestLaunchArguments.fiveThousandEntries.rawValue == "-UI_TESTING_5K_ENTRIES")
        #expect(TestLaunchArguments.forceStoreErrorOnce.rawValue == "-UI_TESTING_FORCE_STORE_ERROR_ONCE")
        #expect(TestLaunchArguments.simulateSaveFailure.rawValue == "-UI_TESTING_SIMULATE_SAVE_FAILURE")
        #expect(TestLaunchArguments.screenshots.rawValue == "-SCREENSHOTS_DATA")
    }

    // MARK: - isPresent

    @Test func isPresentFindsOnlyTheExactFlag() {
        let arguments = ["-UI_TESTING_FORCE_STORE_ERROR_ONCE"]
        #expect(TestLaunchArguments.forceStoreErrorOnce.isPresent(in: arguments))
        // A flag that is a prefix of another must not match it.
        #expect(!TestLaunchArguments.forceStoreError.isPresent(in: arguments))
    }

    @Test func isPresentIsFalseWithoutArguments() {
        for flag in TestLaunchArguments.allCases {
            #expect(!flag.isPresent(in: []))
        }
    }

    // MARK: - hasUITestingFlag

    @Test(arguments: [
        (["-UI_TESTING"], true),
        (["-UI_TESTING_CALENDAR"], true),
        (["-SCREENSHOTS_DATA", "-UI_TESTING_10_RECORDS"], true),
        (["-SCREENSHOTS_DATA"], false),
        (["UI_TESTING"], false),
        ([], false)
    ])
    func uiTestingModeIsDetectedByThePrefix(arguments: [String], expected: Bool) {
        #expect(TestLaunchArguments.hasUITestingFlag(in: arguments) == expected)
    }

    // MARK: - isSyncEnabledAtLaunch

    @Test func normalLaunchFollowsTheSavedPreference() {
        #expect(TestLaunchArguments.isSyncEnabledAtLaunch(storedPreference: true, arguments: []))
        #expect(!TestLaunchArguments.isSyncEnabledAtLaunch(storedPreference: false, arguments: []))
    }

    @Test func uiTestingIgnoresTheSavedPreference() {
        #expect(!TestLaunchArguments.isSyncEnabledAtLaunch(storedPreference: true, arguments: ["-UI_TESTING_CALENDAR"]))
        #expect(!TestLaunchArguments.isSyncEnabledAtLaunch(storedPreference: true, arguments: ["-UI_TESTING"]))
    }

    @Test func uiTestingCanStartWithSyncOn() {
        let arguments = ["-UI_TESTING_SYNC_ENABLED_AT_LAUNCH"]
        #expect(TestLaunchArguments.isSyncEnabledAtLaunch(storedPreference: false, arguments: arguments))
        #expect(TestLaunchArguments.isSyncEnabledAtLaunch(storedPreference: true, arguments: arguments))
    }

    @Test func screenshotsModeNeverSyncs() {
        #expect(!TestLaunchArguments.isSyncEnabledAtLaunch(storedPreference: true, arguments: ["-SCREENSHOTS_DATA"]))
    }
}
