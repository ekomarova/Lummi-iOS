import SwiftUI
import SwiftData

struct RecordInput: View {
    @EnvironmentObject var themeManager: ThemeManager
    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) private var modelContext
    
    let selectedDate: Date?
    
    @State private var text: String = ""

    var isSaveEnabled: Bool {
        !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var body: some View {
        NavigationView {
            ZStack {
                themeManager.currentTheme.bgGradient.ignoresSafeArea()
                
                VStack(spacing: 25) {
                    Text("What made you happy?")
                        .textCase(.uppercase)
                        .font(.lummiFont(size: 24))
                        .foregroundColor(themeManager.currentTheme.textColor)
                        .padding(.top, 5)
                    
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
                        .font(.lummiFont(size: 18))
                        .accessibilityIdentifier("RecordInputTextEditor")

                    Spacer()
                }
                .padding(.horizontal, 20)
            }
            .toolbar {
                // Cancel button
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "chevron.left")
                            .font(.lummiFont(size: 15))
                            .foregroundColor(themeManager.currentTheme.textColor.opacity(0.6))
                            .background(
                                Circle().stroke(Color.clear)
                            )
                            .frame(width: 34, height: 34)
                            .contentShape(Circle())
                    }
                    .accessibilityLabel("Cancel")
                    .accessibilityIdentifier("CancelRecordButton")
                }
                
                // Save button
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        if let date = selectedDate, isSaveEnabled {
                            let newEntry = JoyEntry(text: text, date: date, dateKey: date.stringKey)
                            modelContext.insert(newEntry)
                            try? modelContext.save()
                            dismiss()
                        }
                    }) {
                        Image(systemName: "checkmark")
                            .font(.lummiFont(size: 15))
                            .foregroundColor(themeManager.currentTheme.textColor.opacity(isSaveEnabled ? 0.6 : 0.2))
                            .background(
                                Circle().stroke(Color.clear)
                            )
                            .frame(width: 34, height: 34)
                            .contentShape(Circle())
                    }
                    .disabled(!isSaveEnabled)
                    .accessibilityLabel("Save")
                    .accessibilityIdentifier("SaveRecordButton")
                }
            }
        }
    }
}
