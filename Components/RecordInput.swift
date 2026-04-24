import SwiftUI

struct RecordInput: View {
    @EnvironmentObject var themeManager: ThemeManager
    @Environment(\.dismiss) var dismiss
    
    @Binding var joyEntries: [Int: String]
    let selectedDay: Int?
    
    @State private var text: String = ""

    
    var body: some View {
        NavigationView {
            ZStack {
                themeManager.currentTheme.bgGradient.ignoresSafeArea()
                
                VStack(spacing: 25) {
                    Text("What made you happy?")
                        .font(.system(size: 24, weight: .bold, design: .monospaced))
                        .foregroundColor(themeManager.currentTheme.textColor)
                        .padding(.top, 40)
                    
                    // Text input field
                    TextEditor(text: $text)
                        .frame(height: 150)
                        .padding()
                        .scrollContentBackground(.hidden)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(themeManager.currentTheme.textColor.opacity(0.1))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 20)
                                        .stroke(themeManager.currentTheme.textColor.opacity(0.2), lineWidth: 1)
                                )
                        )
                        .foregroundColor(themeManager.currentTheme.textColor)
                        .font(.system(size: 18, weight: .light, design: .monospaced))
                    
                    // Save button
                    Button(action: {
                        if let day = selectedDay, !text.isEmpty {
                            joyEntries[day] = text
                            dismiss()
                        }
                    }) {
                        Text("Lume the Star ✨")
                            .font(.system(size: 18, weight: .bold, design: .monospaced))
                            .foregroundColor(themeManager.currentTheme.textColor)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(themeManager.currentTheme.todayColor)
                                    .shadow(color: themeManager.currentTheme.todayColor, radius: 10)
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
                        .foregroundColor(themeManager.currentTheme.textColor.opacity(0.6))
                }
            }
        }
    }
}
