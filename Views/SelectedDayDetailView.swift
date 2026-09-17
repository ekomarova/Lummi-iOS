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

struct SelectedDayDetailView: View {
    @Environment(ThemeManager.self) private var themeManager
    @Environment(\.modelContext) private var modelContext

    let selectedDate: Date?

    @Query(sort: \JoyEntry.date) private var allEntries: [JoyEntry]

    @State private var activeEntryID: PersistentIdentifier?
    @State private var editingText: String = ""
    @State private var isEditing: Bool = false
    @State private var saveAlert: SaveAlertKind?
    @FocusState private var isTextFieldFocused: Bool

    enum SaveAlertKind: Equatable {
        case editFailed
        case deleteFailed

        var title: LocalizedStringKey {
            switch self {
            case .editFailed: return "Failed to Save"
            case .deleteFailed: return "Failed to Delete"
            }
        }

        var message: LocalizedStringKey {
            switch self {
            case .editFailed: return "Your changes could not be saved. Please try again."
            case .deleteFailed: return "Your record could not be deleted. Please try again."
            }
        }

        var titleAccessibilityID: String {
            switch self {
            case .editFailed: return "SaveAlertTitle"
            case .deleteFailed: return "DeleteAlertTitle"
            }
        }

        var okButtonAccessibilityID: String {
            switch self {
            case .editFailed: return "SaveAlertOKButton"
            case .deleteFailed: return "DeleteAlertOKButton"
            }
        }
    }

    private var today: Date { Date() }

    private var isSelectedToday: Bool {
        guard let selected = selectedDate else { return false }
        return Calendar.current.isDate(selected, inSameDayAs: today)
    }

    private var todaysEntries: [JoyEntry] {
        guard let key = selectedDate?.stringKey else { return [] }
        return allEntries.filter { $0.dateKey == key }
    }

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color.black.opacity(0.001)
                    .ignoresSafeArea()
                    .accessibilityIdentifier("GlobalDismissArea")
                    .onTapGesture { saveAndDismiss() }

                ScrollView(.vertical, showsIndicators: false) {
                    ScrollViewReader { proxy in
                        VStack(spacing: AdaptiveLayout.getSize(for: 15)) {
                            if let selected = selectedDate {
                                if Calendar.current.startOfDay(for: selected) > Calendar.current.startOfDay(for: today) {
                                    futureDayView
                                        .blur(radius: activeEntryID != nil ? 6 : 0)
                                        .opacity(activeEntryID != nil ? 0.5 : 1.0)
                                        .padding(.top, AdaptiveLayout.getSize(for: 40))
                                } else if !todaysEntries.isEmpty {
                                    notesListView(entries: todaysEntries, proxy: proxy)
                                        .padding(.top, AdaptiveLayout.getSize(for: 10))
                                } else {
                                    noRecordsView
                                        .blur(radius: activeEntryID != nil ? 6 : 0)
                                        .opacity(activeEntryID != nil ? 0.5 : 1.0)
                                        .padding(.top, AdaptiveLayout.getSize(for: 40))
                                }
                            }
                        }
                        .padding(.horizontal)
                        .padding(.bottom, AdaptiveLayout.getSize(for: 160))
                        .frame(maxWidth: .infinity)
                        .frame(minHeight: geometry.size.height, alignment: .top)
                        .background(
                            Color.black.opacity(0.001)
                                .onTapGesture { saveAndDismiss() }
                        )
                    }
                }
            }
        }
        .blur(radius: saveAlert != nil ? 10 : 0)
        .animation(.easeInOut(duration: 0.25), value: saveAlert != nil)
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: selectedDate)
        .animation(.spring(response: 0.35, dampingFraction: 0.8), value: activeEntryID)
        .animation(.spring(response: 0.35, dampingFraction: 0.8), value: isEditing)
        .onChange(of: selectedDate) { _, _ in saveAndDismiss() }
        .onDisappear { saveAndDismiss() }
        .overlay {
            if let alert = saveAlert {
                Color.black.opacity(0.4)
                    .ignoresSafeArea()
                    .onTapGesture { dismissSaveAlert() }
                    .zIndex(1)

                saveAlertCard(alert)
                    .transition(.scale.combined(with: .opacity))
                    .zIndex(2)
            }
        }
    }
}

