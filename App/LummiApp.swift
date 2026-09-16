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

@main
struct LummiApp: App {
    
    @AppStorage("appLanguage") private var selectedLanguage: AppLanguage = .english
    @AppStorage("isICloudSyncEnabled") private var isICloudSyncEnabled: Bool = false

    @State private var container: ModelContainer
    @State private var containerError: (any Error)?

    init() {
        // Read the initial state from UserDefaults before AppStorage is fully available.
        // AppStorage persists in the simulator across app relaunches, so without this
        // reset a UI test that enables sync would leak that state into whichever test
        // runs next on the same simulator. Every UI test run should start from a clean,
        // deterministic "sync off" state regardless of what a previous test left behind.
        #if DEBUG
        let isUITesting = ProcessInfo.processInfo.arguments.contains(where: { $0.hasPrefix("-UI_TESTING") })
        if isUITesting {
            UserDefaults.standard.set(false, forKey: "isICloudSyncEnabled")
        }
        let isSyncEnabled = isUITesting ? false : UserDefaults.standard.bool(forKey: "isICloudSyncEnabled")
        #else
        let isSyncEnabled = UserDefaults.standard.bool(forKey: "isICloudSyncEnabled")
        #endif
        do {
            _container = State(initialValue: try Self.makeModelContainer(isICloudSyncEnabled: isSyncEnabled))
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }

    static func makeModelContainer(isICloudSyncEnabled: Bool) throws -> ModelContainer {
        let schema = Schema([JoyEntry.self])
        let args = ProcessInfo.processInfo.arguments
        let isUITesting = args.contains(where: { $0.hasPrefix("-UI_TESTING") })

        #if DEBUG
        if args.contains("-UI_TESTING_FORCE_SYNC_ERROR") && isICloudSyncEnabled {
            throw NSError(
                domain: "com.lummi.testing",
                code: -1,
                userInfo: [NSLocalizedDescriptionKey: "Simulated iCloud sync failure"]
            )
        }
        #endif
        
        let modelConfiguration: ModelConfiguration
        
        if isUITesting {
            modelConfiguration = ModelConfiguration(
                schema: schema,
                isStoredInMemoryOnly: true,
                cloudKitDatabase: .none
            )
        } else {
            modelConfiguration = ModelConfiguration(
                schema: schema,
                cloudKitDatabase: isICloudSyncEnabled ? .automatic : .none
            )
        }

        return try ModelContainer(for: schema, configurations: [modelConfiguration])
    }

    var body: some Scene {
        WindowGroup {
            ContentView(syncError: $containerError)
                .environment(\.locale, Locale(identifier: selectedLanguage.rawValue))
                .onChange(of: isICloudSyncEnabled) { _, newValue in
                    do {
                        container = try Self.makeModelContainer(isICloudSyncEnabled: newValue)
                    } catch {
                        // Revert the toggle so AppStorage stays consistent with the actual container state
                        isICloudSyncEnabled = !newValue
                        containerError = error
                    }
                }
        }
        .modelContainer(container)
    }
}
