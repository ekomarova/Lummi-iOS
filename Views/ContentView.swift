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
    @StateObject private var themeManager = ThemeManager()
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
        GeometryReader { geometry in
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
                        .environmentObject(themeManager)
                        .transition(.move(edge: .top).combined(with: .opacity))
                    }
                        
                    if isShowingSettings {
                        SettingsView()
                            .environmentObject(themeManager)
                            .transition(.move(edge: .trailing).combined(with: .opacity))
                    } else if isShowingInsights {
                        InsightsView()
                            .environmentObject(themeManager)
                            .transition(.move(edge: .leading).combined(with: .opacity))
                    } else if isCalendarExpanded {
                        ZStack(alignment: .top) {
                            RoundedRectangle(cornerRadius: AdaptiveLayout.getSize(for: 24))
                                .fill(themeManager.currentTheme.calendarBackground.opacity(0.83))
                                .background(
                                    RoundedRectangle(cornerRadius: AdaptiveLayout.getSize(for: 24))
                                        .fill(.ultraThinMaterial)
                                )
                            
                            MainCalendarView(
                                themeManager: themeManager,
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
                        SelectedDayDetailView(
                            selectedDate: selectedDate
                        )
                        .environmentObject(themeManager)
                        .transition(.move(edge: .top).combined(with: .opacity))
                    }
                    
                    Spacer()
                }
                .padding(.top, AdaptiveLayout.getSize(for: 8))
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
        .environmentObject(themeManager)
        .safeAreaInset(edge: .bottom, spacing: 0) {
            if !isKeyboardVisible {
                HStack(spacing: 0) {
                    // Home button
                    HomeButton(
                        isActive: !isCalendarExpanded && !isShowingSettings && !isShowingInsights && Calendar.current.isDateInToday(selectedDate ?? Date()),
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
                    .environmentObject(themeManager)
                    
                    Spacer()
                    
                    // Insights button
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
                    .environmentObject(themeManager)
                    
                    Spacer()
                    
                    // Settings button
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
                    .environmentObject(themeManager)
                    
                    Spacer()
                    
                    // Record button
                    RecordButton(
                        selectedDate: selectedDate,
                        onTap: {
                            isCalendarExpanded = false
                            isShowingSheet = true
                        }
                    )
                    .environmentObject(themeManager)
                    .frame(width: AdaptiveLayout.getSize(for: 70))
                }
                .padding(.horizontal, AdaptiveLayout.getSize(for: 40))
                .padding(.bottom, AdaptiveLayout.getSize(for: 10))
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .sheet(isPresented: $isShowingSheet) {
            RecordInput(selectedDate: Date())
                .environmentObject(themeManager)
        }
        // MARK: For tests only
        .onAppear {
            MockDataManager.injectIfNeeded(modelContext: modelContext, allEntries: allEntries)
            }
        }
    }
