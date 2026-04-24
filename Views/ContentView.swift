import SwiftUI

struct ContentView: View {
    @StateObject private var themeManager = ThemeManager()

    // @State private var joyEntries: [Int: String] = [:]
    // --TEST-- Input
    @State private var joyEntries: [Int: String] = {
        let calendar = Calendar.current
        let today = calendar.component(.day, from: Date())
        
        return [
            (today - 1): "I ate a lot of chips and it was amazing!",
            (today - 2): "Watched a beautiful sunset",
            (today - 4): "I slept a lot",
            //(today): "I watched the starfall"
        ]
    }()
    // --END--
    
    @State private var selectedDay: Int? = Calendar.current.component(.day, from: Date())
    @State private var isShowingSheet = false

    private var today: Int {
        Calendar.current.component(.day, from: Date())
    }

    var body: some View {
        ZStack {
            themeManager.currentTheme.bgGradient.ignoresSafeArea()
            
            VStack(spacing: 15) {
                // --TEST-- Theme switch
                HStack {
                    Spacer()
                    Button(action: { themeManager.isDark.toggle() }) {
                        Image(systemName: themeManager.isDark ? "moon.stars.fill" : "sun.max.fill")
                            .foregroundColor(themeManager.currentTheme.todayColor)
                            .padding()
                            .background(Circle().fill(themeManager.currentTheme.textColor.opacity(0.1)))
                    }
                }
                // --END--
                .padding(.horizontal)
                
                HeaderView()
                
                MainCalendarView(selectedDay: $selectedDay, joyEntries: $joyEntries)
                
                Spacer()
                
                JoyActionArea(
                    selectedDay: selectedDay,
                    today: today,
                    joyEntries: joyEntries,
                    onTap: { isShowingSheet = true }
                )
                .padding(.bottom, 30)
                .padding(.bottom, 30)
            }
        }
        .environmentObject(themeManager)
                .sheet(isPresented: $isShowingSheet) {
                    // Окно записи (можно тоже вынести в компонент)
                    JoyInputSheet(joyEntries: $joyEntries, selectedDay: selectedDay)
                        .environmentObject(themeManager)
        }
    }
}
