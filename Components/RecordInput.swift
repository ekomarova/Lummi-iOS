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

    let selectedDate: Date?
    let onDismiss: () -> Void

    private let maxLength = 280

    @State private var text: String = ""
    @State private var showSaveAlert = false
    @FocusState private var isTextEditorFocused: Bool

    var isSaveEnabled: Bool {
        !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                Text("New Joy")
                    .font(.lummiFont(size: 20, weight: .bold))
                    .foregroundColor(themeManager.currentTheme.textColor)
                    .frame(maxWidth: .infinity, alignment: .center)

                HStack {
                    Button(
                        action: {
                            isTextEditorFocused = false
                            onDismiss()
                        },
                        label: {
                            Circle()
                                .fill(themeManager.currentTheme.textColor.opacity(0.05))
                                .adaptiveGlass(in: Circle())
                                .frame(width: 44, height: 44)
                                .overlay(
                                    Image(systemName: "chevron.left")
                                        .font(.lummiFont(size: 16, weight: .bold))
                                        .foregroundColor(themeManager.currentTheme.textColor)
                                )
                        }
                    )
                    .buttonStyle(.plain)
                    .accessibilityLabel("Cancel")
                    .accessibilityIdentifier("CancelRecordButton")

                    Spacer()

                    Button(
                        action: {
                            if let date = selectedDate, isSaveEnabled {
                                let newEntry = JoyEntry(text: text, date: date)
                                modelContext.insert(newEntry)
                                do {
                                    try modelContext.saveOrSimulate()
                                    isTextEditorFocused = false
                                    onDismiss()
                                } catch {
                                    modelContext.rollback()
                                    withAnimation { showSaveAlert = true }
                                }
                            }
                        },
                        label: {
                            Circle()
                                .fill(themeManager.currentTheme.textColor.opacity(0.05))
                                .adaptiveGlass(in: Circle())
                                .frame(width: 44, height: 44)
                                .overlay(
                                    Image(systemName: "checkmark")
                                        .font(.lummiFont(size: 16, weight: .bold))
                                        .foregroundColor(themeManager.currentTheme.textColor.opacity(isSaveEnabled ? 0.8 : 0.2))
                                )
                        }
                    )
                    .buttonStyle(.plain)
                    .disabled(!isSaveEnabled)
                    .accessibilityLabel("Save")
                    .accessibilityIdentifier("SaveRecordButton")
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 10)

            VStack(spacing: 25) {
                TextEditor(text: $text)
                    .focused($isTextEditorFocused)
                    .frame(height: AdaptiveLayout.isPad ? 280 : 150)
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
                    .onChange(of: text) { _, newValue in
                        if newValue.count > maxLength {
                            text = String(newValue.prefix(maxLength))
                        }
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
