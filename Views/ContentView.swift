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
                    colors: [
                        Color(red: 0.25, green: 0.28, blue: 0.45),
                        Color(red: 0.10, green: 0.10, blue: 0.22),
                        Color(red: 0.02, green: 0.02, blue: 0.05),
                        .black
                    ],
                    startPoint: .top,
                    endPoint: .bottom
            )
            .ignoresSafeArea()
            
            VStack(spacing: 15) {
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
