//
//  Copyright (c) 2026, Evseniia Komarova.
//  All rights reserved.
//
//  Redistribution and use in source and binary forms, with or without
//  modification, are permitted provided that the following conditions are met:
//  - Redistributions of source code must retain the above copyright notice,
//    this list of conditions and the following disclaimer.
//  - Redistributions in binary form must reproduce the above copyright notice,
//    this list of conditions and the following disclaimer in the documentation
//    and/or other materials provided with the distribution.
//  - Neither the name of the copyright holder nor the names of its contributors
//    may be used to endorse or promote products derived from this software
//    without specific prior written permission.
//
//  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
//  AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
//  IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
//  ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
//  LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
//  CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
//  SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
//  INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
//  CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
//  ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF
//  THE POSSIBILITY OF SUCH DAMAGE.
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
    private let container = CKContainer.default()

    init() {
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
        guard let event = notification.userInfo?[NSPersistentCloudKitContainer.eventNotificationUserInfoKey] as? NSPersistentCloudKitContainer.Event else { return }

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
        }
    }

    func checkAccountStatus() async {
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
