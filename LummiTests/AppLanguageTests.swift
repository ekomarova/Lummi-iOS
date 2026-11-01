import Testing
import Foundation
@testable import Lummi

struct AppLanguageTests {

    private func name(of language: AppLanguage, in uiLanguage: String) -> String {
        var resource = language.displayName
        resource.locale = Locale(identifier: uiLanguage)
        return String(localized: resource)
    }

    @Test(arguments: [
        ("en", AppLanguage.english, "English"),
        ("en", AppLanguage.russian, "Russian"),
        ("en", AppLanguage.german, "German"),
        ("ru", AppLanguage.english, "Английский"),
        ("ru", AppLanguage.russian, "Русский"),
        ("ru", AppLanguage.german, "Немецкий"),
        ("de", AppLanguage.english, "Englisch"),
        ("de", AppLanguage.russian, "Russisch"),
        ("de", AppLanguage.german, "Deutsch")
    ])
    func displayNameIsTranslatedIntoTheAppLanguage(uiLanguage: String, language: AppLanguage, expected: String) {
        #expect(name(of: language, in: uiLanguage) == expected)
    }

    @Test func everyLanguageHasADistinctNameInEveryAppLanguage() {
        for uiLanguage in AppLanguage.allCases.map(\.rawValue) {
            let names = AppLanguage.allCases.map { name(of: $0, in: uiLanguage) }
            #expect(Set(names).count == AppLanguage.allCases.count)
        }
    }
}
