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

// Root view: switches between the top-level screens and owns the theme, navigation and bottom toolbar.
struct ContentView: View {
    var syncError: Binding<(any Error)?> = .constant(nil)

    @State private var themeManager = ThemeManager()
    @Environment(\.modelContext) private var modelContext

    @State private var navigation = NavigationState()
    @State private var isKeyboardVisible = false

    var body: some View {
        GeometryReader { _ in
            ZStack(alignment: .top) {
                themeManager.currentTheme.bgGradient.ignoresSafeArea()
                
                if navigation.isCalendarExpanded {
                    Color.black.opacity(0.001)
                        .ignoresSafeArea()
                        .onTapGesture {
                            withAnimation(.spring(response: 0.35, dampingFraction: 0.82)) {
                                navigation.dismissCalendar()
                            }
                        }
                }

                VStack(spacing: 15) {
                    // MARK: - Header View
                    if navigation.showsHeader {
                        HeaderView(
                            date: navigation.isCalendarExpanded ? navigation.visibleMonth : navigation.selectedDate,
                            isExpanded: navigation.isCalendarExpanded,
                            onTap: {
                                withAnimation(.spring(response: 0.35, dampingFraction: 0.82)) {
                                    navigation.toggleCalendar()
                                }
                            }
                        )
                        .transition(.move(edge: .top).combined(with: .opacity))
                    }
                        
                    switch navigation.screen {
                    case .record:
                        // MARK: - Record Input
                        RecordInput(
                            recordDate: navigation.recordDate(),
                            onDismiss: {
                                withAnimation(.spring(response: 0.35, dampingFraction: 0.82)) {
                                    navigation.closeRecord()
                                }
                            }
                        )
                        .environment(themeManager)
                    case .settings:
                        // MARK: - Settings View
                        SettingsView()
                            .transition(.move(edge: .trailing).combined(with: .opacity))
                    case .insights:
                        // MARK: - Insights View
                        InsightsView(isShowingAllJoys: $navigation.isShowingAllJoys)
                            .transition(.move(edge: .leading).combined(with: .opacity))
                    case .home where navigation.isCalendarExpanded:
                        // MARK: - Calendar View
                        MainCalendarView(
                            selectedDate: $navigation.selectedDate,
                            isCalendarExpanded: $navigation.isCalendarExpanded,
                            visibleMonth: $navigation.visibleMonth
                        )
                        .padding(.horizontal, 8)
                        .padding(.vertical, 18)
                        .frame(maxWidth: AdaptiveLayout.isPad ? 420 : .infinity)
                        .frame(height: 340)
                        .adaptiveGlass(in: RoundedRectangle(cornerRadius: 24))
                        .transition(.move(edge: .top).combined(with: .opacity))
                        .padding(.top, 28)
                        .padding(.horizontal, 20)
                        .onTapGesture { }
                    case .home:
                        // MARK: - Selected Day View
                        SelectedDayDetailView(
                            selectedDate: navigation.selectedDate
                        )
                        .transition(.move(edge: .top).combined(with: .opacity))
                    }
                    
                    Spacer()
                }
                .padding(.top, 8)
                .ignoresSafeArea(.container, edges: .bottom)
            }
            .alert(
                "iCloud Sync Error",
                isPresented: Binding(
                    get: { syncError.wrappedValue != nil },
                    set: { isPresented in
                        if !isPresented { syncError.wrappedValue = nil }
                    }
                )
            ) {
                Button("OK", role: .cancel) {
                    syncError.wrappedValue = nil
                }
            } message: {
                Text(syncError.wrappedValue?.localizedDescription ?? "")
            }

            // Listenen to system keyboard notifications
            .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)) { _ in
                withAnimation(.easeOut(duration: 0.2)) {
                    isKeyboardVisible = true
                }
            }
            .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)) { _ in
                withAnimation(.easeOut(duration: 0.2)) {
                    isKeyboardVisible = false
                }
            }
        }
        .overlay(alignment: .bottom) {
            if !isKeyboardVisible && navigation.showsToolbar {
                HStack(spacing: 16) {
                    // MARK: - Bottom toolbar
                    BottomToolbar(
                        isHomeActive: navigation.isHomeActive(),
                        isInsightsActive: navigation.isInsightsActive,
                        isSettingsActive: navigation.isSettingsActive,
                        onHomeTap: { navigate(to: .home) },
                        onInsightsTap: { navigate(to: .insights) },
                        onSettingsTap: { navigate(to: .settings) }
                    )
                    .frame(maxWidth: .infinity)

                    // MARK: - Record button
                    RecordButton(onTap: { navigate(to: .record) })
                }
                .frame(maxWidth: AdaptiveLayout.isPad ? 420 : .infinity)
                .padding(.horizontal, 16)
                .padding(.bottom, 10)
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .environment(themeManager)
        .preferredColorScheme(themeManager.isDark ? .dark : .light)
        // MARK: For tests only
        .onAppear {
#if DEBUG
            MockDataManager.injectIfNeeded(modelContext: modelContext)
#endif
        }
    }
}

private extension ContentView {
    func navigate(to screen: Screen) {
        withAnimation(.spring(response: 0.35, dampingFraction: 0.82)) {
            navigation.navigate(to: screen)
        }
    }
}

#if DEBUG
#Preview {
    ContentView()
        .modelContainer(PreviewSupport.makeContainer())
}
#endif
