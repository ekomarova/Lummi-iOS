//
//  Copyright (c) 2026, Evseniia Komarova.
//  All rights reserved.
//
//  Redistribution and use in source and binary forms, with or without
//  modification, are permitted provided that the following conditions are met:
//  - Redistributions of source code must retain the above copyright notice,
//    this list of conditions and the following disclaimer.
//  - Redistributions in binary form must reproduce the above copyright notice,
//    this list of conditions and the following disclaimer in the documentation
//    and/or other materials provided with the distribution.
//  - Neither the name of the copyright holder nor the names of its contributors
//    may be used to endorse or promote products derived from this software
//    without specific prior written permission.
//
//  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
//  AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
//  IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
//  ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
//  LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
//  CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
//  SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
//  INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
//  CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
//  ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF
//  THE POSSIBILITY OF SUCH DAMAGE.
//

import SwiftUI
import SwiftData

struct SelectedDayDetailView: View {
    @EnvironmentObject var themeManager: ThemeManager
    @Environment(\.modelContext) private var modelContext
    
    let selectedDate: Date?

    @Query(sort: \JoyEntry.date) private var allEntries: [JoyEntry]
    
    @State private var activeMenuIndex: Int?
    @State private var editingText: String = ""
    @State private var isEditing: Bool = false
    @FocusState private var isTextFieldFocused: Bool
    
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
                // Global full-screen tap interceptor
                Color.black.opacity(0.001)
                    .ignoresSafeArea()
                    .accessibilityIdentifier("GlobalDismissArea")
                    .onTapGesture {
                        saveAndDismiss()
                    }

                ScrollView(.vertical, showsIndicators: false) {
                    ScrollViewReader { proxy in
                        VStack(spacing: AdaptiveLayout.getSize(for: 15)) {
                            if let selected = selectedDate {
                                if Calendar.current.startOfDay(for: selected) > Calendar.current.startOfDay(for: today) {
                                    futureDayView
                                        .blur(radius: activeMenuIndex != nil ? 6 : 0)
                                        .opacity(activeMenuIndex != nil ? 0.5 : 1.0)
                                        .padding(.top, AdaptiveLayout.getSize(for: 40))
                                } else if !todaysEntries.isEmpty {
                                    notesListView(entries: todaysEntries, proxy: proxy)
                                        .padding(.top, AdaptiveLayout.getSize(for: 10))
                                } else {
                                    noRecordsView
                                        .blur(radius: activeMenuIndex != nil ? 6 : 0)
                                        .opacity(activeMenuIndex != nil ? 0.5 : 1.0)
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
                                .onTapGesture {
                                    saveAndDismiss()
                                }
                        )
                    }
                }
            }
        }
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: selectedDate)
        .animation(.spring(response: 0.35, dampingFraction: 0.8), value: activeMenuIndex)
        .animation(.spring(response: 0.35, dampingFraction: 0.8), value: isEditing)
        .onChange(of: selectedDate) { _, _ in saveAndDismiss() }
        .onDisappear {
            // Save data when the user closes the screen
            saveAndDismiss()
        }
    }
    
    // MARK: - Subviews
    
    private var futureDayView: some View {
        VStack(spacing: AdaptiveLayout.getSize(for: 12)) {
            Image(systemName: "moon.stars.fill")
                .font(.system(size: AdaptiveLayout.getSize(for: 40)))
                .foregroundColor(themeManager.currentTheme.textColor.opacity(0.2))
            Text("Oops! This day has not started yet")
                .textCase(.uppercase)
                .font(.lummiFont(size: 16))
                .foregroundColor(themeManager.currentTheme.textColor.opacity(0.6))
        }
    }
    
    private var noRecordsView: some View {
        Text("No records for this day")
            .textCase(.uppercase)
            .font(.lummiFont(size: 16))
            .foregroundColor(themeManager.currentTheme.textColor.opacity(0.3))
    }
    
    private func notesListView(entries: [JoyEntry], proxy: ScrollViewProxy) -> some View {
        VStack(alignment: .leading, spacing: AdaptiveLayout.getSize(for: 15)) {
            ForEach(entries.indices, id: \.self) { index in
                noteCell(for: index, entry: entries[index], proxy: proxy)
            }
        }
    }
    
    // MARK: - Interactive Cell
    
    @ViewBuilder
    private func noteCell(for index: Int, entry: JoyEntry, proxy: ScrollViewProxy) -> some View {
        let isActive = (activeMenuIndex == index)
        
        VStack(alignment: .trailing, spacing: AdaptiveLayout.getSize(for: 8)) {
            if isActive && !isEditing {
                noteCellActionButtons(index: index, entry: entry, proxy: proxy)
            }
            
            Group {
                if isActive && isEditing {
                    noteCellEditField
                } else {
                    noteCellTextDisplay(index: index, entry: entry, isActive: isActive, proxy: proxy)
                }
            }
        }
        .id(index)
        .blur(radius: (activeMenuIndex != nil && !isActive) ? 6 : 0)
        .opacity((activeMenuIndex != nil && !isActive) ? 0.4 : 1.0)
    }

    private func noteCellActionButtons(index: Int, entry: JoyEntry, proxy: ScrollViewProxy) -> some View {
        HStack(spacing: AdaptiveLayout.getSize(for: 12)) {
            Button(
                action: {
                    editingText = entry.text
                    isEditing = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        isTextFieldFocused = true
                        withAnimation(.spring()) {
                            proxy.scrollTo(index, anchor: .center)
                        }
                    }
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
                action: { deleteNote(at: index) },
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

    private var noteCellEditField: some View {
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

    private func noteCellTextDisplay(index: Int, entry: JoyEntry, isActive: Bool, proxy: ScrollViewProxy) -> some View {
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
            .accessibilityIdentifier("RecordText_\(index)")
    }
    
    // MARK: - Actions
    
    private func deleteNote(at index: Int) {
        guard index < todaysEntries.count else { return } // Safety check in case deletion fires rapidly
        let entry = todaysEntries[index]
        withAnimation {
            modelContext.delete(entry)
            try? modelContext.save() // Explicitly save to ensure CloudKit updates immediately
            activeMenuIndex = nil
        }
    }
    
    private func saveAndDismiss() {
        isTextFieldFocused = false
                
        guard let index = activeMenuIndex else { return }
        
        if isEditing {
            let trimmed = editingText.trimmingCharacters(in: .whitespacesAndNewlines)
            
            // Adding a safety check in case this is called during view destruction/disappearance
            if index < todaysEntries.count {
                let entry = todaysEntries[index]
                if trimmed.isEmpty {
                    modelContext.delete(entry)
                } else {
                    entry.text = trimmed
                }
                
                // Explicitly save data when the user has finished typing
                try? modelContext.save()
            }
        }
        
        withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
            activeMenuIndex = nil
            isEditing = false
        }
    }
}
