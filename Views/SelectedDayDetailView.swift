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

// Shows the joys recorded on the selected day and lets the user edit or delete them.
struct SelectedDayDetailView: View {
    @Environment(ThemeManager.self) private var themeManager
    @Environment(\.modelContext) private var modelContext

    let selectedDate: Date

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
    }

    private var today: Date { Date() }

    private var isSelectedToday: Bool {
        Calendar.current.isDate(selectedDate, inSameDayAs: today)
    }

    private var todaysEntries: [JoyEntry] {
        let key = selectedDate.stringKey
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
                        VStack(spacing: 15) {
                            if Calendar.current.startOfDay(for: selectedDate) > Calendar.current.startOfDay(for: today) {
                                futureDayView
                                    .blur(radius: activeEntryID != nil ? 6 : 0)
                                    .opacity(activeEntryID != nil ? 0.5 : 1.0)
                                    .padding(.top, 40)
                            } else if !todaysEntries.isEmpty {
                                notesListView(entries: todaysEntries, proxy: proxy)
                                    .padding(.top, 10)
                            } else {
                                noRecordsView
                                    .blur(radius: activeEntryID != nil ? 6 : 0)
                                    .opacity(activeEntryID != nil ? 0.5 : 1.0)
                                    .padding(.top, 40)
                            }
                        }
                        .padding(.horizontal)
                        .padding(.bottom, 160)
                        .frame(maxWidth: .infinity)
                        .frame(minHeight: geometry.size.height, alignment: .top)
                        .background(
                            Color.black.opacity(0.001)
                                .onTapGesture { saveAndDismiss() }
                        )
                    }
                }
                .ignoresSafeArea(.container, edges: .bottom)
            }
        }
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: selectedDate)
        .animation(.spring(response: 0.35, dampingFraction: 0.8), value: activeEntryID)
        .animation(.spring(response: 0.35, dampingFraction: 0.8), value: isEditing)
        .onChange(of: selectedDate) { _, _ in saveAndDismiss() }
        .onDisappear { saveAndDismiss() }
        .alert(
            saveAlert?.title ?? "",
            isPresented: Binding(
                get: { saveAlert != nil },
                set: { isPresented in
                    if !isPresented { dismissSaveAlert() }
                }
            )
        ) {
            Button("OK", role: .cancel) { dismissSaveAlert() }
        } message: {
            Text(saveAlert?.message ?? "")
        }
    }
}

// MARK: - Subviews

private extension SelectedDayDetailView {

    var futureDayView: some View {
        VStack(spacing: 12) {
            Image(systemName: "moon.stars.fill")
                .font(.system(size: 40))
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
        VStack(alignment: .leading, spacing: 15) {
            ForEach(Array(entries.enumerated()), id: \.element.persistentModelID) { index, entry in
                noteCell(for: entry, index: index, proxy: proxy)
            }
        }
    }

    @ViewBuilder
    func noteCell(for entry: JoyEntry, index: Int, proxy: ScrollViewProxy) -> some View {
        let isActive = (activeEntryID == entry.persistentModelID)

        VStack(alignment: .trailing, spacing: 8) {
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
        HStack(spacing: 12) {
            RecordActionButton(systemImage: "pencil", title: "Edit", accessibilityID: "EditRecordButton") {
                editingText = entry.text
                isEditing = true
            }

            RecordActionButton(systemImage: "trash", title: "Delete", accessibilityID: "DeleteRecordButton") {
                deleteNote(entry)
            }
        }
        .transition(.scale(scale: 0.8).combined(with: .opacity).combined(with: .move(edge: .bottom)))
    }

    var noteCellEditField: some View {
        NoteBubble(strokeOpacity: 0.3) {
            TextField("", text: $editingText, axis: .vertical)
                .accessibilityLabel("Record text")
                .accessibilityIdentifier("EditRecordTextField")
                .focused($isTextFieldFocused)
                .font(.lummiFont(size: 16))
                .foregroundColor(themeManager.currentTheme.textColor)
        }
    }

    func noteCellTextDisplay(entry: JoyEntry, index: Int, isActive: Bool, proxy: ScrollViewProxy) -> some View {
        NoteBubble(strokeOpacity: isActive ? 0.5 : 0.25, lineWidth: isActive ? 2 : 1) {
            Text(entry.text)
                .font(.lummiFont(size: 17))
                .foregroundColor(themeManager.currentTheme.textColor)
        }
        .contentShape(RoundedRectangle(cornerRadius: 20))
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
        do {
            try JoyEntryStore(context: modelContext).delete(entry)
            withAnimation { activeEntryID = nil }
        } catch {
            withAnimation { saveAlert = .deleteFailed }
        }
    }

    func saveAndDismiss() {
        isTextFieldFocused = false

        guard let id = activeEntryID else { return }

        if isEditing {
            if let entry = todaysEntries.first(where: { $0.persistentModelID == id }) {
                let originalText = entry.text
                do {
                    try JoyEntryStore(context: modelContext).applyEdit(to: entry, newText: editingText)
                } catch {
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

#if DEBUG
#Preview {
    SelectedDayDetailView(selectedDate: Date())
        .previewEnvironment()
}
#endif
