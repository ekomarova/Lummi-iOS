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

                VStack(spacing: AdaptiveLayout.getSize(for: 15)) {
                    // MARK: - Header View
                    if !isShowingSettings && !isShowingInsights {
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
                        
                    if isShowingSettings {
                        // MARK: - Settings View
                        SettingsView()
                            .transition(.move(edge: .trailing).combined(with: .opacity))
                    } else if isShowingInsights {
                        // MARK: - Insights View
                        InsightsView()
                            .transition(.move(edge: .leading).combined(with: .opacity))
                    } else if isCalendarExpanded {
                        ZStack(alignment: .top) {
                            RoundedRectangle(cornerRadius: AdaptiveLayout.getSize(for: 24))
                                .fill(themeManager.currentTheme.calendarBackground.opacity(0.83))
                                .background(
                                    RoundedRectangle(cornerRadius: AdaptiveLayout.getSize(for: 24))
                                        .fill(.ultraThinMaterial)
                                )
                            
                            // MARK: - Calenadar View
                            MainCalendarView(
                                selectedDate: $selectedDate,
                                isCalendarExpanded: $isCalendarExpanded,
                                visibleMonth: $visibleMonth
                            )
                            .padding(.horizontal, AdaptiveLayout.getSize(for: 8))
                            .padding(.vertical, AdaptiveLayout.getSize(for: 18))
                        }
                        .frame(height: AdaptiveLayout.getSize(for: 340))
                        .transition(.move(edge: .top).combined(with: .opacity))
                        .clipShape(RoundedRectangle(cornerRadius: AdaptiveLayout.getSize(for: 24)))
                        .padding(.top, AdaptiveLayout.getSize(for: 28))
                        .padding(.horizontal, AdaptiveLayout.getSize(for: 20))
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
                .padding(.top, AdaptiveLayout.getSize(for: 8))
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
                                    .textCase(.uppercase)
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
        .safeAreaInset(edge: .bottom, spacing: 0) {
            if !isKeyboardVisible {
                HStack(spacing: 0) {
                    // MARK: - Home button
                    HomeButton(
                        isActive: !isCalendarExpanded && !isShowingSettings && !isShowingInsights &&
                            Calendar.current.isDateInToday(selectedDate ?? Date()),
                        onTap: {
                            withAnimation(.spring(response: 0.35, dampingFraction: 0.82)) {
                                isShowingSettings = false
                                isShowingInsights = false
                                isCalendarExpanded = false
                                selectedDate = Date()
                                visibleMonth = Date().startOfMonth
                            }
                        }
                    )
                    
                    Spacer()
                    
                    // MARK: - Insights button
                    InsightsButton(
                        isActive: isShowingInsights,
                        onTap: {
                            withAnimation(.spring(response: 0.35, dampingFraction: 0.82)) {
                                isShowingSettings = false
                                isCalendarExpanded = false
                                isShowingInsights = true
                            }
                        }
                    )
                    
                    Spacer()
                    
                    // MARK: - Settings button
                    SettingsButton(
                        isActive: isShowingSettings,
                        onTap: {
                            withAnimation(.spring(response: 0.35, dampingFraction: 0.82)) {
                                isShowingInsights = false
                                isCalendarExpanded = false
                                isShowingSettings = true
                            }
                        }
                    )
                    
                    Spacer()
                    
                    // MARK: - Record button
                    RecordButton(
                        selectedDate: selectedDate,
                        onTap: {
                            isCalendarExpanded = false
                            isShowingSheet = true
                        }
                    )
                    .frame(width: AdaptiveLayout.getSize(for: 70))
                }
                .padding(.horizontal, AdaptiveLayout.getSize(for: 40))
                .padding(.bottom, AdaptiveLayout.getSize(for: 10))
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .blur(radius: isShowingSheet ? 10 : 0)
        .animation(.easeInOut(duration: 0.25), value: isShowingSheet)
        .sheet(isPresented: $isShowingSheet) {
            // MARK: - Record Input
            RecordInput(selectedDate: Date())
                .environment(themeManager)
        }
        .environment(themeManager)
        // MARK: For tests only
        .onAppear {
#if DEBUG
            MockDataManager.injectIfNeeded(modelContext: modelContext, allEntries: allEntries)
#endif
        }
    }
}
