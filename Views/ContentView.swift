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
                    if !isShowingSettings {
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
                    } else if isCalendarExpanded {
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
                            selectedDate: selectedDate
                        )
                        .environmentObject(themeManager)
                        .transition(.move(edge: .top).combined(with: .opacity))
                    }
                    
                    Spacer()
                }
                .padding(.top, 8)
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
                        onTap: {
                            isCalendarExpanded = false
                            isShowingSheet = true
                        }
                    )
                    .environmentObject(themeManager)
                    
                    HStack {
                        // 2. Home button
                        HomeButton(
                            isActive: !isCalendarExpanded && !isShowingSettings && Calendar.current.isDateInToday(selectedDate ?? Date()),
                            onTap: {
                                withAnimation(.spring(response: 0.35, dampingFraction: 0.82)) {
                                    isShowingSettings = false
                                    isCalendarExpanded = false
                                    selectedDate = Date()
                                    visibleMonth = Date().startOfMonth
                                }
                            }
                        )
                        .environmentObject(themeManager)
                        .padding(.leading, 40)
                        
                        Spacer()
                        
                        // 3. Settings button
                        SettingsButton(
                            isActive: isShowingSettings,
                            onTap: {
                                withAnimation(.spring(response: 0.35, dampingFraction: 0.82)) {
                                    isCalendarExpanded = false
                                    isShowingSettings = true
                                }
                            }
                        )
                        .environmentObject(themeManager)
                        .padding(.trailing, 40)
                    }
                }
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .sheet(isPresented: $isShowingSheet) {
            RecordInput(selectedDate: Date())
                .environmentObject(themeManager)
        }
        .onAppear {
            if ProcessInfo.processInfo.arguments.contains("-UI_TESTING_CALENDAR") && allEntries.isEmpty {
                let today = Date()
                let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: today)!
                let manyDaysAgo = Calendar.current.date(byAdding: .day, value: -32, to: today)!
                
                modelContext.insert(JoyEntry(text: "I ate a lot of chips and it was amazing!", date: yesterday, dateKey: yesterday.stringKey))
                modelContext.insert(JoyEntry(text: "Watched a beautiful sunset", date: manyDaysAgo, dateKey: manyDaysAgo.stringKey))
            }
            if ProcessInfo.processInfo.arguments.contains("-SEED_10_RECORDS") {
                let baseDate = Date()
                let dateString = baseDate.stringKey
                
                let todaysEntriesCount = allEntries.filter { $0.dateKey == dateString }.count
                if todaysEntriesCount == 0 {
                    for i in 0..<10 {
                        let recordDate = Calendar.current.date(byAdding: .second, value: i, to: baseDate)!
                        modelContext.insert(JoyEntry(text: "Record #\(i)", date: recordDate, dateKey: dateString))
                    }
                    try? modelContext.save()
                }
            }
        }
    }
}
