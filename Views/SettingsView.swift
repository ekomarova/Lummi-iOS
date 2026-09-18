//
//  Copyright (c) 2026, Evseniia Komarova.
//  All rights reserved.
//
//  Licensed under the PolyForm Noncommercial License 1.0.0.
//  See the LICENSE file in the repository root for full terms.
//  <https://polyformproject.org/licenses/noncommercial/1.0.0>
//

import SwiftUI
import SwiftData

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
    @Environment(ThemeManager.self) private var themeManager
    @Environment(\.modelContext) private var modelContext
    
    @AppStorage("appLanguage") private var selectedLanguage: AppLanguage = .english
    @AppStorage("isICloudSyncEnabled") private var isICloudSyncEnabled: Bool = false
    
    @State private var syncMonitor = CloudKitSyncMonitor()
    @State private var syncBannerVisible = false

    @State private var showClearDataAlert: Bool = false
    @State private var isShowingLanguageSelection: Bool = false

    var body: some View {
        if isShowingLanguageSelection {
            LanguageSelectionView(
                selectedLanguage: $selectedLanguage,
                isShowingLanguageSelection: $isShowingLanguageSelection
            )
        } else {
            settingsContent
        }
    }

    private var settingsContent: some View {
        ZStack {
            VStack(alignment: .leading, spacing: 30) {
                Text("Settings")
                    .font(.lummiFont(size: 24, weight: .bold))
                    .foregroundColor(themeManager.currentTheme.textColor)
                    .padding(.top, 10)

                // MARK: - Appearance
                VStack(alignment: .leading, spacing: 15) {
                    Text("Appearance")
                        .font(.lummiFont(size: 20, weight: .bold))
                        .foregroundColor(themeManager.currentTheme.textColor)

                    HStack(spacing: 0) {
                        ThemeOptionButton(
                            title: "Light",
                            isSelected: !themeManager.isDark,
                            accessibilityID: "LightThemeButton",
                            action: { withAnimation(.spring()) { themeManager.isDark = false } }
                        )

                        ThemeOptionButton(
                            title: "Dark",
                            isSelected: themeManager.isDark,
                            accessibilityID: "DarkThemeButton",
                            action: { withAnimation(.spring()) { themeManager.isDark = true } }
                        )
                    }
                    .padding(.vertical, 20)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(themeManager.currentTheme.textColor.opacity(0.05))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(themeManager.currentTheme.textColor.opacity(0.1), lineWidth: 1)
                    )
                }
                
                // MARK: - Language
                VStack(alignment: .leading, spacing: 15) {
                    Text("Language")
                        .font(.lummiFont(size: 20, weight: .bold))
                        .foregroundColor(themeManager.currentTheme.textColor)
                        .accessibilityIdentifier("LanguageLabel")

                    Button(
                        action: {
                            withAnimation(.spring(response: 0.35, dampingFraction: 0.82)) {
                                isShowingLanguageSelection = true
                            }
                        },
                        label: {
                            HStack {
                                Text(selectedLanguage.displayName)
                                    .font(.lummiFont(size: 17))
                                    .foregroundColor(themeManager.currentTheme.textColor)

                                Spacer()

                                Image(systemName: "chevron.right")
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundColor(themeManager.currentTheme.textColor.opacity(0.6))
                            }
                            .frame(minHeight: 31)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 14)
                            .background(
                                Capsule()
                                    .fill(themeManager.currentTheme.textColor.opacity(0.05))
                            )
                            .overlay(
                                Capsule()
                                    .stroke(themeManager.currentTheme.textColor.opacity(0.1), lineWidth: 1)
                            )
                        }
                    )
                    .buttonStyle(.plain)
                    .accessibilityIdentifier("LanguageSelectorButton")
                }

                // MARK: - Sync
                VStack(alignment: .leading, spacing: 15) {
                    Text("Sync")
                        .font(.lummiFont(size: 20, weight: .bold))
                        .foregroundColor(themeManager.currentTheme.textColor)

                    HStack {
                        Text("iCloud")
                            .font(.lummiFont(size: 17))
                            .foregroundColor(themeManager.currentTheme.textColor)

                        Spacer()

                        Toggle(
                            "iCloud",
                            isOn: Binding(
                                get: { isICloudSyncEnabled },
                                set: { newValue in
                                    if newValue { syncBannerVisible = false }
                                    withAnimation(.spring()) { isICloudSyncEnabled = newValue }
                                }
                            )
                        )
                        .labelsHidden()
                        .toggleStyle(.switch)
                        .accessibilityIdentifier("iCloudSyncToggle")
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 14)
                    .background(
                        Capsule()
                            .fill(themeManager.currentTheme.textColor.opacity(0.05))
                    )
                    .overlay(
                        Capsule()
                            .stroke(themeManager.currentTheme.textColor.opacity(0.1), lineWidth: 1)
                    )

                    // MARK: - iCloud Sync Banner
                    if isICloudSyncEnabled && syncBannerVisible, let syncMessage = syncMonitor.syncState.message {
                        HStack(alignment: .top, spacing: 12) {
                            Image(systemName: "exclamationmark.icloud.fill")
                                .font(.system(size: 20))
                                .foregroundColor(.white)

                            Text(syncMessage)
                                .font(.lummiFont(size: 14))
                                .foregroundColor(.white)
                                .multilineTextAlignment(.leading)
                                .accessibilityIdentifier("SyncBannerMessage")
                        }
                        .padding(15)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color.red.opacity(0.8))
                        )
                        .transition(.opacity.combined(with: .scale(scale: 0.95, anchor: .top)))
                        .animation(.spring(), value: syncMonitor.syncState)
                    }
                }

                // MARK: - Clear All Data
                VStack(alignment: .leading, spacing: 15) {
                    Text("Data")
                        .font(.lummiFont(size: 20, weight: .bold))
                        .foregroundColor(themeManager.currentTheme.textColor)

                    Button(
                        action: {
                            withAnimation { showClearDataAlert = true }
                        },
                        label: {
                            Text("Delete")
                                .font(.lummiFont(size: 17))
                                .foregroundColor(Color(red: 0.95, green: 0.2, blue: 0.3))
                                .frame(maxWidth: .infinity, minHeight: 31, alignment: .leading)
                                .padding(.horizontal, 20)
                                .padding(.vertical, 14)
                                .background(
                                    Capsule()
                                        .fill(themeManager.currentTheme.textColor.opacity(0.05))
                                )
                                .overlay(
                                    Capsule()
                                        .stroke(themeManager.currentTheme.textColor.opacity(0.1), lineWidth: 1)
                                )
                        }
                    )
                    .buttonStyle(.plain)
                    .accessibilityIdentifier("ClearAllDataButton")
                }

                Spacer()
            }
            .padding(.horizontal, 20)
            .frame(maxWidth: .infinity, alignment: .leading)
            .blur(radius: showClearDataAlert ? 10 : 0)
            .animation(.easeInOut(duration: 0.25), value: showClearDataAlert)
            .task(id: isICloudSyncEnabled) {
                guard isICloudSyncEnabled else {
                    syncBannerVisible = false
                    return
                }
                // Wait long enough for a container-error revert to complete before
                // allowing the banner to appear, so a failed toggle never flashes the banner.
                try? await Task.sleep(for: .milliseconds(300))
                syncBannerVisible = isICloudSyncEnabled
            }

            if showClearDataAlert {
                Color.black.opacity(0.4)
                    .ignoresSafeArea()
                    .onTapGesture {
                        withAnimation { showClearDataAlert = false }
                    }
                    .zIndex(1)
                
                VStack(spacing: 20) {
                    Text("Clear All Data?")
                        .font(.lummiFont(size: 20))
                        .foregroundColor(themeManager.currentTheme.backgroundColor)
                        .accessibilityIdentifier("ClearDataAlertTitle")
                    
                    Text("This will permanently delete all your entries locally and in iCloud!")
                        .font(.lummiFont(size: 16))
                        .foregroundColor(themeManager.currentTheme.backgroundColor)
                        .multilineTextAlignment(.center)
                    
                    HStack(spacing: 16) {
                        Button(
                            action: {
                                withAnimation { showClearDataAlert = false }
                            },
                            label: {
                                Text("Cancel")
                                    .font(.lummiFont(size: 16))
                                    .foregroundColor(themeManager.currentTheme.backgroundColor)
                                    .padding(.vertical, 12)
                                    .padding(.horizontal, 24)
                                    .background(Capsule().stroke(themeManager.currentTheme.backgroundColor, lineWidth: 1))
                            }
                        )
                        .accessibilityIdentifier("ClearDataCancelButton")
                        
                        Button(
                            action: {
                                clearAllData()
                                withAnimation { showClearDataAlert = false }
                            },
                            label: {
                                Text("Delete")
                                    .font(.lummiFont(size: 16))
                                    .foregroundColor(Color(red: 0.95, green: 0.2, blue: 0.3))
                                    .padding(.vertical, 12)
                                    .padding(.horizontal, 24)
                                    .background(Capsule().fill(themeManager.currentTheme.backgroundColor))
                            }
                        )
                        .accessibilityIdentifier("ClearDataConfirmButton")
                    }
                }
                .padding(24)
                .background(
                    RoundedRectangle(cornerRadius: 24)
                        .fill(themeManager.currentTheme.textColor)
                )
                .padding(40)
                .transition(.scale.combined(with: .opacity))
                .zIndex(2)
            }
        }
    }
    
    // MARK: - Actions
    
    private func clearAllData() {
        do {
            let descriptor = FetchDescriptor<JoyEntry>()
            let entries = try modelContext.fetch(descriptor)
            for entry in entries {
                modelContext.delete(entry)
            }
            try modelContext.save()
        } catch {
            print("Failed to clear data: \(error)")
        }
    }
}

