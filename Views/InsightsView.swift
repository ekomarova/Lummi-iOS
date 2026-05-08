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

struct InsightsView: View {
    @EnvironmentObject var themeManager: ThemeManager
    @Environment(\.locale) var locale
    @Query private var allEntries: [JoyEntry]
    @State private var selectedMonth: Date = Date().startOfMonth
    @State private var isListExpanded: Bool = false

    private var monthlyEntries: [JoyEntry] {
        let calendar = Calendar.current
        return allEntries.filter { calendar.isDate($0.date, equalTo: selectedMonth, toGranularity: .month) }
    }
    
    private var pastMonthEntries: [JoyEntry] {
        let calendar = Calendar.current
        guard let pastMonth = calendar.date(byAdding: .month, value: -1, to: selectedMonth) else { return [] }
        return allEntries.filter { calendar.isDate($0.date, equalTo: pastMonth, toGranularity: .month) }
    }

    private var monthStreak: Int {
        InsightsCalculator.longestStreak(in: monthlyEntries)
    }

    private var isCurrentMonth: Bool {
        Calendar.current.isDate(selectedMonth, equalTo: Date(), toGranularity: .month)
    }
    
    private var isOldestMonth: Bool {
        guard let oldestEntry = allEntries.min(by: { $0.date < $1.date }) else { return true }
        
        let oldestMonth = oldestEntry.date.startOfMonth
        return selectedMonth <= oldestMonth
    }

    var body: some View {
        GeometryReader { geometry in
            VStack(alignment: .leading, spacing: AdaptiveLayout.getSize(for: 20)) {

                Text("Insights")
                    .textCase(.uppercase)
                    .font(.lummiFont(size: 24))
                    .foregroundColor(themeManager.currentTheme.textColor)
                    .padding(.top, 10)
                    .frame(maxWidth: .infinity, alignment: .center)

                // MARK: - Month Selector
                HStack(spacing: 20) {
                    Button(action: { changeMonth(by: -1) }) {
                        Image(systemName: "chevron.left")
                            .font(.lummiFont(size: 18))
                            .foregroundColor(themeManager.currentTheme.textColor.opacity(isOldestMonth ? 0.2 : 0.8))
                    }
                    .disabled(isOldestMonth)
                    .accessibilityIdentifier("PreviousMonthButton")
                    
                    Text(formatMonth(selectedMonth))
                        .font(.lummiFont(size: 20))
                        .foregroundColor(themeManager.currentTheme.textColor.opacity(0.7))
                        .frame(minWidth: 160, alignment: .center)
                        .accessibilityIdentifier("CurrentMonthLabel")
                    
                    Button(action: { changeMonth(by: 1) }) {
                        Image(systemName: "chevron.right")
                            .font(.lummiFont(size: 18))
                            .foregroundColor(themeManager.currentTheme.textColor.opacity(isCurrentMonth ? 0.2 : 0.8))
                    }
                    .disabled(isCurrentMonth)
                    .accessibilityIdentifier("NextMonthButton")
                }
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.bottom, 10)

                // MARK: - Insights Grid
                ScrollView(showsIndicators: false) {
                    VStack(spacing: AdaptiveLayout.getSize(for: 35)) {
                        
                        let itemSize = geometry.size.width * 0.42
                        
                        let comparisonData = InsightsCalculator.getMonthComparisonMessage(
                            currentCount: monthlyEntries.count,
                            pastCount: pastMonthEntries.count,
                            isFirstMonth: isOldestMonth
                        )
                        
                        InsightGlowCard(
                            value: "",
                            subtitle: comparisonData.text,
                            gradientColors: [Color(red: 0.4, green: 0.85, blue: 0.95), Color(red: 0.2, green: 0.5, blue: 0.9)],
                            isWide: true
                        )
                        .accessibilityIdentifier(comparisonData.id)
                        
                        HStack(spacing: AdaptiveLayout.getSize(for: 15)) {
                            InsightGlowCard(
                                value: "\(monthlyEntries.count)",
                                subtitle: "Joys",
                                gradientColors: [Color(red: 1.0, green: 0.7, blue: 0.75), Color(red: 0.95, green: 0.4, blue: 0.55)]
                            )
                            
                            InsightGlowCard(
                                value: "\(monthStreak)",
                                subtitle: "Day streak",
                                gradientColors: [Color(red: 1.0, green: 0.8, blue: 0.3), Color(red: 0.95, green: 0.4, blue: 0.1)]
                            )
                        }
                        .frame(maxWidth: .infinity, minHeight: itemSize * 0.8)
                    
                    // MARK: - Full joy list
                        if !monthlyEntries.isEmpty {
                            VStack(spacing: 0) {
                                Button(action: {
                                    withAnimation(.spring(response: 0.35, dampingFraction: 0.82)) {
                                        isListExpanded.toggle()
                                    }
                                }) {
                                    ZStack {
                                        HStack(spacing: 8) {
                                            Text("Want to see all moments?")
                                                .textCase(.uppercase)
                                                .font(.lummiFont(size: 15))
                                                .foregroundColor(themeManager.currentTheme.textColor)
                                            
                                            Image(systemName: "chevron.down")
                                                .font(.system(size: 14, weight: .bold))
                                                .foregroundColor(themeManager.currentTheme.textColor.opacity(0.6))
                                                .rotationEffect(.degrees(isListExpanded ? 180 : 0))
                                        }
                                    }
                                    .frame(maxWidth: .infinity)
                                    .frame(height: AdaptiveLayout.getSize(for: 130))
                                    .background {
                                        ZStack {
                                            RoundedRectangle(cornerRadius: 30)
                                                .fill(
                                                    LinearGradient(
                                                        colors: [Color(red: 0.4, green: 0.8, blue: 0.4), Color(red: 0.2, green: 0.6, blue: 0.2)],
                                                        startPoint: .topLeading,
                                                        endPoint: .bottomTrailing
                                                    )
                                                )
                                                .blur(radius: 15)
                                                .opacity(0.8)
                                        }
                                        .frame(maxWidth: .infinity)
                                        .padding(.horizontal, AdaptiveLayout.getSize(for: 15))
                                    }
                                }
                                .buttonStyle(.plain)

                                if isListExpanded {
                                    VStack(spacing: AdaptiveLayout.getSize(for: 12)) {
                                        ForEach(monthlyEntries.sorted(by: { $0.date > $1.date })) { entry in
                                            MonthlyMomentCell(entry: entry)
                                        }
                                    }
                                    .padding(.top, AdaptiveLayout.getSize(for: 35))
                                    .transition(.move(edge: .top).combined(with: .opacity))
                                }
                            }
                            .padding(.bottom, AdaptiveLayout.getSize(for: 40))
                        }
                    }
                    .padding(.top, AdaptiveLayout.getSize(for: 30))
                    .padding(.horizontal, AdaptiveLayout.getSize(for: 10))
                    .padding(.bottom, AdaptiveLayout.getSize(for: 100))
                }
            }
        }
        .onAppear {
            selectedMonth = Date().startOfMonth
        }
    }
    
