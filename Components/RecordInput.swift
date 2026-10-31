//
//  Required Notice: Copyright Evseniia Komarova (https://github.com/ekomarova)
//
//  Licensed under the PolyForm Noncommercial License 1.0.0.
//  See the LICENSE file in the repository root for full terms.
//  <https://polyformproject.org/licenses/noncommercial/1.0.0>
//

import SwiftUI
import SwiftData

// New-joy page pushed onto the current tab: text editor with a length limit, the system back button to cancel
// (or swipe from the left edge) and a save button.
struct RecordInput: View {
    @Environment(ThemeManager.self) private var themeManager
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    let recordDate: Date

    private let maxLength = RecordInputRules.maxLength

    @State private var text: String = ""
    @State private var showSaveAlert = false
    @FocusState private var isTextEditorFocused: Bool

    var isSaveEnabled: Bool {
        RecordInputRules.canSave(text)
    }

    var body: some View {
        VStack(spacing: 25) {
            TextEditor(text: $text)
                .focused($isTextEditorFocused)
                .frame(height: AdaptiveLayout.isPad ? 280 : 150)
                .padding()
                .scrollContentBackground(.hidden)
                .cardBackground(RoundedRectangle(cornerRadius: 20), fillOpacity: 0.1, strokeOpacity: 0.2)
                .foregroundColor(themeManager.currentTheme.textColor)
                .lummiScaledFont(size: 18, relativeTo: .body)
                .accessibilityIdentifier("RecordInputTextEditor")
                .onChange(of: text) { _, newValue in
                    let clamped = RecordInputRules.clamped(newValue)
                    if clamped != newValue { text = clamped }
                }

            HStack {
                Spacer()
                Text("\(text.count)/\(maxLength)")
                    .lummiScaledFont(size: 12, relativeTo: .caption)
                    .foregroundColor(themeManager.currentTheme.textColor.opacity(
                        text.count > maxLength - 20 ? 0.7 : 0.35
                    ))
            }
            .padding(.horizontal, 5)

            Spacer()
        }
        .padding(.top, 20)
        .padding(.horizontal, 20)
        .lummiNavigationTitle("New Joy")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button(action: save) {
                    Image(systemName: "checkmark")
                }
                .disabled(!isSaveEnabled)
                .accessibilityLabel(Text("Save"))
                .accessibilityIdentifier("SaveRecordButton")
            }
        }
        .alert("Failed to Save", isPresented: $showSaveAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("Your moment could not be saved. Please try again.")
        }
    }

    private func save() {
        guard isSaveEnabled else { return }
        do {
            try JoyEntryStore(context: modelContext).add(text: text, date: recordDate)
            isTextEditorFocused = false
            dismiss()
        } catch {
            withAnimation { showSaveAlert = true }
        }
    }
}

#if DEBUG
#Preview {
    NavigationStack {
        RecordInput(recordDate: Date())
    }
    .previewEnvironment(withSampleEntries: false)
}
#endif
