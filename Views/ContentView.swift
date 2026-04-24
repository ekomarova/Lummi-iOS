import SwiftUI

struct ContentView: View {
    @State private var selectedDay: Int? = Calendar.current.component(.day, from: Date())
    @State private var joyEntries: [Int: String] = [:]

    private var today: Int {
        Calendar.current.component(.day, from: Date())
    }

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color(red: 0.05, green: 0.05, blue: 0.15), .black],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            VStack(spacing: 30) {
                HeaderView()
                MainCalendarView(selectedDay: $selectedDay, joyEntries: $joyEntries)
                Spacer()
                RecordButton(
                    selectedDay: selectedDay,
                    today: today,
                    joyEntries: joyEntries,
                    onTap: {
                        // [ADD] Tap logic
                    }
                )
            }
            .padding()
        }
    }
}
