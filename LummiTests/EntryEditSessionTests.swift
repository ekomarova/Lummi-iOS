import Testing
import Foundation
import SwiftData
@testable import Lummi

@MainActor
struct EntryEditSessionTests {

    private struct SaveFailure: Error {}

    // Real identifiers, which only a store can make.
    private func makeIDs(_ count: Int = 2) throws -> [PersistentIdentifier] {
        let configuration = ModelConfiguration(isStoredInMemoryOnly: true, cloudKitDatabase: .none)
        let container = try ModelContainer(for: JoyEntry.self, configurations: configuration)
        let context = ModelContext(container)
        let entries = (0..<count).map { JoyEntry(text: "entry \($0)", date: Date()) }
        entries.forEach { context.insert($0) }
        try context.save()
        return entries.map(\.persistentModelID)
    }

    // MARK: - Selecting

    @Test func newSession_hasNothingSelected() {
        let session = EntryEditSession()
        #expect(session.activeEntryID == nil)
        #expect(!session.hasActiveEntry)
        #expect(!session.isEditing)
        #expect(session.saveAlert == nil)
    }

    @Test func canSelect_onlyOnToday() throws {
        let id = try #require(try makeIDs().first)
        let session = EntryEditSession()
        #expect(session.canSelect(id, isToday: true))
        #expect(!session.canSelect(id, isToday: false))
    }

    @Test func canSelect_isFalseForTheEntryThatIsAlreadySelected() throws {
        let ids = try makeIDs()
        let session = EntryEditSession()
        session.select(ids[0])
        #expect(!session.canSelect(ids[0], isToday: true))
        #expect(session.canSelect(ids[1], isToday: true))
    }

    @Test func select_marksTheEntryActiveWithoutEditing() throws {
        let ids = try makeIDs()
        let session = EntryEditSession()
        session.select(ids[0])
        #expect(session.isActive(ids[0]))
        #expect(!session.isActive(ids[1]))
        #expect(session.hasActiveEntry)
        #expect(!session.isEditing)
    }

    @Test func select_anotherEntryWhileEditing_leavesTheEditMode() throws {
        let ids = try makeIDs()
        let session = EntryEditSession()
        session.select(ids[0])
        session.beginEditing(text: "draft")
        session.select(ids[1])
        #expect(session.isActive(ids[1]))
        #expect(!session.isEditing)
    }

    @Test func beginEditing_fillsTheFieldAndStartsEditing() throws {
        let session = EntryEditSession()
        session.select(try #require(try makeIDs().first))
        session.beginEditing(text: "Coffee")
        #expect(session.isEditing)
        #expect(session.editingText == "Coffee")
    }

    // MARK: - Saving

    @Test func saveAndDismiss_withNothingSelected_doesNothing() {
        let session = EntryEditSession()
        var commits = 0
        session.saveAndDismiss { _, _ in commits += 1 }
        #expect(commits == 0)
        #expect(session.saveAlert == nil)
    }

    @Test func saveAndDismiss_selectedButNotEdited_dropsTheSelectionWithoutSaving() throws {
        let session = EntryEditSession()
        session.select(try #require(try makeIDs().first))
        var commits = 0
        session.saveAndDismiss { _, _ in commits += 1 }
        #expect(commits == 0)
        #expect(!session.hasActiveEntry)
    }

    @Test func saveAndDismiss_whileEditing_commitsTheTextAndDropsTheSelection() throws {
        let id = try #require(try makeIDs().first)
        let session = EntryEditSession()
        session.select(id)
        session.beginEditing(text: "old")
        session.editingText = "new"
        var committed: [(PersistentIdentifier, String)] = []
        session.saveAndDismiss { committed.append(($0, $1)) }
        #expect(committed.count == 1)
        #expect(committed.first?.0 == id)
        #expect(committed.first?.1 == "new")
        #expect(!session.hasActiveEntry)
        #expect(!session.isEditing)
        #expect(session.saveAlert == nil)
    }

    @Test func saveAndDismiss_whenSavingFails_keepsTheEditAndRestoresTheText() throws {
        let id = try #require(try makeIDs().first)
        let session = EntryEditSession()
        session.select(id)
        session.beginEditing(text: "old")
        session.editingText = "new"
        session.saveAndDismiss { _, _ in throw SaveFailure() }
        #expect(session.saveAlert == .editFailed)
        #expect(session.editingText == "old")
        #expect(session.isActive(id))
        #expect(session.isEditing)
    }

    // MARK: - Deleting

    @Test func delete_commitsTheSelectedEntryAndDropsTheSelection() throws {
        let id = try #require(try makeIDs().first)
        let session = EntryEditSession()
        session.select(id)
        var deleted: [PersistentIdentifier] = []
        session.delete { deleted.append($0) }
        #expect(deleted == [id])
        #expect(!session.hasActiveEntry)
        #expect(session.saveAlert == nil)
    }

    @Test func delete_whenItFails_keepsTheEntrySelectedAndRaisesTheAlert() throws {
        let id = try #require(try makeIDs().first)
        let session = EntryEditSession()
        session.select(id)
        session.delete { _ in throw SaveFailure() }
        #expect(session.saveAlert == .deleteFailed)
        #expect(session.isActive(id))
    }

    @Test func delete_withNothingSelected_doesNothing() {
        let session = EntryEditSession()
        var calls = 0
        session.delete { _ in calls += 1 }
        #expect(calls == 0)
    }

    // MARK: - Alert

    @Test func dismissSaveAlert_afterAFailedEdit_leavesTheEditToo() throws {
        let session = EntryEditSession()
        session.select(try #require(try makeIDs().first))
        session.beginEditing(text: "old")
        session.saveAndDismiss { _, _ in throw SaveFailure() }
        session.dismissSaveAlert()
        #expect(session.saveAlert == nil)
        #expect(!session.hasActiveEntry)
        #expect(!session.isEditing)
    }

    @Test func dismissSaveAlert_afterAFailedDelete_keepsTheSelection() throws {
        let id = try #require(try makeIDs().first)
        let session = EntryEditSession()
        session.select(id)
        session.delete { _ in throw SaveFailure() }
        session.dismissSaveAlert()
        #expect(session.saveAlert == nil)
        #expect(session.isActive(id))
    }

    @Test func saveAlertKind_hasATitleAndMessageForEveryKind() {
        for kind in [SaveAlertKind.editFailed, .deleteFailed] {
            #expect(!String(localized: kind.title).isEmpty)
            #expect(!String(localized: kind.message).isEmpty)
        }
    }
}
