import SwiftUI

struct DayCell: View {
    let day: Int
    let isFilled: Bool
    let isToday: Bool
    let isSelected: Bool
    
    private var today: Int { Calendar.current.component(.day, from: Date()) }
    
    var body: some View {
        VStack(spacing: 6) {
            ZStack {
                if isSelected {
                    Circle()
                        .fill(Color.white.opacity(0.1))
                        .frame(width: 40, height: 40)
                }
                
                if isFilled {
                    ZStack {
                        Image(systemName: "star.fill")
                            .font(.system(size: 55))
                            .foregroundColor(.yellow.opacity(0.3))
                            .blur(radius: 25)
                        
                        Image(systemName: "star.fill")
                            .font(.system(size: 42))
                            .foregroundColor(.yellow.opacity(0.6))
                            .blur(radius: 8)
                        
                        Image(systemName: "star.fill")
                            .font(.system(size: 32))
                            .foregroundColor(Color(red: 1.0, green: 0.98, blue: 0.8))
                            .blur(radius: 2)
                            .opacity(0.9)
                    }
                    .scaleEffect(x: 1.1, y: 1.0)
                }
                
                Text("\(day)")
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundColor(
                        day > today ? .white.opacity(0.15) :
                        (isToday ? .yellow : .white)
                    )
                    .shadow(color: .black.opacity(isFilled ? 0.7 : 0), radius: 2)
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: 50)
    }
}
