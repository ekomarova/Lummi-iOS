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

struct ContentView: View {
    var syncError: Binding<(any Error)?> = .constant(nil)

    @State private var themeManager = ThemeManager()
    @Environment(\.modelContext) private var modelContext
    @Query private var allEntries: [JoyEntry]

    @State private var visibleMonth: Date = Date().startOfMonth
    @State private var selectedDate: Date? = Date()
    @State private var isShowingSheet = false
    @State private var isCalendarExpanded = false
    @State private var isKeyboardVisible = false
    @State private var isShowingSettings = false
    @State private var isShowingInsights = false
    @State private var isShowingAllJoys = false

    var body: some View {
        GeometryReader { _ in
            ZStack(alignment: .top) {
                themeManager.currentTheme.bgGradient.ignoresSafeArea()
                
                if isCalendarExpanded {
                    Color.black.opacity(0.001)
                        .ignoresSafeArea()
                        .onTapGesture {
                            withAnimation(.spring(response: 0.35, dampingFraction: 0.82)) {
                                isCalendarExpanded = false
                                selectedDate = Date()
                                visibleMonth = Date().startOfMonth
                            }
                        }
                }

                VStack(spacing: 15) {
                    // MARK: - Header View
                    if !isShowingSettings && !isShowingInsights && !isShowingSheet {
                        HeaderView(
                            date: isCalendarExpanded ? visibleMonth : (selectedDate ?? Date()),
                            isExpanded: isCalendarExpanded,
                            onTap: {
                                withAnimation(.spring(response: 0.35, dampingFraction: 0.82)) {
                                    isCalendarExpanded.toggle()
                                    if !isCalendarExpanded {
                                        visibleMonth = (selectedDate ?? Date()).startOfMonth
                                    }
                                }
                            }
                        )
                        .transition(.move(edge: .top).combined(with: .opacity))
                    }
                        
                    if isShowingSheet {
                        // MARK: - Record Input
                        RecordInput(
                            selectedDate: Date(),
                            onDismiss: {
                                withAnimation(.spring(response: 0.35, dampingFraction: 0.82)) {
                                    isShowingSheet = false
                                }
                            }
                        )
                        .environment(themeManager)
                    } else if isShowingSettings {
                        // MARK: - Settings View
                        SettingsView()
                            .transition(.move(edge: .trailing).combined(with: .opacity))
                    } else if isShowingInsights {
                        // MARK: - Insights View
                        InsightsView(isShowingAllJoys: $isShowingAllJoys)
                            .transition(.move(edge: .leading).combined(with: .opacity))
                    } else if isCalendarExpanded {
                        // MARK: - Calenadar View
                        MainCalendarView(
                            selectedDate: $selectedDate,
                            isCalendarExpanded: $isCalendarExpanded,
                            visibleMonth: $visibleMonth
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
                    } else {
                        // MARK: - Selected Day View
                        SelectedDayDetailView(
                            selectedDate: selectedDate
                        )
                        .transition(.move(edge: .top).combined(with: .opacity))
                    }
                    
                    Spacer()
                }
                .padding(.top, 8)
                .ignoresSafeArea(.container, edges: .bottom)
                .blur(radius: syncError.wrappedValue != nil ? 10 : 0)
                .animation(.easeInOut(duration: 0.25), value: syncError.wrappedValue == nil)

                // MARK: - iCloud Sync Error Overlay
                if let error = syncError.wrappedValue {
                    Color.black.opacity(0.4)
                        .ignoresSafeArea()
                        .onTapGesture {
                            withAnimation { syncError.wrappedValue = nil }
                        }
                        .zIndex(1)

                    VStack {
                        Spacer()
                        VStack(spacing: 20) {
                            Image(systemName: "icloud.slash.fill")
                                .font(.system(size: 32))
                                .foregroundColor(themeManager.currentTheme.backgroundColor)

                            Text("iCloud Sync Error")
                                .font(.lummiFont(size: 20))
                                .foregroundColor(themeManager.currentTheme.backgroundColor)
                                .accessibilityIdentifier("SyncErrorAlertTitle")

                            Text(error.localizedDescription)
                                .font(.lummiFont(size: 16))
                                .foregroundColor(themeManager.currentTheme.backgroundColor)
                                .multilineTextAlignment(.center)

                            Button {
                                withAnimation { syncError.wrappedValue = nil }
                            } label: {
                                Text("OK")
                                    .font(.lummiFont(size: 16))
                                    .foregroundColor(themeManager.currentTheme.backgroundColor)
                                    .padding(.vertical, 12)
                                    .padding(.horizontal, 40)
                                    .background(Capsule().stroke(themeManager.currentTheme.backgroundColor, lineWidth: 1))
                            }
                            .buttonStyle(.plain)
                            .accessibilityIdentifier("SyncErrorAlertOKButton")
                        }
                        .padding(24)
                        .background(
                            RoundedRectangle(cornerRadius: 24)
                                .fill(themeManager.currentTheme.textColor)
                        )
                        .padding(40)
                        Spacer()
                    }
                    .transition(.scale.combined(with: .opacity))
                    .zIndex(2)
                }
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
            if !isKeyboardVisible && !isShowingSheet {
                HStack(spacing: 16) {
                    // MARK: - Bottom toolbar
                    BottomToolbar(
                        isHomeActive: !isCalendarExpanded && !isShowingSettings && !isShowingInsights && !isShowingSheet &&
                            Calendar.current.isDateInToday(selectedDate ?? Date()),
                        isInsightsActive: isShowingInsights && !isShowingAllJoys,
                        isSettingsActive: isShowingSettings,
                        onHomeTap: {
                            withAnimation(.spring(response: 0.35, dampingFraction: 0.82)) {
                                isShowingSheet = false
                                isShowingSettings = false
                                isShowingInsights = false
                                isShowingAllJoys = false
                                isCalendarExpanded = false
                                selectedDate = Date()
                                visibleMonth = Date().startOfMonth
                            }
                        },
                        onInsightsTap: {
                            withAnimation(.spring(response: 0.35, dampingFraction: 0.82)) {
                                isShowingSheet = false
                                isShowingSettings = false
                                isCalendarExpanded = false
                                isShowingInsights = true
                                isShowingAllJoys = false
                            }
                        },
                        onSettingsTap: {
                            withAnimation(.spring(response: 0.35, dampingFraction: 0.82)) {
                                isShowingSheet = false
                                isShowingInsights = false
                                isShowingAllJoys = false
                                isCalendarExpanded = false
                                isShowingSettings = true
                            }
                        }
                    )
                    .frame(maxWidth: .infinity)

                    // MARK: - Record button
                    RecordButton(
                        selectedDate: selectedDate,
                        onTap: {
                            withAnimation(.spring(response: 0.35, dampingFraction: 0.82)) {
                                isCalendarExpanded = false
                                isShowingSheet = true
                            }
                        }
                    )
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
            MockDataManager.injectIfNeeded(modelContext: modelContext, allEntries: allEntries)
#endif
        }
    }
}
