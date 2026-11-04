//
//  Required Notice: Copyright Evseniia Komarova (https://github.com/ekomarova)
//
//  Licensed under the PolyForm Noncommercial License 1.0.0.
//  See the LICENSE file in the repository root for full terms.
//  <https://polyformproject.org/licenses/noncommercial/1.0.0>
//

import SwiftUI

// Pushed onto the Settings tab's stack, so the system back button and swipe-back gesture work on it.
struct LanguageSelectionView: View {
    @Environment(ThemeManager.self) private var themeManager
    @Environment(\.dismiss) private var dismiss
    @AppStorage(SettingsKey.appLanguage) private var selectedLanguage: AppLanguage = .systemDefault

    var body: some View {
        VStack(spacing: 12) {
            ForEach(AppLanguage.allCases) { language in
                Button(
                    action: {
                        selectedLanguage = language
                        dismiss()
                    },
                    label: {
                        HStack {
                            Text(language.displayName)
                                .lummiScaledFont(size: 17, relativeTo: .body)
                                .foregroundColor(themeManager.currentTheme.textColor)

                            Spacer()

                            if language == selectedLanguage {
                                Image(systemName: "checkmark")
                                    .lummiScaledFont(size: 15, weight: .bold, relativeTo: .subheadline)
                                    .foregroundColor(themeManager.currentTheme.textColor)
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 16)
                        .solidCard(RoundedRectangle(cornerRadius: 16))
                    }
                )
                .buttonStyle(.plain)
                .accessibilityIdentifier("LanguageOption_\(language.rawValue)")
            }

            Spacer()
        }
        .padding(.top, PageSpacing.topBelowList)
        .padding(.horizontal, 20)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .lummiNavigationTitle("Language")
    }
}

#if DEBUG
#Preview {
    NavigationStack {
        LanguageSelectionView()
    }
    .previewEnvironment()
}
#endif
