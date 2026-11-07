//
//  Required Notice: Copyright Evseniia Komarova (https://github.com/ekomarova)
//
//  Licensed under the PolyForm Noncommercial License 1.0.0.
//  See the LICENSE file in the repository root for full terms.
//  <https://polyformproject.org/licenses/noncommercial/1.0.0>
//

import Foundation

// Input rules for the record text field.
enum RecordInputRules {
    static let maxLength = 280
    // How many characters before `maxLength` the counter starts to stand out.
    static let warningThreshold = 20

    static func clamped(_ text: String) -> String {
        text.count > maxLength ? String(text.prefix(maxLength)) : text
    }

    // True once the text is within `warningThreshold` characters of the limit, or past it.
    static func isNearLimit(_ text: String) -> Bool {
        text.count > maxLength - warningThreshold
    }

    // The text as stored: cut to `maxLength`, then stripped of surrounding whitespace and newlines.
    static func normalized(_ text: String) -> String {
        clamped(text).trimmingCharacters(in: .whitespacesAndNewlines)
    }

    // Whether saving `text` stores anything, which is the case exactly when `normalized` is not empty.
    static func canSave(_ text: String) -> Bool {
        !normalized(text).isEmpty
    }
}
