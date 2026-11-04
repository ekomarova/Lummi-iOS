//
//  Required Notice: Copyright Evseniia Komarova (https://github.com/ekomarova)
//
//  Licensed under the PolyForm Noncommercial License 1.0.0.
//  See the LICENSE file in the repository root for full terms.
//  <https://polyformproject.org/licenses/noncommercial/1.0.0>
//

import Foundation

// The languages the user can pick for the app in Settings.
enum AppLanguage: String, CaseIterable, Identifiable {
    case english = "en"
    case russian = "ru"
    case german = "de"

    var id: String { self.rawValue }

    // The language used until the user picks one in Settings: the first of the system's preferred languages
    // the app supports, or English when none of them is supported.
    static func preferred(from preferredLanguages: [String] = Locale.preferredLanguages) -> AppLanguage {
        let supported = allCases.map(\.rawValue)
        let match = Bundle.preferredLocalizations(from: supported, forPreferences: preferredLanguages).first
        return match.flatMap(AppLanguage.init(rawValue:)) ?? .english
    }

    static var systemDefault: AppLanguage { preferred() }

    var displayName: LocalizedStringResource {
        switch self {
        case .english: return "English"
        case .russian: return "Russian"
        case .german: return "German"
        }
    }
}
