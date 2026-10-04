//
//  Copyright (c) 2026, Evseniia Komarova.
//  All rights reserved.
//
//  Licensed under the PolyForm Noncommercial License 1.0.0.
//  See the LICENSE file in the repository root for full terms.
//  <https://polyformproject.org/licenses/noncommercial/1.0.0>
//

import CloudKit
import CoreData

// How the sync monitor reacts to one CloudKit sync event. It takes plain values instead of the event itself
// because NSPersistentCloudKitContainer.Event cannot be created in tests.
nonisolated enum CloudKitSyncEventReaction: Equatable {
    case setState(CloudKitSyncState)
    // Re-reads the iCloud account. `preservingStorageFull` keeps a "storage full" state through that check.
    case recheckAccount(preservingStorageFull: Bool)
    case none

    // Errors of NSPersistentCloudKitContainer wrap each other and partial failures, so the chain is cut off defensively.
    private static let maxErrorDepth = 5

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
        collectCodes(in: error, into: &codes, depth: 0)
        return codes
    }

    private static func collectCodes(in error: Error, into codes: inout Set<CKError.Code>, depth: Int) {
        guard depth < maxErrorDepth else { return }
        if let ckError = error as? CKError {
            codes.insert(ckError.code)
            if let itemErrors = ckError.partialErrorsByItemID {
                for itemError in itemErrors.values {
                    collectCodes(in: itemError, into: &codes, depth: depth + 1)
                }
            }
        }
        if let underlying = (error as NSError).userInfo[NSUnderlyingErrorKey] as? Error {
            collectCodes(in: underlying, into: &codes, depth: depth + 1)
        }
    }
}
