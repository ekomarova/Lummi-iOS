import Testing
import Foundation
@testable import Lummi

struct ErrorExtensionTests {

    private enum SampleError: Error {
        case first
        case second
    }

    @Test func technicalCode_ofNSError_isDomainAndCode() {
        let error = NSError(domain: NSCocoaErrorDomain, code: 134_110)

        #expect(error.technicalCode == "NSCocoaErrorDomain 134110")
    }

    @Test func technicalCode_ignoresLocalizedDescription() {
        let error = NSError(
            domain: "Test",
            code: 7,
            userInfo: [NSLocalizedDescriptionKey: "Something technical happened"]
        )

        #expect(error.technicalCode == "Test 7")
    }

    @Test func technicalCode_ofSwiftError_usesBridgedDomainAndCaseIndex() {
        #expect(SampleError.first.technicalCode.hasSuffix(".SampleError 0"))
        #expect(SampleError.second.technicalCode.hasSuffix(".SampleError 1"))
    }

    @Test func technicalCode_ofNegativeCode_keepsSign() {
        let error = NSError(domain: NSURLErrorDomain, code: -1009)

        #expect(error.technicalCode == "NSURLErrorDomain -1009")
    }

    // MARK: - Device storage full

    @Test(arguments: [
        (NSCocoaErrorDomain, NSFileWriteOutOfSpaceError),
        ("NSSQLiteErrorDomain", 13),
        (NSPOSIXErrorDomain, Int(ENOSPC))
    ])
    func isDeviceStorageFull_recognizesOutOfSpaceErrors(domain: String, code: Int) {
        #expect(NSError(domain: domain, code: code).isDeviceStorageFull)
    }

    @Test func isDeviceStorageFull_findsErrorInUnderlyingChain() {
        let outOfSpace = NSError(domain: NSPOSIXErrorDomain, code: Int(ENOSPC))
        let wrapped = NSError(domain: NSCocoaErrorDomain, code: 134_110, userInfo: [NSUnderlyingErrorKey: outOfSpace])

        #expect(wrapped.isDeviceStorageFull)
    }

    @Test func isDeviceStorageFull_isFalseForOtherErrors() {
        #expect(!NSError(domain: NSCocoaErrorDomain, code: 134_110).isDeviceStorageFull)
        #expect(!NSError(domain: "NSSQLiteErrorDomain", code: 14).isDeviceStorageFull)
        #expect(!SampleError.first.isDeviceStorageFull)
    }

    @Test func isDeviceStorageFull_ignoresSameCodeInOtherDomain() {
        #expect(!NSError(domain: "Other", code: 13).isDeviceStorageFull)
    }

    @Test func isDeviceStorageFull_ignoresErrorsBeyondDepthLimit() {
        // A chain deeper than the limit must end without crashing; the out-of-space error sits beyond it.
        var error: NSError = NSError(domain: NSPOSIXErrorDomain, code: Int(ENOSPC))
        for _ in 0..<10 {
            error = NSError(domain: "Wrapper", code: 1, userInfo: [NSUnderlyingErrorKey: error])
        }

        #expect(!error.isDeviceStorageFull)
    }
}
