//
//  Required Notice: Copyright Evseniia Komarova (https://github.com/ekomarova)
//
//  Licensed under the PolyForm Noncommercial License 1.0.0.
//  See the LICENSE file in the repository root for full terms.
//  <https://polyformproject.org/licenses/noncommercial/1.0.0>
//

import SwiftUI
import SwiftData

// Settings screen: theme, language, iCloud sync and clearing data.
struct SettingsView: View {
    @Environment(ThemeManager.self) private var themeManager
    @Environment(\.modelContext) private var modelContext

    // Opens a page on the Settings tab's stack.
    let onNavigate: (Route) -> Void
    
    @AppStorage(SettingsKey.appLanguage) private var selectedLanguage: AppLanguage = .systemDefault
    @AppStorage(SettingsKey.isICloudSyncEnabled) private var isICloudSyncEnabled: Bool = false
    
    @Environment(\.isICloudSyncActive) private var isICloudSyncActive
    // Exists only while iCloud sync is active, so Settings never contacts iCloud with sync off, and every enable checks the account afresh.
    @State private var syncMonitor: CloudKitSyncMonitor?

    @State private var showClearDataAlert: Bool = false
    @State private var showClearDataFailedAlert: Bool = false

    var body: some View {
        TabPage(title: "Settings") {
            settingsSections
        }
        // Follows the confirmed state and not the toggle, so a switch the app reverts after a container error
        // never starts the monitor or shows the banner.
        .task(id: isICloudSyncActive) {
            guard isICloudSyncActive else {
                syncMonitor = nil
                return
            }
            // `.task` runs on every appearance of the screen. Keep the monitor it already has, so coming back to
            // Settings does not reset the state and make the banner blink.
            guard syncMonitor == nil else { return }
            // Started here and not from the banner: the banner is an empty view while the state is fine, and
            // SwiftUI does not run `.task` on an empty view, so the monitor would never learn the account state.
            let monitor = CloudKitSyncMonitor()
            monitor.start()
            syncMonitor = monitor
        }
        .alert("Clear All Data?", isPresented: $showClearDataAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                clearAllData()
            }
        } message: {
            Text("This will permanently delete all your entries locally and in iCloud!")
        }
        .errorAlert("Failed to Delete", message: Text("Your entries could not be deleted. Please try again."), isPresented: $showClearDataFailedAlert)
    }

    private var settingsSections: some View {
        VStack(alignment: .leading, spacing: 30) {
            // MARK: - Appearance
            SectionBlock(title: "Appearance") {
                HStack(spacing: 0) {
                    ForEach(AppearanceMode.displayOrder, id: \.self) { mode in
                        ThemeOptionButton(
                            title: mode.title,
                            isSelected: themeManager.mode == mode,
                            accessibilityID: "\(mode.rawValue.capitalized)ThemeButton",
                            action: { themeManager.mode = mode }
                        )
                    }
                }
                .padding(.vertical, 20)
                .solidCard(RoundedRectangle(cornerRadius: 20))
            }

            // MARK: - Language
            SectionBlock(title: "Language", headerAccessibilityID: "LanguageLabel") {
                DisclosureRow(
                    title: selectedLanguage.displayName,
                    accessibilityID: "LanguageSelectorButton"
                ) {
                    onNavigate(.language)
                }
            }

            // MARK: - Sync
            SectionBlock(title: "Sync") {
                CapsuleRow {
                    HStack {
                        Text("iCloud")
                            .lummiScaledFont(size: 17, relativeTo: .body)
                            .foregroundColor(themeManager.currentTheme.textColor)

                        Spacer()

                        Toggle("iCloud", isOn: $isICloudSyncEnabled)
                        .labelsHidden()
                        .toggleStyle(.switch)
                        .tint(AccentColors.toggleOn)
                        .accessibilityIdentifier("iCloudSyncToggle")
                    }
                }

                // MARK: - iCloud Sync Banner
                if let syncMonitor {
                    SyncStatusBanner(monitor: syncMonitor)
                }
            }

            // MARK: - Clear All Data
            SectionBlock(title: "Data") {
                Button(
                    action: {
                        showClearDataAlert = true
                    },
                    label: {
                        CapsuleRow {
                            Text("Delete")
                                .lummiScaledFont(size: 17, relativeTo: .body)
                                .foregroundColor(AccentColors.destructive)
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
            showClearDataFailedAlert = true
        }
    }
}

private struct SyncStatusBanner: View {
    let monitor: CloudKitSyncMonitor

    var body: some View {
        Group {
            if let syncMessage = monitor.syncState.message {
                HStack(alignment: .top, spacing: 12) {
                    Image(systemName: "exclamationmark.icloud.fill")
                        .lummiScaledFont(size: 20, relativeTo: .title3)
                        .foregroundColor(AccentColors.syncBannerForeground)

                    VStack(alignment: .leading, spacing: 4) {
                        Text(syncMessage)
                            .lummiScaledFont(size: 14, relativeTo: .subheadline)
                            .foregroundColor(AccentColors.syncBannerForeground)
                            .multilineTextAlignment(.leading)
                            .accessibilityIdentifier("SyncBannerMessage")

                        if let detail = monitor.syncState.technicalDetail {
                            Text(verbatim: detail)
                                .lummiScaledFont(size: 12, relativeTo: .caption)
                                .foregroundColor(AccentColors.syncBannerForeground.opacity(0.6))
                                .accessibilityIdentifier("SyncBannerDetail")
                        }
                    }
                }
                .padding(15)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(AccentColors.syncBannerBackground)
                )
                .transition(.opacity.combined(with: .scale(scale: 0.95, anchor: .top)))
            }
        }
        .animation(.lummiSpring, value: monitor.syncState)
    }
}

#if DEBUG
#Preview {
    SettingsView(onNavigate: { _ in })
        .previewEnvironment()
}

#Preview("Largest text") {
    SettingsView(onNavigate: { _ in })
        .dynamicTypeSize(DynamicTypeSize.lummiSupportedRange.upperBound)
        .previewEnvironment()
}

#Preview("Sync banner") {
    let monitor = CloudKitSyncMonitor()
    monitor.syncState = .storageFull
    return SyncStatusBanner(monitor: monitor)
        .padding(20)
        .previewEnvironment()
}
#endif
