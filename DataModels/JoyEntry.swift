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

@Model
final class JoyEntry {
    // Unique ID for each record
    var id: UUID = UUID()
    
    // Record text
    @Attribute(.allowsCloudEncryption)
    var text: String = ""
    
    // Date of record creation
    var date: Date = Date()
    
    var dateKey: String { date.stringKey }
    
    init(text: String, date: Date) {
        self.text = text
        self.date = date
    }
}
