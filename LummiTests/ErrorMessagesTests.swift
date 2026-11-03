import Testing
import Foundation
@testable import Lummi

struct ErrorMessagesTests {

    private let diskFull = NSError(domain: NSCocoaErrorDomain, code: NSFileWriteOutOfSpaceError)
    private let other = NSError(domain: NSCocoaErrorDomain, code: 134_110)

    @Test func storageExplanation_forFullDevice_differsFromGeneral() {
        #expect(ErrorMessages.storageExplanation(for: diskFull) != ErrorMessages.storageExplanation(for: other))
    }

    @Test func storageExplanation_forOtherErrors_isTheSame() {
        let another = NSError(domain: "Test", code: 1)

        #expect(ErrorMessages.storageExplanation(for: other) == ErrorMessages.storageExplanation(for: another))
    }

    @Test func syncAlert_forFullDevice_differsFromGeneral() {
        #expect(ErrorMessages.syncAlert(for: diskFull) != ErrorMessages.syncAlert(for: other))
    }

    @Test func syncAlert_withoutError_isGeneral() {
        #expect(ErrorMessages.syncAlert(for: nil) == ErrorMessages.syncAlert(for: other))
    }

    // The keys must match the String Catalog exactly, or the ru and de translations would silently not apply.
    @Test func keys_matchStringCatalogEntries() {
        #expect(ErrorMessages.storageExplanation(for: diskFull).key == """
            Your device is out of storage, so Lummi couldn't open its storage. Your joys haven't been deleted. Free up some space and try again.
            """.replacingOccurrences(of: "\n", with: " "))
    }
}
