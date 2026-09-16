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

enum CloudKitSyncState: Equatable {
    case available
    case loggedOut
    case restricted
    case storageFull
    case unknownError(String)

    var message: LocalizedStringKey? {
        switch self {
        case .available:
            return nil
        case .loggedOut:
            return "Synchronization is suspended. Please log in to iCloud in Settings."
        case .restricted:
            return "iCloud is restricted by security policies."
        case .storageFull:
            return "iCloud storage is full. Please free up space to continue syncing."
        case .unknownError(let msg):
            return "Sync issue: \(msg)"
        }
    }
}

@Observable
@MainActor
final class CloudKitSyncMonitor {
    var syncState: CloudKitSyncState = .available
    private let container: CKContainer?

    init() {
        // CKContainer.default() raises an uncaught NSException (crashing the process)
        // on builds without a signed iCloud entitlement, e.g. CI builds made with
        // CODE_SIGNING_ALLOWED=NO. UI test runs always fall into that category, so skip
        // it there the same way LummiApp already switches SwiftData to in-memory storage
        // for UI tests, instead of touching CloudKit at all.
        #if DEBUG
        let isUITesting = ProcessInfo.processInfo.arguments.contains(where: { $0.hasPrefix("-UI_TESTING") })
        guard !isUITesting else {
            container = nil
            syncState = .unknownError("iCloud is not available in this build.")
            return
        }
        #endif
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

        if let error = event.error {
            let nsError = error as NSError
            let underlyingError = nsError.userInfo[NSUnderlyingErrorKey] as? Error ?? error

            if let ckError = underlyingError as? CKError {
                Task { @MainActor in
                    if ckError.code == .quotaExceeded {
                        self.syncState = .storageFull
                    } else if ckError.code == .notAuthenticated {
                        self.syncState = .loggedOut
                    }
                }
            }
        } else if event.succeeded {
            Task { @MainActor in
                await checkAccountStatus()
            }
        }
    }

    func checkAccountStatus() async {
        guard let container else { return }
        do {
            let status = try await container.accountStatus()
            switch status {
            case .available:
                self.syncState = .available
            case .noAccount:
                self.syncState = .loggedOut
            case .restricted:
                self.syncState = .restricted
            case .temporarilyUnavailable:
                // Do nothing, SwiftData seamlessly works offline locally
                break
            case .couldNotDetermine:
                self.syncState = .unknownError("Status could not be determined.")
            @unknown default:
                self.syncState = .unknownError("Unknown status.")
            }
        } catch {
            self.syncState = .unknownError(error.localizedDescription)
        }
    }
}
