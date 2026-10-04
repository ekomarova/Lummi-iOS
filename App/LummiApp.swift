//
//  Copyright (c) 2026, Evseniia Komarova.
//  All rights reserved.
//
//  Licensed under the PolyForm Noncommercial License 1.0.0.
//  See the LICENSE file in the repository root for full terms.
//  <https://polyformproject.org/licenses/noncommercial/1.0.0>
//

import SwiftUI
import SwiftData

// App entry point: builds the SwiftData container (with opt-in iCloud sync) and shows the root ContentView.
// If the store cannot be opened it falls back to a local store, and failing that shows an error screen, never a crash.
@main
struct LummiApp: App {
    
    @AppStorage("appLanguage") private var selectedLanguage: AppLanguage = .english
    @AppStorage("isICloudSyncEnabled") private var isICloudSyncEnabled: Bool = false

    @State private var container: ModelContainer
    @State private var containerError: (any Error)?
    // Set when no persistent store could be opened. The app then shows an error screen instead of the content.
    @State private var storageError: (any Error)?
    // Whether the current container syncs with iCloud. Tells a real toggle from a revert done by the app itself.
    @State private var isSyncActive: Bool

    init() {
        // Read the initial state from UserDefaults before AppStorage is fully available.
        // AppStorage persists in the simulator across app relaunches, so without this
        // reset a UI test that enables sync would leak that state into whichever test
        // runs next on the same simulator. Every UI test run should start from a clean,
        // deterministic "sync off" state regardless of what a previous test left behind.
        #if DEBUG
        let isUITesting = ProcessInfo.processInfo.arguments.contains(where: { $0.hasPrefix("-UI_TESTING") })
        // `-UI_TESTING_SYNC_ENABLED_AT_LAUNCH` lets a test start with sync on, to exercise the launch fallback.
        let startsWithSync = isUITesting && ProcessInfo.processInfo.arguments.contains("-UI_TESTING_SYNC_ENABLED_AT_LAUNCH")
        if isUITesting {
            UserDefaults.standard.set(startsWithSync, forKey: "isICloudSyncEnabled")
        }
        let isScreenshots = MockDataManager.isScreenshotsMode
        let isSyncEnabled = startsWithSync || (!isUITesting && !isScreenshots && UserDefaults.standard.bool(forKey: "isICloudSyncEnabled"))
        #else
        let isSyncEnabled = UserDefaults.standard.bool(forKey: "isICloudSyncEnabled")
        #endif
        let result = Self.openStorage(isICloudSyncEnabled: isSyncEnabled)
        _container = State(initialValue: result.container)
        _containerError = State(initialValue: result.syncError)
        _storageError = State(initialValue: result.storageError)
        _isSyncActive = State(initialValue: result.isICloudSyncActive)
    }

    // Opens the store with the fallbacks from `ContainerBootstrap`.
    static func openStorage(isICloudSyncEnabled: Bool) -> ContainerBootstrapResult {
        do {
            let result = try ContainerBootstrap.open(
                isICloudSyncEnabled: isICloudSyncEnabled,
                makeContainer: { try makeModelContainer(isICloudSyncEnabled: $0) },
                makeInMemoryContainer: { try makeInMemoryContainer() }
            )
            if result.fallback == .localOnly {
                // Keep the saved flag in step with the container that opened, so the Settings toggle is not lying
                // and the app does not retry a broken iCloud store on every launch.
                UserDefaults.standard.set(false, forKey: "isICloudSyncEnabled")
            }
            return result
        } catch {
            // An empty in-memory store failing means the schema itself is invalid. That is a bug in the build,
            // not something the user's device can cause.
            fatalError("Could not create even an in-memory ModelContainer: \(error)")
        }
    }

    // A throwaway store that is never written to disk or synced.
    static func makeInMemoryContainer() throws -> ModelContainer {
        let schema = Schema(versionedSchema: LummiSchemaV1.self)
        let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true, cloudKitDatabase: .none)
        return try ModelContainer(for: schema, migrationPlan: LummiMigrationPlan.self, configurations: [configuration])
    }

    #if DEBUG
    private static var hasSimulatedStoreFailure = false
    #endif

    static func makeModelContainer(isICloudSyncEnabled: Bool) throws -> ModelContainer {
        let schema = Schema(versionedSchema: LummiSchemaV1.self)
        let args = ProcessInfo.processInfo.arguments
        let isUITesting = args.contains(where: { $0.hasPrefix("-UI_TESTING") })

        #if DEBUG
        // `-UI_TESTING_FORCE_STORE_ERROR` makes every attempt fail; the `_ONCE` variant fails only the first one,
        // so a test can tap "Try Again" and see the app recover.
        if args.contains("-UI_TESTING_FORCE_STORE_ERROR")
            || (args.contains("-UI_TESTING_FORCE_STORE_ERROR_ONCE") && !hasSimulatedStoreFailure) {
            hasSimulatedStoreFailure = true
            throw NSError(
                domain: "com.lummi.testing",
                code: -2,
                userInfo: [NSLocalizedDescriptionKey: "Simulated storage failure"]
            )
        }
        if args.contains("-UI_TESTING_FORCE_SYNC_ERROR") && isICloudSyncEnabled {
            throw NSError(
                domain: "com.lummi.testing",
                code: -1,
                userInfo: [NSLocalizedDescriptionKey: "Simulated iCloud sync failure"]
            )
        }
        #endif

        #if DEBUG
        // Screenshots mode also uses a throwaway in-memory store, so real data is never touched.
        let usesInMemoryStore = isUITesting || MockDataManager.isScreenshotsMode
        #else
        let usesInMemoryStore = isUITesting
        #endif

        if usesInMemoryStore {
            return try makeInMemoryContainer()
        }

        let modelConfiguration = ModelConfiguration(
            schema: schema,
            cloudKitDatabase: isICloudSyncEnabled ? .automatic : .none
        )
        return try ModelContainer(for: schema, migrationPlan: LummiMigrationPlan.self, configurations: [modelConfiguration])
    }

    var body: some Scene {
        WindowGroup {
            Group {
                if let storageError {
                    StorageErrorView(error: storageError, onRetry: retryOpeningStorage)
                } else {
                    ContentView(syncError: $containerError)
                }
            }
            .environment(\.locale, Locale(identifier: selectedLanguage.rawValue))
            .onChange(of: isICloudSyncEnabled) { _, newValue in
                // Skips the flag change made below to revert a failed switch, and the one made by a launch fallback.
                guard newValue != isSyncActive else { return }
                do {
                    container = try Self.makeModelContainer(isICloudSyncEnabled: newValue)
                    isSyncActive = newValue
                } catch {
                    // Revert the toggle so AppStorage stays consistent with the actual container state
                    isICloudSyncEnabled = isSyncActive
                    containerError = error
                }
            }
        }
        .modelContainer(container)
    }

    private func retryOpeningStorage() {
        let result = Self.openStorage(isICloudSyncEnabled: isICloudSyncEnabled)
        container = result.container
        isSyncActive = result.isICloudSyncActive
        containerError = result.syncError
        storageError = result.storageError
    }
}
