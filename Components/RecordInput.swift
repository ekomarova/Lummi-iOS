//
//  Copyright (c) 2026, Evseniia Komarova.
//  All rights reserved.
//
//  Licensed under the PolyForm Noncommercial License 1.0.0.
//  See the LICENSE file in the repository root for full terms.
//  <https://polyformproject.org/licenses/noncommercial/1.0.0>
//

import SwiftUI
import SwiftData

struct RecordInput: View {
    @Environment(ThemeManager.self) private var themeManager
    @Environment(\.modelContext) private var modelContext

    let recordDate: Date
    let onDismiss: () -> Void

    private let maxLength = RecordInputRules.maxLength

    @State private var text: String = ""
    @State private var showSaveAlert = false
    @FocusState private var isTextEditorFocused: Bool

    var isSaveEnabled: Bool {
        RecordInputRules.canSave(text)
    }

    var body: some View {
        VStack(spacing: 0) {
            ScreenHeader(
                title: "New Joy",
                leftButton: {
                    NavigationIconButton(
                        systemImage: "chevron.left",
                        accessibilityLabel: "Cancel",
                        accessibilityID: "CancelRecordButton"
                    ) {
                        isTextEditorFocused = false
                        onDismiss()
                    }
                },
                rightButton: {
                    NavigationIconButton(
                        systemImage: "checkmark",
                        iconOpacity: isSaveEnabled ? 0.8 : 0.2,
                        accessibilityLabel: "Save",
                        accessibilityID: "SaveRecordButton"
                    ) {
                        if isSaveEnabled {
                            do {
                                try JoyEntryStore(context: modelContext).add(text: text, date: recordDate)
                                isTextEditorFocused = false
                                onDismiss()
                            } catch {
                                withAnimation { showSaveAlert = true }
                            }
                        }
                    }
                    .disabled(!isSaveEnabled)
                }
            )

            VStack(spacing: 25) {
                TextEditor(text: $text)
                    .focused($isTextEditorFocused)
                    .frame(height: AdaptiveLayout.isPad ? 280 : 150)
                    .padding()
                    .scrollContentBackground(.hidden)
                    .cardBackground(RoundedRectangle(cornerRadius: 20), fillOpacity: 0.1, strokeOpacity: 0.2)
                    .foregroundColor(themeManager.currentTheme.textColor)
                    .font(.lummiFont(size: 18))
                    .accessibilityIdentifier("RecordInputTextEditor")
                    .onChange(of: text) { _, newValue in
                        let clamped = RecordInputRules.clamped(newValue)
                        if clamped != newValue { text = clamped }
                    }

                HStack {
                    Spacer()
                    Text("\(text.count)/\(maxLength)")
                        .font(.lummiFont(size: 12))
                        .foregroundColor(themeManager.currentTheme.textColor.opacity(
                            text.count > maxLength - 20 ? 0.7 : 0.35
                        ))
                }
                .padding(.horizontal, 5)

                Spacer()
            }
            .padding(.top, 30)
            .padding(.horizontal, 20)
        }
        .transition(.move(edge: .trailing).combined(with: .opacity))
        .alert("Failed to Save", isPresented: $showSaveAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("Your moment could not be saved. Please try again.")
        }
    }
}

#if DEBUG
#Preview {
    RecordInput(recordDate: Date(), onDismiss: { })
        .previewEnvironment(withSampleEntries: false)
}
#endif
