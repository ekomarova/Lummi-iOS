import SwiftUI

struct ContentView: View {
    @StateObject private var themeManager = ThemeManager()

    // @State private var joyEntries: [Int: String] = [:]
    // --TEST-- Input
    @State private var joyEntries: [Int: [String]] = {
        let calendar = Calendar.current
        let today = calendar.component(.day, from: Date())
        
        return [
            (today - 1): ["I ate a lot of chips and it was amazing!"],
            (today - 2): ["Watched a beautiful sunset"],
            (today - 4): ["I slept a lot"],
            //(today): ["I watched the starfall"]
        ]
    }()
    // --END--
    
    @State private var selectedDay: Int? = Calendar.current.component(.day, from: Date())
    @State private var isShowingSheet = false
    @State private var isCalendarExpanded = false

    private let currentDate = Date()

    private var today: Int {
        Calendar.current.component(.day, from: Date())
    }

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .top) {
                themeManager.currentTheme.bgGradient.ignoresSafeArea()
                
                VStack(spacing: 15) {
                    HeaderView(
                        date: currentDate,
                        isExpanded: isCalendarExpanded,
                        onTap: {
                            withAnimation(.spring(response: 0.35, dampingFraction: 0.82)) {
                                isCalendarExpanded.toggle()
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
                    } else if selectedDay != nil { // Show SelectedDayDetailView when calendar is folded
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

                // Theme toggle button
                Button(action: {
                    isCalendarExpanded = false // Collapse calendar when changing theme for consistency
                    themeManager.isDark.toggle()
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
                    isCalendarExpanded = false // Ensure calendar folds when recording
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
