//
//  Copyright (c) 2026, Evseniia Komarova.
//  All rights reserved.
//
//  Licensed under the PolyForm Noncommercial License 1.0.0.
//  See the LICENSE file in the repository root for full terms.
//  <https://polyformproject.org/licenses/noncommercial/1.0.0>
//

import SwiftData

// Which store the app ended up with after trying to open the one the user asked for.
enum StorageFallback: Equatable {
    // The requested store opened.
    case none
    // The iCloud store failed, so the local store on the device opened instead.
    case localOnly
    // Nothing on disk opened. The container is a throwaway in-memory one, only there so the app has something to
    // attach, and the user must not keep adding joys to it.
    case inMemory
}

struct ContainerBootstrapResult {
    let container: ModelContainer
    let fallback: StorageFallback
    // The error from the last store that failed to open, nil when nothing failed.
    let error: (any Error)?
    // Whether the opened container actually syncs with iCloud.
    let isICloudSyncActive: Bool

    // Shown as the "iCloud Sync Error" alert: iCloud failed but the data is reachable locally.
    var syncError: (any Error)? { fallback == .localOnly ? error : nil }

    // Shown as the full-screen error: no persistent store could be opened.
    var storageError: (any Error)? { fallback == .inMemory ? error : nil }
}

// Opens the store at launch without ever crashing: the requested store first, then the local one, then memory.
// It never deletes or recreates a store file, because that file is the only copy of the user's joys.
enum ContainerBootstrap {

    static func open(
        isICloudSyncEnabled: Bool,
        makeContainer: (_ isICloudSyncEnabled: Bool) throws -> ModelContainer,
        makeInMemoryContainer: () throws -> ModelContainer
    ) throws -> ContainerBootstrapResult {
        var lastError: (any Error)?

        do {
            let container = try makeContainer(isICloudSyncEnabled)
            return ContainerBootstrapResult(
                container: container,
                fallback: .none,
                error: nil,
                isICloudSyncActive: isICloudSyncEnabled
            )
        } catch {
            lastError = error
        }

        // With sync off the local store is exactly what was just tried, so there is nothing to retry.
        if isICloudSyncEnabled {
            do {
                let container = try makeContainer(false)
                return ContainerBootstrapResult(
                    container: container,
                    fallback: .localOnly,
                    error: lastError,
                    isICloudSyncActive: false
                )
            } catch {
                lastError = error
            }
        }

        return ContainerBootstrapResult(
            container: try makeInMemoryContainer(),
            fallback: .inMemory,
            error: lastError,
            isICloudSyncActive: false
        )
    }
}
