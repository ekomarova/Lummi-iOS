//
//  Copyright (c) 2026, Evseniia Komarova.
//  All rights reserved.
//
//  Licensed under the PolyForm Noncommercial License 1.0.0.
//  See the LICENSE file in the repository root for full terms.
//  <https://polyformproject.org/licenses/noncommercial/1.0.0>
//

import Foundation
import SwiftData

// Save wrapper that lets UI tests simulate a save failure in DEBUG builds.
extension ModelContext {
    func saveOrSimulate() throws {
        #if DEBUG
        if ProcessInfo.processInfo.arguments.contains("-UI_TESTING_SIMULATE_SAVE_FAILURE") {
            struct SimulatedSaveError: LocalizedError {
                let errorDescription: String? = "Simulated save failure"
            }
            throw SimulatedSaveError()
        }
        #endif
        try save()
    }
}
