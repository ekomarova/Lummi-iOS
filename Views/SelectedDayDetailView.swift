import SwiftUI

struct SelectedDayDetailView: View {
    @EnvironmentObject var themeManager: ThemeManager
    
    let selectedDate: Date?
    let joyEntries: [String: [String]]
    
    private var today: Date { Date() }
    
    var body: some View {
        Group {
            if let selected = selectedDate {
                if Calendar.current.startOfDay(for: selected) > Calendar.current.startOfDay(for: today) {
                    VStack(spacing: 12) {
                        Image(systemName: "moon.stars.fill")
                            .font(.system(size: 40))
                            .foregroundColor(themeManager.currentTheme.textColor.opacity(0.2))
                        
                        Text("Oops! This day has not started yet")
                            .font(.system(size: 16, weight: .bold, design: .monospaced))
                            .foregroundColor(themeManager.currentTheme.textColor.opacity(0.6))
                        
                        Text("✨ Lumens will light up when the time is right ✨")
                            .font(.system(size: 13))
                            .foregroundColor(themeManager.currentTheme.textColor.opacity(0.4))
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity)
                    
                } else if let notes = joyEntries[selected.stringKey], !notes.isEmpty {
                    VStack(alignment: .leading, spacing: 10) {
                        ForEach(notes, id: \.self) { note in
                            Text(note)
                                .font(.system(size: 16, weight: .light, design: .monospaced))
                                .foregroundColor(themeManager.currentTheme.textColor)
                                .padding(20)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(
                                    RoundedRectangle(cornerRadius: 20)
                                        .fill(themeManager.currentTheme.textColor.opacity(0.05))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 20)
                                                .stroke(themeManager.currentTheme.textColor.opacity(0.1), lineWidth: 1)
                                        )
                                )
                        }
                    }
                    .padding(.horizontal)

                } else {
                    Text("No records for this day")
                        .font(.system(size: 14, design: .monospaced))
                        .foregroundColor(themeManager.currentTheme.textColor.opacity(0.3))
                        .frame(maxWidth: .infinity)
                }
            }
        }
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: selectedDate)
    }
}
