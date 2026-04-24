import SwiftUI

struct RecordButton: View {
    let selectedDay: Int?
    let today: Int
    let joyEntries: [Int: String]
    var onTap: () -> Void
    
    var body: some View {
        Group {
            if let selected = selectedDay {
                if selected > today {
                    VStack(spacing: 12) {
                        Image(systemName: "moon.stars.fill")
                            .font(.system(size: 40))
                            .foregroundColor(.white.opacity(0.2))
                        
                        Text("Oops! This day has not started yet")
                            .font(.system(size: 16, weight: .bold, design: .rounded))
                            .foregroundColor(.white.opacity(0.6))
                        
                        Text("✨ Lumens will light up when the time is right ✨")
                            .font(.system(size: 13))
                            .foregroundColor(.white.opacity(0.4))
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity)
                    
                } else if let note = joyEntries[selected] {
                    VStack(alignment: .leading, spacing: 10) {
                        Text(note)
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color.white.opacity(0.07))
                            .cornerRadius(15)
                            .overlay(
                                RoundedRectangle(cornerRadius: 15)
                                    .stroke(Color.white.opacity(0.1), lineWidth: 1)
                            )
                    }
                    .padding(.horizontal)

                } else if selected == today {
                    Button(action: onTap) {
                        HStack(spacing: 12) {
                            Image(systemName: "sparkles")
                            Text("Record the joy")
                        }
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundColor(.black)
                        .padding(.vertical, 18)
                        .frame(maxWidth: .infinity)
                        .background(RoundedRectangle(cornerRadius: 20).fill(Color.yellow))
                    }
                    .padding(.horizontal)
                } else {
                    Text("No records for this day")
                        .font(.system(size: 14, design: .rounded))
                        .foregroundColor(.white.opacity(0.3))
                }
            }
        }
        .animation(.spring(), value: selectedDay)
    }
}
