import Testing
import Foundation
@testable import Lummi

struct RecordInputRulesTests {

    // MARK: - clamped

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

    // MARK: - isNearLimit

    @Test func isNearLimit_belowThreshold_isFalse() {
        let limit = RecordInputRules.maxLength - RecordInputRules.warningThreshold
        #expect(!RecordInputRules.isNearLimit(""))
        #expect(!RecordInputRules.isNearLimit(String(repeating: "a", count: limit)))
    }

    @Test func isNearLimit_pastThresholdAndAtLimit_isTrue() {
        let limit = RecordInputRules.maxLength - RecordInputRules.warningThreshold
        #expect(RecordInputRules.isNearLimit(String(repeating: "a", count: limit + 1)))
        #expect(RecordInputRules.isNearLimit(String(repeating: "a", count: RecordInputRules.maxLength)))
    }

    // MARK: - normalized

    @Test func normalized_trimsAndClamps() {
        #expect(RecordInputRules.normalized("  joy \n") == "joy")
        #expect(RecordInputRules.normalized(" \n ").isEmpty)
        #expect(RecordInputRules.normalized(String(repeating: "a", count: 300)).count == 280)
    }

    @Test func normalized_clampsBeforeTrimming() {
        // The limit applies to the typed text, so the cut can leave only whitespace.
        let text = String(repeating: " ", count: RecordInputRules.maxLength) + "joy"
        #expect(RecordInputRules.normalized(text).isEmpty)
    }

    // MARK: - canSave

    @Test func canSave_emptyAndWhitespaceOnly_isFalse() {
        #expect(!RecordInputRules.canSave(""))
        #expect(!RecordInputRules.canSave("  \n\t "))
        #expect(RecordInputRules.canSave(" joy "))
    }

    // `canSave` and what is stored must agree, so the Save button is never enabled for text that saves nothing.
    @Test func canSave_whitespaceFollowedByTextBeyondTheLimit_isFalse() {
        let text = String(repeating: " ", count: RecordInputRules.maxLength) + "joy"
        #expect(!RecordInputRules.canSave(text))
    }

    @Test(arguments: ["", " ", "\n", "joy", "  joy  ", " \n joy \n ", "😀"])
    func canSave_matchesWhetherNormalizedTextIsEmpty(text: String) {
        #expect(RecordInputRules.canSave(text) == !RecordInputRules.normalized(text).isEmpty)
    }
}
