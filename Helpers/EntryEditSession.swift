//
//  Required Notice: Copyright Evseniia Komarova (https://github.com/ekomarova)
//
//  Licensed under the PolyForm Noncommercial License 1.0.0.
//  See the LICENSE file in the repository root for full terms.
//  <https://polyformproject.org/licenses/noncommercial/1.0.0>
//

import Foundation
import Observation
import SwiftData

// What went wrong when a change to an entry could not be saved.
enum SaveAlertKind: Equatable {
    case editFailed
    case deleteFailed

    var title: LocalizedStringResource {
        switch self {
        case .editFailed: return "Failed to Save"
        case .deleteFailed: return "Failed to Delete"
        }
    }

    var message: LocalizedStringResource {
        switch self {
        case .editFailed: return "Your changes could not be saved. Please try again."
        case .deleteFailed: return "Your record could not be deleted. Please try again."
        }
    }
}

// The edit flow of one day's page: which entry is selected, whether it is being edited, the text in the field and the
// alert after a failed save. The view only draws this and reports taps. Writing to the store is passed in as a closure,
// so the rules can be tested without one.
@MainActor
@Observable
final class EntryEditSession {
    private(set) var activeEntryID: PersistentIdentifier?
    private(set) var isEditing = false
    var editingText = ""
    var saveAlert: SaveAlertKind?

    // The text when editing began, put back in the field if saving fails.
    private var originalText = ""

    var hasActiveEntry: Bool { activeEntryID != nil }

    func isActive(_ id: PersistentIdentifier) -> Bool {
        activeEntryID == id
    }

    // Only today's entries can be changed, and an entry that is already selected stays as it is.
    func canSelect(_ id: PersistentIdentifier, isToday: Bool) -> Bool {
        isToday && activeEntryID != id
    }

    // Selects the entry, which shows its Edit and Delete buttons. Whatever was selected before is dropped, so save it
    // first with `saveAndDismiss`.
    func select(_ id: PersistentIdentifier) {
        activeEntryID = id
        isEditing = false
    }

    func beginEditing(text: String) {
        originalText = text
        editingText = text
        isEditing = true
    }

    // Saves the edit, if there is one, and drops the selection. When saving fails, the selection and the edit stay,
    // the field gets its old text back and the alert is raised.
    func saveAndDismiss(commit: (PersistentIdentifier, String) throws -> Void) {
        guard let id = activeEntryID else { return }

        if isEditing {
            do {
                try commit(id, editingText)
            } catch {
                editingText = originalText
                saveAlert = .editFailed
                return
            }
        }
        dismiss()
    }

    // Deletes the selected entry. When that fails, the entry stays selected and the alert is raised.
    func delete(commit: (PersistentIdentifier) throws -> Void) {
        guard let id = activeEntryID else { return }

        do {
            try commit(id)
            dismiss()
        } catch {
            saveAlert = .deleteFailed
        }
    }

    // After a failed edit, closing the alert also leaves the edit, so the page is not stuck on text that was not saved.
    func dismissSaveAlert() {
        let kind = saveAlert
        saveAlert = nil
        if kind == .editFailed { dismiss() }
    }

    func dismiss() {
        activeEntryID = nil
        isEditing = false
    }
}