// MARK: - Alert Card

private extension SelectedDayDetailView {

    @ViewBuilder
    func saveAlertCard(_ alert: SaveAlertKind) -> some View {
        VStack(spacing: 20) {
            Text(alert.title)
                .font(.lummiFont(size: 20))
                .foregroundColor(themeManager.currentTheme.backgroundColor)
                .multilineTextAlignment(.center)
                .accessibilityIdentifier(alert.titleAccessibilityID)

            Text(alert.message)
                .font(.lummiFont(size: 16))
                .foregroundColor(themeManager.currentTheme.backgroundColor)
                .multilineTextAlignment(.center)

            Button(
                action: { dismissSaveAlert() },
                label: {
                    Text("OK")
                        .font(.lummiFont(size: 16))
                        .foregroundColor(themeManager.currentTheme.textColor)
                        .padding(.vertical, 12)
                        .padding(.horizontal, 40)
                        .background(Capsule().fill(themeManager.currentTheme.backgroundColor))
                }
            )
            .accessibilityIdentifier(alert.okButtonAccessibilityID)
        }
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(themeManager.currentTheme.textColor)
        )
        .padding(40)
        .zIndex(2)
    }
}

// MARK: - Subviews

private extension SelectedDayDetailView {

    var futureDayView: some View {
        VStack(spacing: AdaptiveLayout.getSize(for: 12)) {
            Image(systemName: "moon.stars.fill")
                .font(.system(size: AdaptiveLayout.getSize(for: 40)))
                .foregroundColor(themeManager.currentTheme.textColor.opacity(0.2))
            Text("Oops! This day has not started yet")
                .font(.lummiFont(size: 16))
                .foregroundColor(themeManager.currentTheme.textColor.opacity(0.6))
        }
    }

    var noRecordsView: some View {
        Text("No records for this day")
            .font(.lummiFont(size: 16))
            .foregroundColor(themeManager.currentTheme.textColor.opacity(0.3))
    }

    func notesListView(entries: [JoyEntry], proxy: ScrollViewProxy) -> some View {
        VStack(alignment: .leading, spacing: AdaptiveLayout.getSize(for: 15)) {
            ForEach(Array(entries.enumerated()), id: \.element.persistentModelID) { index, entry in
                noteCell(for: entry, index: index, proxy: proxy)
            }
        }
    }

    @ViewBuilder
    func noteCell(for entry: JoyEntry, index: Int, proxy: ScrollViewProxy) -> some View {
        let isActive = (activeEntryID == entry.persistentModelID)

        VStack(alignment: .trailing, spacing: AdaptiveLayout.getSize(for: 8)) {
            if isActive && !isEditing {
                noteCellActionButtons(entry: entry, proxy: proxy)
            }

            Group {
                if isActive && isEditing {
                    noteCellEditField
                } else {
                    noteCellTextDisplay(entry: entry, index: index, isActive: isActive, proxy: proxy)
                }
            }
        }
        .id(entry.persistentModelID)
        .blur(radius: (activeEntryID != nil && !isActive) ? 6 : 0)
        .opacity((activeEntryID != nil && !isActive) ? 0.4 : 1.0)
        .onChange(of: isEditing) { _, editing in
            if editing && isActive {
                isTextFieldFocused = true
                withAnimation(.spring()) {
                    proxy.scrollTo(entry.persistentModelID, anchor: .center)
                }
            }
        }
    }

