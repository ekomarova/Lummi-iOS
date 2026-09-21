import Testing
import Foundation
import SwiftData
@testable import Lummi

@MainActor
struct JoyEntryStoreTests {

    private struct SaveFailure: Error {}

    private func makeContext() throws -> ModelContext {
        let configuration = ModelConfiguration(isStoredInMemoryOnly: true, cloudKitDatabase: .none)
        let container = try ModelContainer(for: JoyEntry.self, configurations: configuration)
        return ModelContext(container)
    }

    private func store(_ context: ModelContext, failing: Bool = false) -> JoyEntryStore {
        JoyEntryStore(context: context, save: { ctx in
            if failing { throw SaveFailure() }
            try ctx.save()
        })
    }

    private func count(_ context: ModelContext) throws -> Int {
        try context.fetchCount(FetchDescriptor<JoyEntry>())
    }

    // MARK: - RecordInputRules

    @Test func clamped_textAtLimit_isUnchanged() {
        let text = String(repeating: "a", count: RecordInputRules.maxLength)
        #expect(RecordInputRules.clamped(text) == text)
    }

    @Test func clamped_textOverLimit_isTruncatedTo280() {
        let text = String(repeating: "a", count: 300)
        #expect(RecordInputRules.clamped(text).count == 280)
    }

    @Test func clamped_emojiCountsAsOneCharacter() {
        let text = String(repeating: "😀", count: 281)
        #expect(RecordInputRules.clamped(text).count == 280)
    }

    @Test func canSave_emptyAndWhitespaceOnly_isFalse() {
        #expect(!RecordInputRules.canSave(""))
        #expect(!RecordInputRules.canSave("  \n\t "))
        #expect(RecordInputRules.canSave(" joy "))
    }

    // MARK: - add

    @Test func add_validText_persistsEntry() throws {
        let context = try makeContext()
        try store(context).add(text: "Sun", date: Date())
        #expect(try count(context) == 1)
    }

    @Test func add_blankText_insertsNothing() throws {
        let context = try makeContext()
        try store(context).add(text: "   ", date: Date())
        #expect(try count(context) == 0)
    }

    @Test func add_saveFails_rollsBackAndThrows() throws {
        let context = try makeContext()
        #expect(throws: SaveFailure.self) {
            try store(context, failing: true).add(text: "Sun", date: Date())
        }
        #expect(try count(context) == 0)
    }

    // MARK: - delete

    @Test func delete_removesEntry() throws {
        let context = try makeContext()
        let entry = JoyEntry(text: "Sun", date: Date())
        context.insert(entry)
        try context.save()
        try store(context).delete(entry)
        #expect(try count(context) == 0)
    }

    @Test func delete_saveFails_rollsBackAndThrows() throws {
        let context = try makeContext()
        let entry = JoyEntry(text: "Sun", date: Date())
        context.insert(entry)
        try context.save()
        #expect(throws: SaveFailure.self) { try store(context, failing: true).delete(entry) }
        #expect(try count(context) == 1)
    }

    // MARK: - applyEdit

    @Test func applyEdit_nonEmpty_updatesTrimmedText() throws {
        let context = try makeContext()
        let entry = JoyEntry(text: "Old", date: Date())
        context.insert(entry)
        try context.save()
        let outcome = try store(context).applyEdit(to: entry, newText: "  New  ")
        #expect(outcome == .updated)
        #expect(entry.text == "New")
    }

    @Test func applyEdit_blank_deletesEntry() throws {
        let context = try makeContext()
        let entry = JoyEntry(text: "Old", date: Date())
        context.insert(entry)
        try context.save()
        let outcome = try store(context).applyEdit(to: entry, newText: " \n ")
        #expect(outcome == .deleted)
        #expect(try count(context) == 0)
    }

    @Test func applyEdit_saveFails_rollsBackTextAndThrows() throws {
        let context = try makeContext()
        let entry = JoyEntry(text: "Old", date: Date())
        context.insert(entry)
        try context.save()
        #expect(throws: SaveFailure.self) { try store(context, failing: true).applyEdit(to: entry, newText: "New") }
        #expect(entry.text == "Old")
    }

    // MARK: - clearAll

    @Test func clearAll_removesEveryEntry() throws {
        let context = try makeContext()
        for index in 0..<3 { context.insert(JoyEntry(text: "Joy \(index)", date: Date())) }
        try context.save()
        try store(context).clearAll()
        #expect(try count(context) == 0)
    }

    @Test func clearAll_emptyStore_succeeds() throws {
        let context = try makeContext()
        try store(context).clearAll()
        #expect(try count(context) == 0)
    }

    @Test func clearAll_saveFails_keepsEntriesAndThrows() throws {
        let context = try makeContext()
        for index in 0..<3 { context.insert(JoyEntry(text: "Joy \(index)", date: Date())) }
        try context.save()
        #expect(throws: SaveFailure.self) { try store(context, failing: true).clearAll() }
        #expect(try count(context) == 3)
    }
}
