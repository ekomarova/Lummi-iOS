import Testing
import CloudKit
import CoreData
@testable import Lummi

@MainActor
struct CloudKitSyncEventReactionTests {

    // The container wraps the CloudKit error into a Cocoa error, like NSPersistentCloudKitContainer does.
    private func wrapped(_ error: Error) -> NSError {
        NSError(domain: NSCocoaErrorDomain, code: 134400, userInfo: [NSUnderlyingErrorKey: error])
    }

    private func partialFailure(_ itemErrors: [String: Error]) -> CKError {
        CKError(
            .partialFailure,
            userInfo: [CKPartialErrorsByItemIDKey: Dictionary(uniqueKeysWithValues: itemErrors.map { (AnyHashable($0.key), $0.value) })]
        )
    }

    // MARK: - Error classification

    @Test func quotaExceededMapsToStorageFull() {
        #expect(CloudKitSyncEventReaction.state(for: CKError(.quotaExceeded)) == .storageFull)
    }

    @Test func notAuthenticatedMapsToLoggedOut() {
        #expect(CloudKitSyncEventReaction.state(for: CKError(.notAuthenticated)) == .loggedOut)
    }

    @Test func wrappedQuotaExceededMapsToStorageFull() {
        #expect(CloudKitSyncEventReaction.state(for: wrapped(CKError(.quotaExceeded))) == .storageFull)
    }

    @Test func quotaExceededInsidePartialFailureMapsToStorageFull() {
        let error = wrapped(partialFailure(["record": CKError(.quotaExceeded)]))

        #expect(CloudKitSyncEventReaction.state(for: error) == .storageFull)
    }

    @Test func quotaExceededWinsOverNotAuthenticated() {
        let error = partialFailure(["a": CKError(.notAuthenticated), "b": CKError(.quotaExceeded)])

        #expect(CloudKitSyncEventReaction.state(for: error) == .storageFull)
    }

    @Test(arguments: [CKError.Code.networkUnavailable, .networkFailure, .zoneBusy, .requestRateLimited, .serverRecordChanged])
    func transientErrorsAreNotShown(code: CKError.Code) {
        #expect(CloudKitSyncEventReaction.state(for: CKError(code)) == nil)
    }

    @Test func partialFailureWithoutRelevantItemErrorsIsNotShown() {
        let error = partialFailure(["record": CKError(.serverRecordChanged)])

        #expect(CloudKitSyncEventReaction.state(for: error) == nil)
    }

    @Test func nonCloudKitErrorIsNotShown() {
        #expect(CloudKitSyncEventReaction.state(for: NSError(domain: NSCocoaErrorDomain, code: 1)) == nil)
    }

    @Test func endlessUnderlyingChainTerminates() {
        var error: Error = NSError(domain: NSCocoaErrorDomain, code: 1)
        for _ in 0..<50 { error = wrapped(error) }

        #expect(CloudKitSyncEventReaction.state(for: error) == nil)
    }

    // The depth limit counts every wrapper and every partial-failure level, root being depth 0: depth 4 is still read,
    // depth 5 is not.
    @Test func codeAtTheLastReadDepthInTheChainIsFound() {
        var error: Error = CKError(.quotaExceeded)
        for _ in 0..<4 { error = wrapped(error) }

        #expect(CloudKitSyncEventReaction.state(for: error) == .storageFull)
    }

    @Test func codeBeyondTheDepthLimitInTheChainIsIgnored() {
        var error: Error = CKError(.quotaExceeded)
        for _ in 0..<5 { error = wrapped(error) }

        #expect(CloudKitSyncEventReaction.state(for: error) == nil)
    }

    @Test func itemErrorAtTheLastReadDepthIsFound() {
        // Three wrappers put the partial failure at depth 3, so its item errors sit at depth 4.
        var error: Error = partialFailure(["a": CKError(.quotaExceeded)])
        for _ in 0..<3 { error = wrapped(error) }

        #expect(CloudKitSyncEventReaction.state(for: error) == .storageFull)
    }

    @Test func itemErrorBeyondTheDepthLimitIsIgnored() {
        var error: Error = partialFailure(["a": CKError(.quotaExceeded)])
        for _ in 0..<4 { error = wrapped(error) }

        #expect(CloudKitSyncEventReaction.state(for: error) == nil)
    }

    @Test func nestedPartialFailuresShareOneDepthLimit() {
        var error: Error = CKError(.quotaExceeded)
        for _ in 0..<5 { error = partialFailure(["a": error]) }

        #expect(CloudKitSyncEventReaction.state(for: error) == nil)
    }

    @Test func collectsCodesFromWholeErrorTree() {
        let error = wrapped(partialFailure(["a": CKError(.quotaExceeded), "b": CKError(.zoneBusy)]))

        #expect(CloudKitSyncEventReaction.ckErrorCodes(in: error) == [.partialFailure, .quotaExceeded, .zoneBusy])
    }

    // MARK: - Reaction to an event

    @Test func failedExportWithQuotaExceededSetsStorageFull() {
        let reaction = CloudKitSyncEventReaction.make(type: .export, succeeded: false, error: CKError(.quotaExceeded))

        #expect(reaction == .setState(.storageFull))
    }

    @Test func failedEventWithTransientErrorDoesNothing() {
        let reaction = CloudKitSyncEventReaction.make(type: .export, succeeded: false, error: CKError(.networkUnavailable))

        #expect(reaction == .none)
    }

    @Test func unfinishedEventDoesNothing() {
        #expect(CloudKitSyncEventReaction.make(type: .export, succeeded: false, error: nil) == .none)
    }

    @Test func successfulExportRechecksAccountAndMayClearStorageFull() {
        let reaction = CloudKitSyncEventReaction.make(type: .export, succeeded: true, error: nil)

        #expect(reaction == .recheckAccount(preservingStorageFull: false))
    }

    @Test(arguments: [NSPersistentCloudKitContainer.EventType.import, .setup])
    func successfulImportOrSetupKeepsStorageFull(type: NSPersistentCloudKitContainer.EventType) {
        let reaction = CloudKitSyncEventReaction.make(type: type, succeeded: true, error: nil)

        #expect(reaction == .recheckAccount(preservingStorageFull: true))
    }
}
