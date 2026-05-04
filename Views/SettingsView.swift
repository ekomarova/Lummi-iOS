//
//  Copyright (c) 2026, Evseniia Komarova.
//  All rights reserved.
//
//  Redistribution and use in source and binary forms, with or without
//  modification, are permitted provided that the following conditions are met:
//  - Redistributions of source code must retain the above copyright notice,
//    this list of conditions and the following disclaimer.
//  - Redistributions in binary form must reproduce the above copyright notice,
//    this list of conditions and the following disclaimer in the documentation
//    and/or other materials provided with the distribution.
//  - Neither the name of the copyright holder nor the names of its contributors
//    may be used to endorse or promote products derived from this software
//    without specific prior written permission.
//
//  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
//  AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
//  IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
//  ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
//  LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
//  CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
//  SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
//  INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
//  CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
//  ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF
//  THE POSSIBILITY OF SUCH DAMAGE.
//

import SwiftUI

enum AppLanguage: String, CaseIterable, Identifiable {
    case english = "en"
    case russian = "ru"
    case german = "de"
    
    var id: String { self.rawValue }
    
    var displayName: LocalizedStringKey {
        switch self {
        case .english: return "English"
        case .russian: return "Русский"
        case .german: return "Deutsch"
        }
    }
}

struct SettingsView: View {
    @EnvironmentObject var themeManager: ThemeManager
    
    @AppStorage("appLanguage") private var selectedLanguage: AppLanguage = .english

    var body: some View {
        VStack(alignment: .leading, spacing: 30) {
            Text("Settings")
                .textCase(.uppercase)
                .font(.lummiFont(size: 24))
                .foregroundColor(themeManager.currentTheme.textColor)
                .padding(.top, 10)
                .frame(maxWidth: .infinity, alignment: .center)

            // MARK: - Appearance
            HStack {
                Text("Appearance")
                    .textCase(.uppercase)
                    .font(.lummiFont(size: 18))
                    .foregroundColor(themeManager.currentTheme.textColor)
                
                Spacer()
                
                HStack(spacing: 0) {
                    CompactThemeButton(
                        // Light
                        title: "",
                        icon: "sun.max.fill",
                        isSelected: !themeManager.isDark,
                        accessibilityID: "LightThemeButton",
                        action: { withAnimation(.spring()) { themeManager.isDark = false } }
                    )
                    
                    CompactThemeButton(
                        // Dark
                        title: "",
                        icon: "moon.stars.fill",
                        isSelected: themeManager.isDark,
                        accessibilityID: "DarkThemeButton",
                        action: { withAnimation(.spring()) { themeManager.isDark = true } }
                    )
                }
                .background(
                    Capsule()
                        .fill(themeManager.currentTheme.textColor.opacity(0.05))
                )
                .overlay(
                    Capsule()
                        .stroke(themeManager.currentTheme.textColor.opacity(0.1), lineWidth: 1)
                )
            }
            
            // MARK: - Language
            HStack {
                Text("Language")
                    .textCase(.uppercase)
                    .font(.lummiFont(size: 18))
                    .foregroundColor(themeManager.currentTheme.textColor)
                    .accessibilityIdentifier("LanguageLabel")
                
                Spacer()
                
                Picker("Language", selection: $selectedLanguage) {
                    ForEach(AppLanguage.allCases) { language in
                        Text(language.displayName)
                            .tag(language)
                            .textCase(.uppercase)
                            .font(.lummiFont(size: 17))
                            .foregroundColor(themeManager.currentTheme.textColor)
                    }
                }
                .tint(themeManager.currentTheme.textColor)
                .accessibilityIdentifier("LanguagePicker")
            }
            
            Spacer()
        }
        .padding(.horizontal, 20)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}


struct CompactThemeButton: View {
    @EnvironmentObject var themeManager: ThemeManager
    
    let title: String
    let icon: String
    let isSelected: Bool
    let accessibilityID: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.lummiFont(size: 14))
                Text(title)
                    .font(.lummiFont(size: 14))
                    .lineLimit(1)
                    .fixedSize(horizontal: true, vertical: false)
            }
            .padding(.vertical, 8)
            .padding(.horizontal, 16)
            .foregroundColor(isSelected ? themeManager.currentTheme.backgroundColor : themeManager.currentTheme.textColor.opacity(0.5))
            .background(
                Capsule()
                    .fill(isSelected ? themeManager.currentTheme.textColor : Color.clear)
            )
        }
        .buttonStyle(.plain)
        .accessibilityIdentifier(accessibilityID)
        .accessibilityValue(isSelected ? Text("Selected") : Text("Unselected"))
    }
}
