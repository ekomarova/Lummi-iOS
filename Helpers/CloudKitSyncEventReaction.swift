//
//  Required Notice: Copyright Evseniia Komarova (https://github.com/ekomarova)
//
//  Licensed under the PolyForm Noncommercial License 1.0.0.
//  See the LICENSE file in the repository root for full terms.
//  <https://polyformproject.org/licenses/noncommercial/1.0.0>
//

import CloudKit
import CoreData

// How the sync monitor reacts to one CloudKit sync event. It takes plain values instead of the event itself
// because NSPersistentCloudKitContainer.Event cannot be created in tests.
enum CloudKitSyncEventReaction: Equatable {
    case setState(CloudKitSyncState)
    // Re-reads the iCloud account. `preservingStorageFull` keeps a "storage full" state through that check.
    case recheckAccount(preservingStorageFull: Bool)
    case none

    static func make(type: NSPersistentCloudKitContainer.EventType, succeeded: Bool, error: Error?) -> CloudKitSyncEventReaction {
        if let error {
            guard let state = state(for: error) else { return .none }
            return .setState(state)
        }
        guard succeeded else { return .none }
        // Import and setup succeed even while the iCloud storage is full (only uploading needs free space),
        // so only a successful export proves that the storage problem is gone.
        return .recheckAccount(preservingStorageFull: type != .export)
    }

    // The user-facing state for an error, or nil when it is transient or not actionable for the user.
    static func state(for error: Error) -> CloudKitSyncState? {
        let codes = ckErrorCodes(in: error)
        if codes.contains(.quotaExceeded) { return .storageFull }
        if codes.contains(.notAuthenticated) { return .loggedOut }
        return nil
    }

    // Every CKError code found in the error, its underlying errors and the per-item errors of a partial failure.
    static func ckErrorCodes(in error: Error) -> Set<CKError.Code> {
        var codes = Set<CKError.Code>()
        collectCodes(in: error, into: &codes, remainingDepth: maxUnderlyingErrorDepth)
        return codes
    }

    // Errors of NSPersistentCloudKitContainer wrap each other and partial failures. Both the underlying chain and the
    // per-item errors count against the same depth limit, so the walk is cut off defensively.
    private static func collectCodes(in error: Error, into codes: inout Set<CKError.Code>, remainingDepth: Int) {
        for (index, link) in error.underlyingErrors(maxDepth: remainingDepth).enumerated() {
            guard let ckError = link as? CKError else { continue }
            codes.insert(ckError.code)
            for itemError in ckError.partialErrorsByItemID?.values ?? [:].values {
                collectCodes(in: itemError, into: &codes, remainingDepth: remainingDepth - index - 1)
            }
        }
    }
}
