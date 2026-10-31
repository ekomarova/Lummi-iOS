import Testing
import SwiftUI
@testable import Lummi

struct FontExtensionTests {

    @Test func supportedRange_includesDefaultSize() {
        #expect(DynamicTypeSize.lummiSupportedRange.contains(.large))
    }

    @Test func supportedRange_coversEverySliderStep() {
        #expect(DynamicTypeSize.lummiSupportedRange.contains(.xSmall))
        #expect(DynamicTypeSize.lummiSupportedRange.contains(.xxxLarge))
    }

    @Test func supportedRange_includesFirstTwoAccessibilitySizes() {
        #expect(DynamicTypeSize.lummiSupportedRange.contains(.accessibility1))
        #expect(DynamicTypeSize.lummiSupportedRange.contains(.accessibility2))
    }

    @Test func supportedRange_excludesLargerAccessibilitySizes() {
        #expect(!DynamicTypeSize.lummiSupportedRange.contains(.accessibility3))
        #expect(!DynamicTypeSize.lummiSupportedRange.contains(.accessibility5))
    }
}
