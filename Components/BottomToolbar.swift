//
//  Copyright (c) 2026, Evseniia Komarova.
//  All rights reserved.
//
//  Licensed under the PolyForm Noncommercial License 1.0.0.
//  See the LICENSE file in the repository root for full terms.
//  <https://polyformproject.org/licenses/noncommercial/1.0.0>
//

import SwiftUI

struct BottomToolbar: View {
    @Environment(ThemeManager.self) private var themeManager
    @Namespace private var glassNamespace

    let isHomeActive: Bool
    let isInsightsActive: Bool
    let isSettingsActive: Bool
    let onHomeTap: () -> Void
    let onInsightsTap: () -> Void
    let onSettingsTap: () -> Void

    var body: some View {
        HStack(spacing: 0) {
            tab(
                systemImage: "house.fill", label: "Home",
                isActive: isHomeActive, accessibilityBase: "HomeButton", onTap: onHomeTap
            )
            tab(
                systemImage: "chart.pie.fill", label: "Insights",
                isActive: isInsightsActive, accessibilityBase: "InsightsButton", onTap: onInsightsTap
            )
            tab(
                systemImage: "gearshape.fill", label: "Settings",
                isActive: isSettingsActive, accessibilityBase: "SettingsButton", onTap: onSettingsTap
            )
        }
        .frame(height: 64)
        .adaptiveGlass(in: Capsule())
        .animation(.spring(response: 0.35, dampingFraction: 0.82), value: isHomeActive)
        .animation(.spring(response: 0.35, dampingFraction: 0.82), value: isInsightsActive)
        .animation(.spring(response: 0.35, dampingFraction: 0.82), value: isSettingsActive)
    }

    @ViewBuilder
    private func tab(
        systemImage: String,
        label: LocalizedStringKey,
        isActive: Bool,
        accessibilityBase: String,
        onTap: @escaping () -> Void
    ) -> some View {
        Button(action: onTap) {
            ZStack {
                if isActive {
                    Group {
                        if #available(iOS 26, *) {
                            GlassEffectContainer {
                                Capsule()
                                    .fill(themeManager.currentTheme.recordButtonColor.opacity(0.35))
                                    .glassEffect(.clear, in: Capsule())
                                    .glassEffectID("bottomToolbarSelection", in: glassNamespace)
                            }
                        } else {
                            Capsule()
                                .fill(themeManager.currentTheme.recordButtonColor.opacity(0.35))
                                .background(.ultraThinMaterial)
                                .clipShape(Capsule())
                        }
                    }
                    .padding(4)
                }

                VStack(spacing: 2) {
                    Image(systemName: systemImage)
                        .font(.lummiFont(size: 23))
                    Text(label)
                        .font(.lummiFont(size: 12))
                }
                .foregroundColor(themeManager.currentTheme.textColor)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 64)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityIdentifier(isActive ? "\(accessibilityBase)_Active" : "\(accessibilityBase)_Inactive")
    }
}

#if DEBUG
#Preview("Interactive (Live mode)") {
    @Previewable @State var tab = 0

    VStack {
        Spacer()
        HStack(spacing: 16) {
            BottomToolbar(
                isHomeActive: tab == 0,
                isInsightsActive: tab == 1,
                isSettingsActive: tab == 2,
                onHomeTap: { tab = 0 },
                onInsightsTap: { tab = 1 },
                onSettingsTap: { tab = 2 }
            )
            RecordButton(selectedDate: Date(), onTap: { })
        }
        .padding(.horizontal, 16)
        .padding(.bottom, 10)
    }
    .previewEnvironment()
}
#endif
