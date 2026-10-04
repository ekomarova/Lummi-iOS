import Testing
import Foundation
@testable import Lummi

// These tests never call `start()` on an enabled monitor: CKContainer.default() crashes in
// test hosts without a signed iCloud entitlement.
@MainActor
struct CloudKitSyncMonitorTests {

    // MARK: - Lazy start

    @Test func initDoesNotConnectToCloudKit() {
        let monitor = CloudKitSyncMonitor()

        #expect(!monitor.hasStarted)
        #expect(monitor.syncState == .available)
    }

    @Test func startIsNoOpWhenCloudKitIsDisabled() {
        let monitor = CloudKitSyncMonitor(isCloudKitDisabled: true)

        monitor.start()
        monitor.start()

        #expect(!monitor.hasStarted)
        #expect(monitor.syncState == .available)
    }

    @Test func checkAccountStatusWithoutStartLeavesStateUntouched() async {
        let monitor = CloudKitSyncMonitor()

        await monitor.checkAccountStatus()

        #expect(monitor.syncState == .available)
    }

    // MARK: - Sync state messages

    @Test func availableStateHasNoMessage() {
        #expect(CloudKitSyncState.available.message == nil)
    }

    @Test(arguments: [
        CloudKitSyncState.loggedOut,
        .restricted,
        .storageFull,
        .unknownError("boom")
    ])
    func problemStatesHaveMessage(state: CloudKitSyncState) {
        #expect(state.message != nil)
    }
}
