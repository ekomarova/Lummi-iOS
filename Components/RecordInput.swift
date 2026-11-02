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

    @State private var text: String = ""
    @State private var showSaveAlert = false
    @FocusState private var isTextEditorFocused: Bool

    var isSaveEnabled: Bool {
        RecordInputRules.canSave(text)
    }

    // A `TextEditor` does not size itself to its text, so an invisible copy of the text sets the height and the editor
    // fills it: one line when empty, growing with the text up to `maxEditorLines`, after which the editor scrolls.
    // The extra character keeps the height of a trailing line break, which `Text` would otherwise drop. The cap is a
    // line limit: a `maxHeight` frame would stretch the copy to that height instead of only limiting it.
    private var editor: some View {
        Text(text.isEmpty ? " " : text + "\u{200B}")
            .lummiScaledFont(size: 18, relativeTo: .body)
            .lineLimit(maxEditorLines)
            .padding(.horizontal, 5)
            .padding(.vertical, 8)
            .frame(maxWidth: .infinity, alignment: .topLeading)
            .opacity(0)
            .accessibilityHidden(true)
            .overlay {
                TextEditor(text: $text)
                    .focused($isTextEditorFocused)
                    .scrollContentBackground(.hidden)
                    .foregroundColor(themeManager.currentTheme.textColor)
                    .lummiScaledFont(size: 18, relativeTo: .body)
                    .accessibilityIdentifier("RecordInputTextEditor")
                    .limitedLength($text)
            }
    }

    private var maxEditorLines: Int { AdaptiveLayout.isPad ? 16 : 9 }

    var body: some View {
        VStack(spacing: 25) {
            editor
                .padding()
                .cardBackground(RoundedRectangle(cornerRadius: 20), fillOpacity: 0.1, strokeOpacity: 0.2)

            HStack {
                Spacer()
                Text("\(text.count)/\(RecordInputRules.maxLength)")
                    .lummiScaledFont(size: 12, relativeTo: .caption)
                    .foregroundColor(themeManager.currentTheme.textColor.opacity(
                        RecordInputRules.isNearLimit(text) ? 0.7 : 0.35
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
