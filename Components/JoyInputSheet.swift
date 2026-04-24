import SwiftUI

struct JoyInputSheet: View {
    @EnvironmentObject var tm: ThemeManager
    @Environment(\.dismiss) var dismiss
    
    @Binding var joyEntries: [Int: String]
    let selectedDay: Int?
    
    @State private var text: String = ""
    
    private var theme: AppTheme { tm.currentTheme }
    
    var body: some View {
        NavigationView {
            ZStack {
                theme.bgGradient.ignoresSafeArea()
                
                VStack(spacing: 25) {
                    Text("What made you happy?")
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundColor(theme.textColor)
                        .padding(.top, 40)
                    
                    // Text input field
                    TextEditor(text: $text)
                        .frame(height: 150)
                        .padding()
                        .scrollContentBackground(.hidden)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(theme.textColor.opacity(0.1))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 20)
                                        .stroke(theme.textColor.opacity(0.2), lineWidth: 1)
                                )
                        )
                        .foregroundColor(theme.textColor)
                        .font(.system(size: 18, weight: .light, design: .rounded))
                    
                    // Save button
                    Button(action: {
                        if let day = selectedDay, !text.isEmpty {
                            joyEntries[day] = text
                            dismiss()
                        }
                    }) {
                        Text("Lume the Star ✨")
                            .font(.system(size: 18, weight: .bold, design: .rounded))
                            .foregroundColor(tm.isDark ? .black : .white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(theme.todayColor)
                                    .shadow(color: theme.todayColor.opacity(0.4), radius: 10)
                            )
                    }
                    .disabled(text.isEmpty)
                    .opacity(text.isEmpty ? 0.5 : 1.0)
                    
                    Spacer()
                }
                .padding(.horizontal, 20)
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                        .foregroundColor(theme.textColor.opacity(0.6))
                }
            }
        }
    }
}
