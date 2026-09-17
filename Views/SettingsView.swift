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

    var body: some View {
        ZStack {
            VStack(alignment: .leading, spacing: 30) {
                Text("Settings")
                    .font(.lummiFont(size: 24))
                    .foregroundColor(themeManager.currentTheme.textColor)
                    .padding(.top, 10)
                    .frame(maxWidth: .infinity, alignment: .center)

                // MARK: - Appearance
                HStack {
                    Text("Appearance")
                        .font(.lummiFont(size: 18))
                        .foregroundColor(themeManager.currentTheme.textColor)
                    
                    Spacer()
                    
                    HStack(spacing: 0) {
                        LummiSegmentButton(
                            // Light
                            icon: "sun.max.fill",
                            isSelected: !themeManager.isDark,
                            accessibilityID: "LightThemeButton",
                            action: { withAnimation(.spring()) { themeManager.isDark = false } }
                        )
                        
                        LummiSegmentButton(
                            // Dark
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
                
                // MARK: - iCloud sync
                VStack(spacing: 15) {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("iCloud Sync")
                                .font(.lummiFont(size: 17))
                                .foregroundColor(themeManager.currentTheme.textColor)
                        }
                        
                        Spacer()
                        
                        HStack(spacing: 0) {
                            LummiSegmentButton(
                                icon: "xmark.circle.fill",
                                isSelected: !isICloudSyncEnabled,
                                color: isICloudSyncEnabled ? nil : Color(red: 0.95, green: 0.2, blue: 0.3),
                                accessibilityID: "iCloudDisabledButton",
                                action: { withAnimation(.spring()) { isICloudSyncEnabled = false } }
                            )

                            LummiSegmentButton(
                                icon: "checkmark.circle.fill",
                                isSelected: isICloudSyncEnabled,
                                color: !isICloudSyncEnabled ? nil : Color(red: 0.2, green: 0.9, blue: 0.4),
                                accessibilityID: "iCloudEnabledButton",
                                action: {
                                    syncBannerVisible = false
                                    withAnimation(.spring()) { isICloudSyncEnabled = true }
                                }
                            )
                        }
                        .background(Capsule().fill(themeManager.currentTheme.textColor.opacity(0.05)))
                        .overlay(Capsule().stroke(themeManager.currentTheme.textColor.opacity(0.1), lineWidth: 1))
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
                        .padding(AdaptiveLayout.getSize(for: 15))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(
                            RoundedRectangle(cornerRadius: AdaptiveLayout.getSize(for: 16))
                                .fill(Color.red.opacity(0.8))
                        )
                        .transition(.opacity.combined(with: .scale(scale: 0.95, anchor: .top)))
                        .animation(.spring(), value: syncMonitor.syncState)
                    }
                }
                
                // MARK: - Language
                HStack {
                    Text("Language")
                        .font(.lummiFont(size: 18))
                        .foregroundColor(themeManager.currentTheme.textColor)
                        .accessibilityIdentifier("LanguageLabel")
                    
                    Spacer()
                    
                    ZStack {
                        HStack(spacing: 4) {
                            Text(selectedLanguage.displayName)
                                .font(.lummiFont(size: 17))
                            
                            Image(systemName: "chevron.up.chevron.down")
                                .font(.system(size: 15, weight: .medium))
                        }
                        .foregroundColor(themeManager.currentTheme.textColor)

                        Picker("Language", selection: $selectedLanguage) {
                            ForEach(AppLanguage.allCases) { language in
                                Text(language.displayName)
                                    .tag(language)
                                    .font(.lummiFont(size: 17))
                            }
                        }
                        .pickerStyle(.menu)
                        .tint(.clear)
                        .accessibilityIdentifier("LanguagePicker")
                    }
                }
                
                Spacer()

                // MARK: - Delete all data!
                Button(
                    action: {
                        withAnimation { showClearDataAlert = true }
                    },
                    label: {
                        Text("Clear All Data")
                            .font(.lummiFont(size: 16))
                            .foregroundColor(Color(red: 0.95, green: 0.2, blue: 0.3))
                            .padding(.vertical, 12)
                            .padding(.horizontal, 40)
                            .background(Capsule().fill(Color(red: 0.95, green: 0.2, blue: 0.3).opacity(0.1)))
                            .overlay(Capsule().stroke(Color(red: 0.95, green: 0.2, blue: 0.3), lineWidth: 1))
                    }
                )
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.bottom, 20)
                .accessibilityIdentifier("ClearAllDataButton")
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

struct LummiSegmentButton: View {
    @Environment(ThemeManager.self) private var themeManager
    
    let icon: String
    let isSelected: Bool
    var color: Color?
    let accessibilityID: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.lummiFont(size: 16))
                .foregroundColor(isSelected ? themeManager.currentTheme.backgroundColor : themeManager.currentTheme.textColor.opacity(0.4))
                .frame(width: AdaptiveLayout.getSize(for: 60), height: AdaptiveLayout.getSize(for: 36))
                .background(Capsule().fill(isSelected ? (color ?? themeManager.currentTheme.textColor.opacity(0.85)) : Color.clear))
        }
        .buttonStyle(.plain)
        .accessibilityIdentifier(accessibilityID)
        .accessibilityValue(isSelected ? Text("Selected") : Text("Unselected"))
    }
}
