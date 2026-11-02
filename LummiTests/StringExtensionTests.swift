import Testing
import Foundation
@testable import Lummi

struct StringExtensionTests {

    @Test func capitalizedFirstLetter_lowercaseWord_capitalizesTheFirstLetter() {
        #expect("september".capitalizedFirstLetter == "September")
    }

    @Test func capitalizedFirstLetter_cyrillicWord_capitalizesTheFirstLetter() {
        #expect("сентябрь".capitalizedFirstLetter == "Сентябрь")
    }

    @Test func capitalizedFirstLetter_alreadyCapitalized_isUnchanged() {
        #expect("Sep".capitalizedFirstLetter == "Sep")
    }

    @Test func capitalizedFirstLetter_restOfTheWord_isLowercased() {
        #expect("mCdONALD".capitalizedFirstLetter == "Mcdonald")
        #expect("ÉCOLE".capitalizedFirstLetter == "École")
    }

    @Test func capitalizedFirstLetter_emptyString_staysEmpty() {
        #expect("".capitalizedFirstLetter == "")
    }

    @Test func capitalizedFirstLetter_singleCharacter_isUppercased() {
        #expect("a".capitalizedFirstLetter == "A")
    }

    @Test func capitalizedFirstLetter_leadingNonLetter_isLeftAlone() {
        #expect("1st".capitalizedFirstLetter == "1st")
        #expect("😀abc".capitalizedFirstLetter == "😀abc")
    }
}
