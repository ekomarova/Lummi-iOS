#if DEBUG
import Foundation

// Every launch argument the app understands in Debug builds, for UI tests, previews of failure states and App Store
// screenshots. Release builds do not compile this and ignore all of them.
//
// UI tests run in their own target and pass the same strings by hand.
enum TestLaunchArguments: String, CaseIterable {

    // MARK: - Data scenarios (see `MockDataManager`)
    case calendar = "-UI_TESTING_CALENDAR"
    case tenRecords = "-UI_TESTING_10_RECORDS"
    case pastMonthsAvailable = "-UI_TESTING_PAST_MONTHS_AVAILABLE"
    case pastMonthOneJoy = "-UI_TESTING_PAST_MONTH_ONE_JOY"
    case pastMonthManyJoys = "-UI_TESTING_PAST_MONTH_MANY_JOYS"
    case insightsTwoMonths = "-UI_TESTING_INSIGHTS_TWO_MONTHS"
    case fiveThousandEntries = "-UI_TESTING_5K_ENTRIES"
    case fourDaysFilled = "-UI_TESTING_4_DAYS_FILLED"
    case trendsMultiYear = "-UI_TESTING_TRENDS_MULTI_YEAR"

    // MARK: - Simulated failures and state
    // Makes every attempt to open the store fail; the `Once` variant fails only the first one, so a test can tap
    // "Try Again" and see the app recover.
    case forceStoreError = "-UI_TESTING_FORCE_STORE_ERROR"
    case forceStoreErrorOnce = "-UI_TESTING_FORCE_STORE_ERROR_ONCE"
    case forceSyncError = "-UI_TESTING_FORCE_SYNC_ERROR"
    case simulateSaveFailure = "-UI_TESTING_SIMULATE_SAVE_FAILURE"
    // Reports the real "logged out" iCloud state deterministically, since a genuine account status can't be
    // exercised without live entitlements.
    case iCloudLoggedOut = "-UI_TESTING_ICLOUD_LOGGED_OUT"
    // Starts with iCloud sync on, to exercise the launch fallback.
    case syncEnabledAtLaunch = "-UI_TESTING_SYNC_ENABLED_AT_LAUNCH"

    // MARK: - Screenshots
    // Fills the app with demo data for App Store screenshots. Deliberately does not start with "-UI_TESTING", so UI
    // tests never trigger it.
    case screenshots = "-SCREENSHOTS_DATA"

    static let uiTestingPrefix = "-UI_TESTING"

    // Any argument starting with the prefix puts the app into UI testing mode: a throwaway in-memory store, sync off
    // and no CloudKit.
    static var isUITesting: Bool {
        hasUITestingFlag(in: ProcessInfo.processInfo.arguments)
    }

    static func hasUITestingFlag(in arguments: [String]) -> Bool {
        arguments.contains { $0.hasPrefix(uiTestingPrefix) }
    }

    var isSet: Bool {
        isPresent(in: ProcessInfo.processInfo.arguments)
    }

    func isPresent(in arguments: [String]) -> Bool {
        arguments.contains(rawValue)
    }

    // Whether the first container syncs with iCloud.
    // UI tests always start from a deterministic state, ignoring the saved preference, which persists in the
    // simulator between runs and would leak one test's sync setting into the next. Screenshots mode never syncs.
    static func isSyncEnabledAtLaunch(storedPreference: Bool, arguments: [String] = ProcessInfo.processInfo.arguments) -> Bool {
        if hasUITestingFlag(in: arguments) {
            return syncEnabledAtLaunch.isPresent(in: arguments)
        }
        return !screenshots.isPresent(in: arguments) && storedPreference
    }
}
#endif
