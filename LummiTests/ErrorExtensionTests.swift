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

    // MARK: - Underlying errors

    private func wrap(_ error: Error, times: Int = 1) -> NSError {
        var wrapped = error
        for level in 0..<times {
            wrapped = NSError(domain: "Wrapper\(level)", code: level, userInfo: [NSUnderlyingErrorKey: wrapped])
        }
        return wrapped as NSError
    }

    @Test func underlyingErrors_ofAnErrorWithoutOne_isJustTheError() {
        let chain = NSError(domain: "Test", code: 1).underlyingErrors()

        #expect(chain.count == 1)
        #expect((chain.first as NSError?)?.domain == "Test")
    }

    @Test func underlyingErrors_listsTheChainOutermostFirst() {
        let inner = NSError(domain: "Inner", code: 3)
        let middle = NSError(domain: "Middle", code: 2, userInfo: [NSUnderlyingErrorKey: inner])
        let outer = NSError(domain: "Outer", code: 1, userInfo: [NSUnderlyingErrorKey: middle])

        let domains = outer.underlyingErrors().map { ($0 as NSError).domain }

        #expect(domains == ["Outer", "Middle", "Inner"])
    }

    @Test func underlyingErrors_ofASwiftError_isJustTheError() {
        #expect(SampleError.first.underlyingErrors().count == 1)
    }

    @Test func underlyingErrors_isCutOffAtTheDefaultDepth() {
        let chain = wrap(NSError(domain: "Bottom", code: 0), times: 20).underlyingErrors()

        #expect(chain.count == maxUnderlyingErrorDepth)
        #expect(!chain.contains { ($0 as NSError).domain == "Bottom" })
    }

    @Test(arguments: [1, 2, 3])
    func underlyingErrors_isCutOffAtTheGivenDepth(maxDepth: Int) {
        let chain = wrap(NSError(domain: "Bottom", code: 0), times: 6).underlyingErrors(maxDepth: maxDepth)

        #expect(chain.count == maxDepth)
    }

    @Test func underlyingErrors_withDepthZero_isEmpty() {
        #expect(NSError(domain: "Test", code: 1).underlyingErrors(maxDepth: 0).isEmpty)
    }

    @Test func underlyingErrors_keepsTheWholeChainWhenItFitsTheDepth() {
        let chain = wrap(NSError(domain: "Bottom", code: 0), times: 3).underlyingErrors(maxDepth: 4)

        #expect(chain.count == 4)
        #expect((chain.last as NSError?)?.domain == "Bottom")
    }

    @Test func underlyingErrors_ignoresAnUnderlyingValueThatIsNotAnError() {
        let error = NSError(domain: "Test", code: 1, userInfo: [NSUnderlyingErrorKey: "not an error"])

        #expect(error.underlyingErrors().count == 1)
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
