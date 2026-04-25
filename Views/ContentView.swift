import SwiftUI

struct CalendarFramePreferenceKey: PreferenceKey {
    static var defaultValue: CGRect = .zero
    static func reduce(value: inout CGRect, nextValue: () -> CGRect) {
        value = nextValue()
    }
}

struct ContentView: View {
    @StateObject private var themeManager = ThemeManager()

    // --TEST-- Input
    @State private var joyEntries: [Int: [String]] = {
        let calendar = Calendar.current
        let today = calendar.component(.day, from: Date())
        
        return [
            (today - 1): ["I ate a lot of chips and it was amazing!"],
            (today - 2): ["Watched a beautiful sunset"],
            (today - 4): ["I slept a lot"]
        ]
    }()
    
    // Initial state: folded (false) and selected day is today.
    @State private var selectedDay: Int? = Calendar.current.component(.day, from: Date())
    @State private var isShowingSheet = false
    @State private var isCalendarExpanded = false

    private var today: Int {
        Calendar.current.component(.day, from: Date())
    }

    // Derives the Date to display in the Header based on the selectedDay
    private var displayDate: Date {
        let calendar = Calendar.current
        var components = calendar.dateComponents([.year, .month], from: Date())
        components.day = selectedDay ?? today
        return calendar.date(from: components) ?? Date()
    }

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .top) {
                // 1. Theme Background
                themeManager.currentTheme.bgGradient.ignoresSafeArea()
                
                // 2. Tap-to-Collapse Overlay
                // Only active when the calendar is expanded. It catches taps outside the calendar.
                if isCalendarExpanded {
                    Color.black.opacity(0.001)
                        .ignoresSafeArea()
                        .onTapGesture {
                            withAnimation(.spring(response: 0.35, dampingFraction: 0.82)) {
                                isCalendarExpanded = false
                            }
                        }
                }

                // 3. Main Content
                VStack(spacing: 15) {
                    HeaderView(
                        date: displayDate,
                        isExpanded: isCalendarExpanded,
                        onTap: {
                            withAnimation(.spring(response: 0.35, dampingFraction: 0.82)) {
                                isCalendarExpanded.toggle()
                                // Reset to today when the date button is pressed
                                selectedDay = today
                            }
                        }
                    )
                    .environmentObject(themeManager)

                    if isCalendarExpanded {
                        ZStack(alignment: .top) {
                            RoundedRectangle(cornerRadius: 24)
                                .fill(themeManager.currentTheme.calendarBackground)

                            MainCalendarView(
                                themeManager: themeManager,
                                selectedDay: $selectedDay,
                                joyEntries: $joyEntries,
                                isCalendarExpanded: $isCalendarExpanded
                            )
                            .padding(.horizontal, 8)
                            .padding(.vertical, 18)
                        }
                        .fixedSize(horizontal: false, vertical: true)
                        .transition(.move(edge: .top).combined(with: .opacity))
                        .clipShape(RoundedRectangle(cornerRadius: 24))
                        .padding(.top, 28)
                        .padding(.horizontal, 20)
                        // Prevents taps inside the calendar from triggering the background overlay
                        .onTapGesture { } 
                    } else if selectedDay != nil { 
                        SelectedDayDetailView(
                            selectedDay: selectedDay,
                            today: today,
                            joyEntries: joyEntries
                        )
                        .environmentObject(themeManager)
                        .transition(.move(edge: .top).combined(with: .opacity))
                    }
                    
                    Spacer()
                }
                .padding(.top, 8)

                // 4. Theme toggle button
                Button(action: {
                    isCalendarExpanded = false 
                    themeManager.isDark.toggle()
                    // Reset to today when the theme toggle is pressed
                    selectedDay = today
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
        }
        .environmentObject(themeManager)
        .safeAreaInset(edge: .bottom, spacing: 0) {
            RecordButton(
                selectedDay: selectedDay,
                today: today,
                joyEntries: joyEntries,
                onTap: {
                    isCalendarExpanded = false 
                    // Reset to today when the record button is pressed
                    selectedDay = today
                    isShowingSheet = true
                }
            )
            .environmentObject(themeManager)
        }
        .sheet(isPresented: $isShowingSheet) {
            RecordInput(joyEntries: $joyEntries, selectedDay: selectedDay)
                .environmentObject(themeManager)
        }
    }
}
