//
//  Copyright (c) 2026, Evseniia Komarova.
//  All rights reserved.
//
//  Licensed under the PolyForm Noncommercial License 1.0.0.
//  See the LICENSE file in the repository root for full terms.
//  <https://polyformproject.org/licenses/noncommercial/1.0.0>
//

import Foundation
import CloudKit
import CoreData
import Observation
import SwiftUI

// Observes the iCloud account and CloudKit sync events and exposes a user-facing sync state.
enum CloudKitSyncState: Equatable {
    case available
    case loggedOut
    case restricted
    case storageFull
    case unavailableInThisBuild
    case statusUndetermined
    case statusUnrecognized
    case unknownError(String)

    var message: LocalizedStringResource? {
        switch self {
        case .available:
            return nil
        case .loggedOut:
            return "Synchronization is suspended. Please log in to iCloud in Settings."
        case .restricted:
            return "iCloud is restricted by security policies."
        case .storageFull:
            return "iCloud storage is full. Please free up space to continue syncing."
        case .unavailableInThisBuild:
            return "Sync issue: iCloud is not available in this build."
        case .statusUndetermined:
            return "Sync issue: Status could not be determined."
        case .statusUnrecognized:
            return "Sync issue: Unknown status."
        case .unknownError(let msg):
            return "Sync issue: \(msg)"
        }
    }
}

@Observable
@MainActor
final class CloudKitSyncMonitor {
    var syncState: CloudKitSyncState = .available
    private var container: CKContainer?
    private var isCloudKitDisabled = false
    private(set) var hasStarted = false

    // Cheap on purpose: SwiftUI may run a `@State` initializer on every view re-creation,
    // so nothing here may touch CloudKit. Call `start()` once the monitor is actually needed.
    init(isCloudKitDisabled: Bool = false) {
        self.isCloudKitDisabled = isCloudKitDisabled
        // CKContainer.default() raises an uncaught NSException (crashing the process)
        // on builds without a signed iCloud entitlement, e.g. CI builds made with
        // CODE_SIGNING_ALLOWED=NO. UI test runs always fall into that category, so skip
        // it there the same way LummiApp already switches SwiftData to in-memory storage
        // for UI tests, instead of touching CloudKit at all. -UI_TESTING_ICLOUD_LOGGED_OUT
        // reports the real .loggedOut state deterministically, since a genuine account
        // status can't be exercised without live entitlements.
        #if DEBUG
        let arguments = ProcessInfo.processInfo.arguments
        // Xcode Previews run without the iCloud entitlement too, so they must not touch CloudKit either.
        if ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1" {
            self.isCloudKitDisabled = true
            return
        }
        if arguments.contains("-UI_TESTING_ICLOUD_LOGGED_OUT") {
            self.isCloudKitDisabled = true
            syncState = .loggedOut
            return
        }
        if arguments.contains(where: { $0.hasPrefix("-UI_TESTING") }) {
            self.isCloudKitDisabled = true
            syncState = .unavailableInThisBuild
        }
        #endif
    }

    // Connects to CloudKit, starts observing and checks the account. Safe to call more than once.
    func start() {
        guard !isCloudKitDisabled, !hasStarted else { return }
        hasStarted = true
        container = CKContainer.default()

        // Listen for Apple ID Account changes
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(accountStatusDidChange),
            name: .CKAccountChanged,
            object: nil
        )

        // Listen to SwiftData/CoreData background sync events
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(cloudKitEventChanged(_:)),
            name: NSPersistentCloudKitContainer.eventChangedNotification,
            object: nil
        )

        Task {
            await checkAccountStatus()
        }
    }

    @objc private func accountStatusDidChange() {
        Task {
            await checkAccountStatus()
        }
    }

    @objc private func cloudKitEventChanged(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
              let event = userInfo[NSPersistentCloudKitContainer.eventNotificationUserInfoKey] as? NSPersistentCloudKitContainer.Event else { return }

        // Most CloudKit errors are transient and retried by SwiftData, so only the ones the user can act on are shown.
        let reaction = CloudKitSyncEventReaction.make(type: event.type, succeeded: event.succeeded, error: event.error)
        Task { @MainActor in
            switch reaction {
            case .setState(let state):
                self.syncState = state
            case .recheckAccount(let preservingStorageFull):
                await checkAccountStatus(preservingStorageFull: preservingStorageFull)
            case .none:
                break
            }
        }
    }

    // `preservingStorageFull` keeps `.storageFull` when the account itself is fine: the account being available
    // says nothing about free iCloud space, which only a successful upload proves.
    func checkAccountStatus(preservingStorageFull: Bool = false) async {
        guard let container else { return }
        do {
            let status = try await container.accountStatus()
            switch status {
            case .available:
                if !(preservingStorageFull && self.syncState == .storageFull) {
                    self.syncState = .available
                }
            case .noAccount:
                self.syncState = .loggedOut
            case .restricted:
                self.syncState = .restricted
            case .temporarilyUnavailable:
                // Do nothing, SwiftData seamlessly works offline locally
                break
            case .couldNotDetermine:
                self.syncState = .statusUndetermined
            @unknown default:
                self.syncState = .statusUnrecognized
            }
        } catch {
            self.syncState = .unknownError(error.localizedDescription)
        }
    }
}
