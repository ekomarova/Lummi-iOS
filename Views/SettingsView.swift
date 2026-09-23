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
    @State private var showClearDataFailedAlert: Bool = false
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
        VStack(alignment: .leading, spacing: 15) {
            Text("Settings")
                .font(.lummiFont(size: 24, weight: .bold))
                .foregroundColor(themeManager.currentTheme.textColor)
                .padding(.top, 10)
                .padding(.horizontal, 20)

            ScrollView(showsIndicators: false) {
                settingsSections
                    .padding(.horizontal, 20)
                    .padding(.bottom, 100)
            }
            .ignoresSafeArea(.container, edges: .bottom)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
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
        .alert("Clear All Data?", isPresented: $showClearDataAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                clearAllData()
            }
        } message: {
            Text("This will permanently delete all your entries locally and in iCloud!")
        }
        .alert("Failed to Delete", isPresented: $showClearDataFailedAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("Your entries could not be deleted. Please try again.")
        }
    }

    private var settingsSections: some View {
        VStack(alignment: .leading, spacing: 30) {
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
                        action: { themeManager.isDark = false }
                    )

                    ThemeOptionButton(
                        title: "Dark",
                        isSelected: themeManager.isDark,
                        accessibilityID: "DarkThemeButton",
                        action: { themeManager.isDark = true }
                    )
                }
                .padding(.vertical, 20)
                .cardBackground(RoundedRectangle(cornerRadius: 20))
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
                        CapsuleRow {
                            HStack {
                                Text(selectedLanguage.displayName)
                                    .font(.lummiFont(size: 17))
                                    .foregroundColor(themeManager.currentTheme.textColor)

                                Spacer()

                                Image(systemName: "chevron.right")
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundColor(themeManager.currentTheme.textColor.opacity(0.6))
                            }
                        }
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

                CapsuleRow {
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
                                    isICloudSyncEnabled = newValue
                                }
                            )
                        )
                        .labelsHidden()
                        .toggleStyle(.switch)
                        .accessibilityIdentifier("iCloudSyncToggle")
                    }
                }

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
                        CapsuleRow {
                            Text("Delete")
                                .font(.lummiFont(size: 17))
                                .foregroundColor(Color(red: 0.95, green: 0.2, blue: 0.3))
                        }
                    }
                )
                .buttonStyle(.plain)
                .accessibilityIdentifier("ClearAllDataButton")
            }
        }
    }

    // MARK: - Actions
    
    private func clearAllData() {
        do {
            try JoyEntryStore(context: modelContext).clearAll()
        } catch {
            print("Failed to clear data: \(error)")
            withAnimation { showClearDataFailedAlert = true }
        }
    }
}

struct LanguageSelectionView: View {
    @Environment(ThemeManager.self) private var themeManager
    @Binding var selectedLanguage: AppLanguage
    @Binding var isShowingLanguageSelection: Bool

    var body: some View {
        VStack(spacing: 0) {
            ScreenHeader(
                title: "Language",
                leftButton: {
                    NavigationIconButton(systemImage: "arrow.left", accessibilityID: "LanguageSelectionBackButton") {
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.82)) {
                            isShowingLanguageSelection = false
                        }
                    }
                }
            )

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
                            .cardBackground(RoundedRectangle(cornerRadius: 16))
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

#if DEBUG
#Preview {
    SettingsView()
        .previewEnvironment()
}

#Preview {
    LanguageSelectionView(selectedLanguage: .constant(.english), isShowingLanguageSelection: .constant(true))
        .previewEnvironment()
}
#endif
