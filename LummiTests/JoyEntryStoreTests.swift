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

    // MARK: - add

    @Test func add_validText_persistsEntry() throws {
        let context = try makeContext()
        try store(context).add(text: "Sun", date: Date())
        #expect(try count(context) == 1)
    }

    @Test func add_surroundingWhitespaceAndNewlines_storesTrimmedText() throws {
        let context = try makeContext()
        try store(context).add(text: "\n  Sun  \n", date: Date())
        let entries = try context.fetch(FetchDescriptor<JoyEntry>())
        #expect(entries.map(\.text) == ["Sun"])
    }

    @Test func add_innerWhitespace_isKept() throws {
        let context = try makeContext()
        try store(context).add(text: " Warm \n sun ", date: Date())
        let entries = try context.fetch(FetchDescriptor<JoyEntry>())
        #expect(entries.map(\.text) == ["Warm \n sun"])
    }

    @Test func add_overLimit_cutsTextToMaxLength() throws {
        let context = try makeContext()
        try store(context).add(text: String(repeating: "a", count: RecordInputRules.maxLength + 20), date: Date())
        let entries = try context.fetch(FetchDescriptor<JoyEntry>())
        #expect(entries.map(\.text.count) == [RecordInputRules.maxLength])
    }

    @Test func add_exactlyAtLimit_keepsFullText() throws {
        let context = try makeContext()
        let text = String(repeating: "a", count: RecordInputRules.maxLength)
        try store(context).add(text: text, date: Date())
        let entries = try context.fetch(FetchDescriptor<JoyEntry>())
        #expect(entries.map(\.text) == [text])
    }

    @Test func add_leadingWhitespaceAndOverLimit_matchesNormalizedText() throws {
        let context = try makeContext()
        let input = "  " + String(repeating: "a", count: RecordInputRules.maxLength + 20)
        try store(context).add(text: input, date: Date())
        let entries = try context.fetch(FetchDescriptor<JoyEntry>())
        #expect(entries.map(\.text) == [RecordInputRules.normalized(input)])
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

    @Test func applyEdit_overLimit_cutsTextToMaxLength() throws {
        let context = try makeContext()
        let entry = JoyEntry(text: "Old", date: Date())
        context.insert(entry)
        try context.save()
        let outcome = try store(context).applyEdit(to: entry, newText: String(repeating: "a", count: RecordInputRules.maxLength + 20))
        #expect(outcome == .updated)
        #expect(entry.text.count == RecordInputRules.maxLength)
    }

    @Test func applyEdit_exactlyAtLimit_keepsFullText() throws {
        let context = try makeContext()
        let entry = JoyEntry(text: "Old", date: Date())
        context.insert(entry)
        try context.save()
        let text = String(repeating: "a", count: RecordInputRules.maxLength)
        try store(context).applyEdit(to: entry, newText: text)
        #expect(entry.text == text)
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
