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
        // When force-error testing, reset sync to off so the synthetic throw only happens
        // on the onChange path (user tapping the toggle), not at startup.
        #if DEBUG
        let isForceSyncError = ProcessInfo.processInfo.arguments.contains("-UI_TESTING_FORCE_SYNC_ERROR")
        if isForceSyncError {
            UserDefaults.standard.set(false, forKey: "isICloudSyncEnabled")
        }
        let isSyncEnabled = isForceSyncError ? false : UserDefaults.standard.bool(forKey: "isICloudSyncEnabled")
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
