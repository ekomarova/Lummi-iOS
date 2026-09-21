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

// Input rules for the record text field.
enum RecordInputRules {
    static let maxLength = 280

    static func clamped(_ text: String) -> String {
        text.count > maxLength ? String(text.prefix(maxLength)) : text
    }

    static func canSave(_ text: String) -> Bool {
        !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
}

// Create / edit / delete / clear rules for entries. Every failed save is rolled back and rethrown,
// so the caller only decides how to show the error.
struct JoyEntryStore {
    enum EditOutcome: Equatable {
        case updated
        case deleted
    }

    let context: ModelContext
    private let save: (ModelContext) throws -> Void

    init(context: ModelContext, save: @escaping (ModelContext) throws -> Void = { try $0.saveOrSimulate() }) {
        self.context = context
        self.save = save
    }

    func add(text: String, date: Date) throws {
        guard RecordInputRules.canSave(text) else { return }
        context.insert(JoyEntry(text: text, date: date))
        try commit()
    }

    func delete(_ entry: JoyEntry) throws {
        context.delete(entry)
        try commit()
    }

    // Saves trimmed `newText`; an empty result deletes the entry.
    @discardableResult
    func applyEdit(to entry: JoyEntry, newText: String) throws -> EditOutcome {
        let trimmed = newText.trimmingCharacters(in: .whitespacesAndNewlines)
        let originalText = entry.text
        let outcome: EditOutcome
        if trimmed.isEmpty {
            context.delete(entry)
            outcome = .deleted
        } else {
            entry.text = trimmed
            outcome = .updated
        }
        do {
            try commit()
        } catch {
            // rollback() does not reliably revert property changes on an already saved model
            if outcome == .updated { entry.text = originalText }
            throw error
        }
        return outcome
    }

    // Deletes every entry in a scratch context with autosave off: on iOS 17 `rollback()` does not
    // bring back bulk-deleted objects, so a failed save would leave the visible context empty.
    // Dropping an unsaved scratch context leaves the main context untouched.
    func clearAll() throws {
        let scratch = ModelContext(context.container)
        scratch.autosaveEnabled = false
        for entry in try scratch.fetch(FetchDescriptor<JoyEntry>()) {
            scratch.delete(entry)
        }
        try save(scratch)
    }

    private func commit() throws {
        do {
            try save(context)
        } catch {
            context.rollback()
            throw error
        }
    }
}
