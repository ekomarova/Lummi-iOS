import Testing
import Foundation
import CloudKit
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
        .unavailableInThisBuild,
        .statusUndetermined,
        .statusUnrecognized,
        .unknownError("CKErrorDomain 4")
    ])
    func problemStatesHaveMessage(state: CloudKitSyncState) {
        #expect(state.message != nil)
    }

    @Test func undeterminedAndUnrecognizedStatesShareOneActionableMessage() {
        #expect(CloudKitSyncState.statusUndetermined.message == CloudKitSyncState.statusUnrecognized.message)
    }

    @Test func onlyUnknownErrorShowsTechnicalDetail() {
        #expect(CloudKitSyncState.unknownError("CKErrorDomain 4").technicalDetail == "CKErrorDomain 4")
        #expect(CloudKitSyncState.loggedOut.technicalDetail == nil)
        #expect(CloudKitSyncState.networkUnavailable.technicalDetail == nil)
        #expect(CloudKitSyncState.available.technicalDetail == nil)
    }

    // MARK: - Account status errors

    @Test func accountStatusError_notAuthenticated_isLoggedOut() {
        #expect(CloudKitSyncState.forAccountStatusError(CKError(.notAuthenticated)) == .loggedOut)
    }

    @Test func accountStatusError_quotaExceeded_isStorageFull() {
        #expect(CloudKitSyncState.forAccountStatusError(CKError(.quotaExceeded)) == .storageFull)
    }

    @Test(arguments: [CKError.Code.networkUnavailable, .networkFailure])
    func accountStatusError_networkProblems_areNetworkUnavailable(code: CKError.Code) {
        #expect(CloudKitSyncState.forAccountStatusError(CKError(code)) == .networkUnavailable)
    }

    @Test func accountStatusError_networkErrorInsideUnderlyingError_isNetworkUnavailable() {
        let wrapped = NSError(
            domain: NSCocoaErrorDomain,
            code: 1,
            userInfo: [NSUnderlyingErrorKey: CKError(.networkUnavailable)]
        )

        #expect(CloudKitSyncState.forAccountStatusError(wrapped) == .networkUnavailable)
    }

    @Test func accountStatusError_otherCKError_isUnknownErrorWithCode() {
        let state = CloudKitSyncState.forAccountStatusError(CKError(.internalError))

        #expect(state == .unknownError("CKErrorDomain 1"))
    }

    @Test func accountStatusError_nonCloudKitError_isUnknownErrorWithCode() {
        let state = CloudKitSyncState.forAccountStatusError(NSError(domain: "Test", code: 7))

        #expect(state == .unknownError("Test 7"))
    }
}
