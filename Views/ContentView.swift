import SwiftUI

struct ContentView: View {
    @StateObject private var themeManager = ThemeManager()

    @State private var joyEntries: [String: [String]] = {
        if ProcessInfo.processInfo.arguments.contains("-UI_TESTING_CALENDAR") {
            let today = Date()
            let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: today)!
            let manyDaysAgo = Calendar.current.date(byAdding: .day, value: -32, to: today)!
            
            return [
                yesterday.stringKey: ["I ate a lot of chips and it was amazing!"],
                manyDaysAgo.stringKey: ["Watched a beautiful sunset"]
            ]
        }
        return [:]
    }()

    @State private var visibleMonth: Date = Date().startOfMonth
    
    @State private var selectedDate: Date? = Date()
    @State private var isShowingSheet = false
    @State private var isCalendarExpanded = false
    
    @State private var isKeyboardVisible = false

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

                VStack(spacing: 15) {
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

                    if isCalendarExpanded {
                        ZStack(alignment: .top) {
                            RoundedRectangle(cornerRadius: 24)
                                .fill(themeManager.currentTheme.calendarBackground.opacity(0.83))
                                .background(
                                    RoundedRectangle(cornerRadius: 24)
                                        .fill(.ultraThinMaterial)
                                )

                            MainCalendarView(
                                themeManager: themeManager,
                                selectedDate: $selectedDate,
                                joyEntries: $joyEntries,
                                isCalendarExpanded: $isCalendarExpanded,
                                visibleMonth: $visibleMonth
                            )
                            .padding(.horizontal, 8)
                            .padding(.vertical, 18)
                        }
                        .frame(height: 340)
                        .transition(.move(edge: .top).combined(with: .opacity))
                        .clipShape(RoundedRectangle(cornerRadius: 24))
                        .padding(.top, 28)
                        .padding(.horizontal, 20)
                        .onTapGesture { }
                    } else {
                        SelectedDayDetailView(
                            selectedDate: selectedDate,
                            joyEntries: $joyEntries
                        )
                        .environmentObject(themeManager)
                        .transition(.move(edge: .top).combined(with: .opacity))
                    }
                    
                    Spacer()
                }
                .padding(.top, 8)

                // Theme button
                Button(action: {
                    isCalendarExpanded = false
                    themeManager.isDark.toggle()
                    selectedDate = Date()
                }) {
                    Image(systemName: themeManager.isDark ? "moon.stars.fill" : "sun.max.fill")
                        .foregroundColor(themeManager.currentTheme.dayFilledColor)
                        .padding()
                        .background(Circle().fill(themeManager.currentTheme.textColor.opacity(0.1)))
                }
                .padding(.top, 8)
                .padding(.horizontal)
                .frame(maxWidth: .infinity, alignment: .trailing)
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
                ZStack {
                    // 1. Record button
                    RecordButton(
                        selectedDate: selectedDate,
                        joyEntries: joyEntries,
                        onTap: {
                            isCalendarExpanded = false
                            isShowingSheet = true
                        }
                    )
                    .environmentObject(themeManager)
                    
                    HStack {
                        // 2. Home button
                        HomeButton(
                            isActive: !isCalendarExpanded && Calendar.current.isDateInToday(selectedDate ?? Date()),
                            onTap: {
                                withAnimation(.spring(response: 0.35, dampingFraction: 0.82)) {
                                    isCalendarExpanded = false
                                    selectedDate = Date()
                                    visibleMonth = Date().startOfMonth
                                }
                            }
                        )
                        .environmentObject(themeManager)
                        .padding(.leading, 40)
                        
                        Spacer()
                    }
                }
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .sheet(isPresented: $isShowingSheet) {
            RecordInput(joyEntries: $joyEntries, selectedDate: Date())
                .environmentObject(themeManager)
        }
    }
}
