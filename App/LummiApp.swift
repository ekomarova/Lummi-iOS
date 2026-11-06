//
//  Required Notice: Copyright Evseniia Komarova (https://github.com/ekomarova)
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
    
    @AppStorage(SettingsKey.appLanguage) private var selectedLanguage: AppLanguage = .systemDefault
    @AppStorage(SettingsKey.isICloudSyncEnabled) private var isICloudSyncEnabled: Bool = false

    @State private var container: ModelContainer
    @State private var containerError: (any Error)?
    // Set when no persistent store could be opened. The app then shows an error screen instead of the content.
    @State private var storageError: (any Error)?
    // Whether the current container syncs with iCloud. Tells a real toggle from a revert done by the app itself.
    @State private var isSyncActive: Bool

    init() {
        TabBarAppearance.configure()
        let isSyncEnabled = Self.isSyncEnabledAtLaunch()
        let result = Self.openStorage(isICloudSyncEnabled: isSyncEnabled)
        _container = State(initialValue: result.container)
        _containerError = State(initialValue: result.syncError)
        _storageError = State(initialValue: result.storageError)
        _isSyncActive = State(initialValue: result.isICloudSyncActive)
    }

    // Reads the saved sync preference from UserDefaults before AppStorage is fully available.
    // Debug builds let launch arguments decide instead, see `TestLaunchArguments`.
    private static func isSyncEnabledAtLaunch() -> Bool {
        let storedPreference = UserDefaults.standard.bool(forKey: SettingsKey.isICloudSyncEnabled)
        #if DEBUG
        // AppStorage persists in the simulator across app relaunches, so without this reset a UI test that
        // enables sync would leak that state into whichever test runs next on the same simulator. Every UI test
        // run should start from a clean, deterministic "sync off" state regardless of what a previous test left
        // behind.
        if TestLaunchArguments.isUITesting {
            UserDefaults.standard.set(TestLaunchArguments.syncEnabledAtLaunch.isSet, forKey: SettingsKey.isICloudSyncEnabled)
        }
        return TestLaunchArguments.isSyncEnabledAtLaunch(storedPreference: storedPreference)
        #else
        return storedPreference
        #endif
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
                UserDefaults.standard.set(false, forKey: SettingsKey.isICloudSyncEnabled)
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

        #if DEBUG
        if TestLaunchArguments.forceStoreError.isSet
            || (TestLaunchArguments.forceStoreErrorOnce.isSet && !hasSimulatedStoreFailure) {
            hasSimulatedStoreFailure = true
            throw NSError(
                domain: "com.lummi.testing",
                code: -2,
                userInfo: [NSLocalizedDescriptionKey: "Simulated storage failure"]
            )
        }
        if TestLaunchArguments.forceSyncError.isSet && isICloudSyncEnabled {
            throw NSError(
                domain: "com.lummi.testing",
                code: -1,
                userInfo: [NSLocalizedDescriptionKey: "Simulated iCloud sync failure"]
            )
        }
        #endif

        #if DEBUG
        // UI tests and screenshots mode use a throwaway in-memory store, so real data is never touched.
        // Release builds ignore these launch arguments.
        if TestLaunchArguments.isUITesting || TestLaunchArguments.screenshots.isSet {
            return try makeInMemoryContainer()
        }
        #endif

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
            .environment(\.isICloudSyncActive, isSyncActive)
            .dynamicTypeSize(DynamicTypeSize.lummiSupportedRange)
            .onChange(of: isICloudSyncEnabled) { _, newValue in
                let outcome = SyncToggle.apply(
                    requested: newValue,
                    isActive: isSyncActive,
                    makeContainer: { try Self.makeModelContainer(isICloudSyncEnabled: $0) }
                )
                switch outcome {
                case .unchanged:
                    // The flag change made below to revert a failed switch, or the one made by a launch fallback.
                    break
                case .switched(let newContainer):
                    container = newContainer
                    isSyncActive = newValue
                case .failed(let error):
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
