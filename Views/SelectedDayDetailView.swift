import SwiftUI

struct SelectedDayDetailView: View {
    @EnvironmentObject var themeManager: ThemeManager
    
    let selectedDate: Date?
    @Binding var joyEntries: [String: [String]]
    
    @State private var activeMenuIndex: Int? = nil
    @State private var editingText: String = ""
    @State private var isEditing: Bool = false
    @FocusState private var isTextFieldFocused: Bool
    
    private var today: Date { Date() }
    private var isSelectedToday: Bool {
        guard let selected = selectedDate else { return false }
        return Calendar.current.isDate(selected, inSameDayAs: today)
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Global full-screen tap interceptor
                Color.black.opacity(0.001)
                    .ignoresSafeArea()
                    .onTapGesture {
                        saveAndDismiss()
                    }

                ScrollView(.vertical, showsIndicators: false) {
                    ScrollViewReader { proxy in
                        VStack(spacing: 15) {
                            if let selected = selectedDate {
                                if Calendar.current.startOfDay(for: selected) > Calendar.current.startOfDay(for: today) {
                                    futureDayView
                                        .blur(radius: activeMenuIndex != nil ? 6 : 0)
                                        .opacity(activeMenuIndex != nil ? 0.5 : 1.0)
                                        .padding(.top, 40)
                                } else if let notes = joyEntries[selected.stringKey], !notes.isEmpty {
                                    notesListView(notes: notes, proxy: proxy)
                                        .padding(.top, 10)
                                } else {
                                    noRecordsView
                                        .blur(radius: activeMenuIndex != nil ? 6 : 0)
                                        .opacity(activeMenuIndex != nil ? 0.5 : 1.0)
                                        .padding(.top, 40)
                                }
                            }
                        }
                        .padding(.horizontal)
                        .padding(.bottom, 160)
                        .frame(maxWidth: .infinity)
                        .frame(minHeight: geometry.size.height, alignment: .top)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            saveAndDismiss()
                        }
                    }
                }
            }
        }
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: selectedDate)
        .animation(.spring(response: 0.35, dampingFraction: 0.8), value: activeMenuIndex)
        .animation(.spring(response: 0.35, dampingFraction: 0.8), value: isEditing)
        .onChange(of: selectedDate) { oldValue, newValue in
            saveAndDismiss()
        }
    }
    
    // MARK: - Subviews
    
    private var futureDayView: some View {
        VStack(spacing: 12) {
            Image(systemName: "moon.stars.fill")
                .font(.system(size: 40))
                .foregroundColor(themeManager.currentTheme.textColor.opacity(0.2))
            Text("Oops! This day has not started yet")
                .font(.system(size: 16, weight: .bold, design: .monospaced))
                .foregroundColor(themeManager.currentTheme.textColor.opacity(0.6))
            Text("✨ Lumens will light up when the time is right ✨")
                .font(.system(size: 13))
                .foregroundColor(themeManager.currentTheme.textColor.opacity(0.4))
                .multilineTextAlignment(.center)
        }
    }
    
    private var noRecordsView: some View {
        Text("No records for this day")
            .font(.system(size: 14, design: .monospaced))
            .foregroundColor(themeManager.currentTheme.textColor.opacity(0.3))
    }
    
    private func notesListView(notes: [String], proxy: ScrollViewProxy) -> some View {
        VStack(alignment: .leading, spacing: 15) {
            ForEach(notes.indices, id: \.self) { index in
                noteCell(for: index, note: notes[index], proxy: proxy)
            }
        }
    }
    
    // MARK: - Interactive Cell
    
    @ViewBuilder
    private func noteCell(for index: Int, note: String, proxy: ScrollViewProxy) -> some View {
        let isActive = (activeMenuIndex == index)
        
        VStack(alignment: .trailing, spacing: 8) {
            
            if isActive && !isEditing {
                HStack(spacing: 12) {
                    Button(action: {
                        editingText = note
                        isEditing = true
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            isTextFieldFocused = true
                            withAnimation(.spring()) {
                                proxy.scrollTo(index, anchor: .center)
                            }
                        }
                    }) {
                        Image(systemName: "pencil")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(themeManager.currentTheme.backgroundColor)
                            .frame(width: 44, height: 44)
                            .background(Circle().fill(themeManager.currentTheme.textColor.opacity(0.85)))
                    }
                    
                    Button(action: { deleteNote(at: index) }) {
                        Image(systemName: "trash")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(themeManager.currentTheme.backgroundColor)
                            .frame(width: 44, height: 44)
                            .background(Circle().fill(themeManager.currentTheme.textColor.opacity(0.85)))
                    }
                }
                .transition(.scale(scale: 0.8).combined(with: .opacity).combined(with: .move(edge: .bottom)))
            }
            
            Group {
                if isActive && isEditing {
                    TextField("What made you happy?", text: $editingText, axis: .vertical)
                        .focused($isTextFieldFocused)
                        .font(.system(size: 16, weight: .light, design: .monospaced))
                        .foregroundColor(themeManager.currentTheme.textColor)
                        .padding(20)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(themeManager.currentTheme.textColor.opacity(0.12))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 20)
                                        .stroke(themeManager.currentTheme.textColor.opacity(0.3), lineWidth: 1)
                                )
                        )
                } else {
                    Text(note)
                        .font(.system(size: 16, weight: .light, design: .monospaced))
                        .foregroundColor(themeManager.currentTheme.textColor)
                        .padding(20)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(themeManager.currentTheme.textColor.opacity(0.05))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 20)
                                        .stroke(themeManager.currentTheme.textColor.opacity(isActive ? 0.3 : 0.1), lineWidth: isActive ? 2 : 1)
                                )
                        )
                        .onTapGesture {
                            if activeMenuIndex != nil { saveAndDismiss() }
                        }
                        .onLongPressGesture {
                            if isSelectedToday && !isActive {
                                saveAndDismiss()
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                    activeMenuIndex = index
                                    isEditing = false
                                }
                                withAnimation { proxy.scrollTo(index, anchor: .center) }
                            }
                        }
                }
            }
        }
        .id(index)
        .blur(radius: (activeMenuIndex != nil && !isActive) ? 6 : 0)
        .opacity((activeMenuIndex != nil && !isActive) ? 0.4 : 1.0)
    }
    
    // MARK: - Actions
    
    private func deleteNote(at index: Int) {
        guard let key = selectedDate?.stringKey else { return }
        withAnimation {
            joyEntries[key]?.remove(at: index)
            activeMenuIndex = nil
        }
    }
    
    private func saveAndDismiss() {
        isTextFieldFocused = false
        
        guard let index = activeMenuIndex, let key = selectedDate?.stringKey else {
            return
        }
        
        if isEditing {
            let trimmed = editingText.trimmingCharacters(in: .whitespacesAndNewlines)
            if trimmed.isEmpty {
                joyEntries[key]?.remove(at: index)
            } else {
                joyEntries[key]?[index] = trimmed
            }
        }
        
        withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
            activeMenuIndex = nil
            isEditing = false
        }
    }
}