struct LanguageSelectionView: View {
    @Environment(ThemeManager.self) private var themeManager
    @Binding var selectedLanguage: AppLanguage
    @Binding var isShowingLanguageSelection: Bool

    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                Text("Language")
                    .font(.lummiFont(size: 24, weight: .bold))
                    .foregroundColor(themeManager.currentTheme.textColor)
                    .frame(maxWidth: .infinity, alignment: .center)

                HStack {
                    Button(
                        action: {
                            withAnimation(.spring(response: 0.35, dampingFraction: 0.82)) {
                                isShowingLanguageSelection = false
                            }
                        },
                        label: {
                            Circle()
                                .fill(themeManager.currentTheme.textColor.opacity(0.05))
                                .adaptiveGlass(in: Circle())
                                .frame(width: 44, height: 44)
                                .overlay(
                                    Image(systemName: "arrow.left")
                                        .font(.lummiFont(size: 16, weight: .bold))
                                        .foregroundColor(themeManager.currentTheme.textColor)
                                )
                        }
                    )
                    .buttonStyle(.plain)
                    .accessibilityIdentifier("LanguageSelectionBackButton")

                    Spacer()
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 10)

            VStack(spacing: 12) {
                ForEach(AppLanguage.allCases) { language in
                    Button(
                        action: {
                            selectedLanguage = language
                            withAnimation(.spring(response: 0.35, dampingFraction: 0.82)) {
                                isShowingLanguageSelection = false
                            }
                        },
                        label: {
                            HStack {
                                Text(language.displayName)
                                    .font(.lummiFont(size: 17))
                                    .foregroundColor(themeManager.currentTheme.textColor)

                                Spacer()

                                if language == selectedLanguage {
                                    Image(systemName: "checkmark")
                                        .font(.system(size: 15, weight: .bold))
                                        .foregroundColor(themeManager.currentTheme.textColor)
                                }
                            }
                            .padding(.horizontal, 20)
                            .padding(.vertical, 16)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(themeManager.currentTheme.textColor.opacity(0.05))
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(themeManager.currentTheme.textColor.opacity(0.1), lineWidth: 1)
                            )
                        }
                    )
                    .buttonStyle(.plain)
                    .accessibilityIdentifier("LanguageOption_\(language.rawValue)")
                }
            }
            .padding(.top, 30)
            .padding(.horizontal, 20)

            Spacer()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .transition(.move(edge: .trailing).combined(with: .opacity))
    }
}

struct ThemeOptionButton: View {
    @Environment(ThemeManager.self) private var themeManager

    let title: LocalizedStringKey
    let isSelected: Bool
    let accessibilityID: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 12) {
                Text(title)
                    .font(.lummiFont(size: 16))
                    .foregroundColor(themeManager.currentTheme.textColor)

                ZStack {
                    Circle()
                        .fill(isSelected ? Color.blue : Color.clear)
                        .overlay(
                            Circle()
                                .stroke(themeManager.currentTheme.textColor.opacity(isSelected ? 0 : 0.3), lineWidth: 1.5)
                        )

                    Image(systemName: "checkmark")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(.white)
                        .opacity(isSelected ? 1 : 0)
                }
                .frame(width: 26, height: 26)
            }
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(.plain)
        .accessibilityIdentifier(accessibilityID)
        .accessibilityValue(isSelected ? Text("Selected") : Text("Unselected"))
    }
}