// MARK: - Helpers
    
private func changeMonth(by value: Int) {
    if let newMonth = Calendar.current.date(byAdding: .month, value: value, to: selectedMonth) {
        withAnimation(.spring(response: 0.35, dampingFraction: 0.82)) {
            selectedMonth = newMonth
        }
    }
}

private func formatMonth(_ date: Date) -> String {
    let formatter = DateFormatter()
    formatter.locale = locale
    formatter.dateFormat = "LLLL yyyy"
    return formatter.string(from: date).uppercased()
    }
}

struct InsightGlowCard: View {
    @EnvironmentObject var themeManager: ThemeManager
    var value: String
    var subtitle: LocalizedStringResource
    var gradientColors: [Color]
    var isWide: Bool = false
    
    var body: some View {
        ZStack {
            if isWide {
                Text(subtitle)
                    .textCase(.uppercase)
                    .font(.lummiFont(size: 15))
                    .foregroundColor(themeManager.currentTheme.textColor)
                    .multilineTextAlignment(.center)
                    .lineLimit(4)
                    .minimumScaleFactor(0.8)
                    .padding(.horizontal, AdaptiveLayout.getSize(for: 16))
            } else {
                VStack(spacing: 0) {
                    Spacer()
                    
                    Text(value)
                        .font(.lummiFont(size: 45))
                        .foregroundColor(themeManager.currentTheme.textColor)
                        .minimumScaleFactor(0.5)
                        .lineLimit(1)
                    
                    Spacer()
                    
                    Text(subtitle)
                        .textCase(.uppercase)
                        .font(.lummiFont(size: 12))
                        .foregroundColor(themeManager.currentTheme.textColor.opacity(0.85))
                        .padding(.bottom, AdaptiveLayout.getSize(for: 16))
                }
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: AdaptiveLayout.getSize(for: isWide ? 130 : 170))
        .background {
            ZStack {
                RoundedRectangle(cornerRadius: 30)
                    .fill(
                        LinearGradient(
                            colors: gradientColors,
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .blur(radius: 15)
                    .opacity(0.8)
            }
            .frame(maxWidth: .infinity)
            .padding(.horizontal, AdaptiveLayout.getSize(for: 15))
        }
    }
}

struct MonthlyMomentCell: View {
    @EnvironmentObject var themeManager: ThemeManager
    @Environment(\.locale) var locale
    let entry: JoyEntry
    
    var body: some View {
        HStack(alignment: .top, spacing: AdaptiveLayout.getSize(for: 12)) {
            VStack(alignment: .center, spacing: 2) {
                Text(entry.date.format("dd", locale: locale))
                    .font(.lummiFont(size: 18))
                    .foregroundColor(themeManager.currentTheme.textColor)
                
                Text(entry.date.format("MMM", locale: locale).uppercased())
                    .font(.lummiFont(size: 11))
                    .foregroundColor(themeManager.currentTheme.textColor.opacity(0.5))
            }
            .frame(width: AdaptiveLayout.getSize(for: 35))
            .padding(.top, AdaptiveLayout.getSize(for: 4))

            Text(entry.text)
                .font(.lummiFont(size: 16))
                .foregroundColor(themeManager.currentTheme.textColor)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(AdaptiveLayout.getSize(for: 16))
                .background(
                    RoundedRectangle(cornerRadius: AdaptiveLayout.getSize(for: 16))
                        .fill(themeManager.currentTheme.textColor.opacity(0.05))
                        .overlay(
                            RoundedRectangle(cornerRadius: AdaptiveLayout.getSize(for: 16))
                                .stroke(themeManager.currentTheme.textColor.opacity(0.1), lineWidth: 1)
                        )
                )
        }
        .padding(.leading, AdaptiveLayout.getSize(for: 4))
        .padding(.trailing, AdaptiveLayout.getSize(for: 15))
    }
}

extension Date {
    func format(_ format: String, locale: Locale = .current) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        formatter.locale = locale
        return formatter.string(from: self)
    }
}
