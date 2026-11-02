//
//  Required Notice: Copyright Evseniia Komarova (https://github.com/ekomarova)
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

    // Only the selected day's entries are fetched, not the whole journal.
    @Query private var dayEntries: [JoyEntry]

    @State private var session = EntryEditSession()
    @FocusState private var isTextFieldFocused: Bool

    init(selectedDate: Date) {
        self.selectedDate = selectedDate
        _dayEntries = Query(filter: JoyEntry.dayPredicate(for: selectedDate), sort: \JoyEntry.date)
    }

    private var today: Date { Date() }

    private var isSelectedToday: Bool {
        Calendar.current.isDate(selectedDate, inSameDayAs: today)
    }

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                tapCatcher
                    .ignoresSafeArea()
                    .accessibilityIdentifier("GlobalDismissArea")
                    .onTapGesture { saveAndDismiss() }

                ScrollView(.vertical, showsIndicators: false) {
                    ScrollViewReader { proxy in
                        VStack(spacing: 15) {
                            // Like the first message of a chat: the question stays on top and the day's entries follow
                            // it, scrolling up together once there are many.
                            dayPromptView
                                .blur(radius: session.hasActiveEntry ? 6 : 0)
                                .opacity(session.hasActiveEntry ? 0.5 : 1.0)
                                .padding(.top, 10)

                            if !dayEntries.isEmpty {
                                notesListView(entries: dayEntries, proxy: proxy)
                            }
                        }
                        .padding(.horizontal)
                        .padding(.bottom, 160)
                        .frame(maxWidth: .infinity)
                        .frame(minHeight: geometry.size.height, alignment: .top)
                        .background(
                            tapCatcher
                                .onTapGesture { saveAndDismiss() }
                        )
                    }
                }
                .scrollClipDisabled()
                .ignoresSafeArea(.container, edges: .bottom)
            }
        }
        .animation(.lummiSpringSlow, value: selectedDate)
        .animation(.lummiSpring, value: session.activeEntryID)
        .animation(.lummiSpring, value: session.isEditing)
        .onChange(of: selectedDate) { _, _ in saveAndDismiss() }
        .onDisappear { saveAndDismiss() }
        .errorAlert(
            session.saveAlert?.title ?? "",
            message: Text(session.saveAlert?.message ?? ""),
            isPresented: session.saveAlert != nil
        ) {
            withAnimation(.lummiSpring) { session.dismissSaveAlert() }
        }
    }
}

// MARK: - Subviews

private extension SelectedDayDetailView {

    // An invisible area that takes taps, so a tap anywhere outside the entries leaves the edit mode.
    var tapCatcher: some View {
        Color.clear.contentShape(Rectangle())
    }

    var dayPromptView: some View {
        NoteBubble(sharpCorner: .bottomLeading, style: .card) {
            Text("What made this day brighter?")
                .lummiScaledFont(size: 17, relativeTo: .body)
                .accessibilityIdentifier("DayPromptText")
        }
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
        let isActive = session.isActive(entry.persistentModelID)

        VStack(alignment: .trailing, spacing: 8) {
            if isActive && !session.isEditing {
                noteCellActionButtons(entry: entry, proxy: proxy)
            }

            Group {
                if isActive && session.isEditing {
                    noteCellEditField
                } else {
                    noteCellTextDisplay(entry: entry, index: index, isActive: isActive, proxy: proxy)
                }
            }
        }
        .id(entry.persistentModelID)
        .blur(radius: (session.hasActiveEntry && !isActive) ? 6 : 0)
        .opacity((session.hasActiveEntry && !isActive) ? 0.4 : 1.0)
        .onChange(of: session.isEditing) { _, editing in
            if editing && isActive {
                isTextFieldFocused = true
                withAnimation(.lummiSpring) {
                    proxy.scrollTo(entry.persistentModelID, anchor: .center)
                }
            }
        }
    }

    func noteCellActionButtons(entry: JoyEntry, proxy: ScrollViewProxy) -> some View {
        HStack(spacing: 12) {
            RecordActionButton(systemImage: "pencil", title: "Edit", accessibilityID: "EditRecordButton") {
                session.beginEditing(text: entry.text)
            }

            RecordActionButton(systemImage: "trash", title: "Delete", accessibilityID: "DeleteRecordButton") {
                deleteNote()
            }
        }
        .transition(.scale(scale: 0.8).combined(with: .opacity).combined(with: .move(edge: .bottom)))
    }

    var noteCellEditField: some View {
        NoteBubble(sharpCorner: .bottomTrailing, fillsWidth: true) {
            TextField("", text: Bindable(session).editingText, axis: .vertical)
                .accessibilityLabel("Record text")
                .accessibilityIdentifier("EditRecordTextField")
                .focused($isTextFieldFocused)
                .lummiScaledFont(size: 16, relativeTo: .callout)
                .limitedLength(Bindable(session).editingText)
        }
    }

    func noteCellTextDisplay(entry: JoyEntry, index: Int, isActive: Bool, proxy: ScrollViewProxy) -> some View {
        NoteBubble(sharpCorner: .bottomTrailing) {
            Text(entry.text)
                .lummiScaledFont(size: 17, relativeTo: .body)
        }
        .onTapGesture {
            if session.hasActiveEntry { saveAndDismiss() }
        }
        .onLongPressGesture {
            if session.canSelect(entry.persistentModelID, isToday: isSelectedToday) {
                saveAndDismiss()
                withAnimation(.lummiSpringQuick) {
                    session.select(entry.persistentModelID)
                }
                withAnimation { proxy.scrollTo(entry.persistentModelID, anchor: .center) }
            }
        }
        .accessibilityIdentifier("RecordText_\(index)")
    }
}

// MARK: - Actions

private extension SelectedDayDetailView {

    func deleteNote() {
        session.delete { id in
            guard let entry = dayEntries.first(where: { $0.persistentModelID == id }) else { return }
            try JoyEntryStore(context: modelContext).delete(entry)
        }
    }

    func saveAndDismiss() {
        isTextFieldFocused = false

        withAnimation(.lummiSpring) {
            session.saveAndDismiss { id, text in
                guard let entry = dayEntries.first(where: { $0.persistentModelID == id }) else { return }
                try JoyEntryStore(context: modelContext).applyEdit(to: entry, newText: text)
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