    func noteCellActionButtons(entry: JoyEntry, proxy: ScrollViewProxy) -> some View {
        HStack(spacing: AdaptiveLayout.getSize(for: 12)) {
            Button(
                action: {
                    editingText = entry.text
                    isEditing = true
                },
                label: {
                    Image(systemName: "pencil")
                        .font(.lummiFont(size: 16))
                        .foregroundColor(themeManager.currentTheme.backgroundColor)
                        .frame(width: AdaptiveLayout.getSize(for: 44), height: AdaptiveLayout.getSize(for: 44))
                        .background(Circle().fill(themeManager.currentTheme.textColor.opacity(0.85)))
                }
            )
            .accessibilityIdentifier("EditRecordButton")

            Button(
                action: { deleteNote(entry) },
                label: {
                    Image(systemName: "trash")
                        .font(.lummiFont(size: 16))
                        .foregroundColor(themeManager.currentTheme.backgroundColor)
                        .frame(width: AdaptiveLayout.getSize(for: 44), height: AdaptiveLayout.getSize(for: 44))
                        .background(Circle().fill(themeManager.currentTheme.textColor.opacity(0.85)))
                }
            )
            .accessibilityIdentifier("DeleteRecordButton")
        }
        .transition(.scale(scale: 0.8).combined(with: .opacity).combined(with: .move(edge: .bottom)))
    }

    var noteCellEditField: some View {
        TextField("What made you happy?", text: $editingText, axis: .vertical)
            .accessibilityIdentifier("EditRecordTextField")
            .focused($isTextFieldFocused)
            .font(.lummiFont(size: 16))
            .foregroundColor(themeManager.currentTheme.textColor)
            .padding(AdaptiveLayout.getSize(for: 20))
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: AdaptiveLayout.getSize(for: 20))
                    .fill(themeManager.currentTheme.textColor.opacity(0.12))
                    .overlay(
                        RoundedRectangle(cornerRadius: AdaptiveLayout.getSize(for: 20))
                            .stroke(themeManager.currentTheme.textColor.opacity(0.3), lineWidth: 1)
                    )
            )
    }

    func noteCellTextDisplay(entry: JoyEntry, index: Int, isActive: Bool, proxy: ScrollViewProxy) -> some View {
        Text(entry.text)
            .font(.lummiFont(size: 16))
            .foregroundColor(themeManager.currentTheme.textColor)
            .padding(AdaptiveLayout.getSize(for: 20))
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: AdaptiveLayout.getSize(for: 20))
                    .fill(themeManager.currentTheme.textColor.opacity(0.05))
                    .overlay(
                        RoundedRectangle(cornerRadius: AdaptiveLayout.getSize(for: 20))
                            .stroke(
                                themeManager.currentTheme.textColor.opacity(isActive ? 0.3 : 0.1),
                                lineWidth: isActive ? 2 : 1
                            )
                    )
            )
            .onTapGesture {
                if activeEntryID != nil { saveAndDismiss() }
            }
            .onLongPressGesture {
                if isSelectedToday && !isActive {
                    saveAndDismiss()
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        activeEntryID = entry.persistentModelID
                        isEditing = false
                    }
                    withAnimation { proxy.scrollTo(entry.persistentModelID, anchor: .center) }
                }
            }
            .accessibilityIdentifier("RecordText_\(index)")
    }
}

// MARK: - Actions

private extension SelectedDayDetailView {

    func deleteNote(_ entry: JoyEntry) {
        modelContext.delete(entry)
        do {
            try modelContext.saveOrSimulate()
            withAnimation { activeEntryID = nil }
        } catch {
            modelContext.rollback()
            withAnimation { saveAlert = .deleteFailed }
        }
    }

    func saveAndDismiss() {
        isTextFieldFocused = false

        guard let id = activeEntryID else { return }

        if isEditing {
            let trimmed = editingText.trimmingCharacters(in: .whitespacesAndNewlines)
            if let entry = todaysEntries.first(where: { $0.persistentModelID == id }) {
                let originalText = entry.text
                if trimmed.isEmpty {
                    modelContext.delete(entry)
                } else {
                    entry.text = trimmed
                }
                do {
                    try modelContext.saveOrSimulate()
                } catch {
                    modelContext.rollback()
                    editingText = originalText
                    withAnimation { saveAlert = .editFailed }
                    return
                }
            }
        }

        withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
            activeEntryID = nil
            isEditing = false
        }
    }

    func dismissSaveAlert() {
        let kind = saveAlert
        withAnimation(.easeInOut(duration: 0.25)) { saveAlert = nil }
        if kind == .editFailed {
            withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                activeEntryID = nil
                isEditing = false
            }
        }
    }
}
