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

struct InsightsView: View {
    @Environment(ThemeManager.self) private var themeManager
    @Environment(\.locale) var locale
    @Query private var allEntries: [JoyEntry]
    @State private var selectedMonth: Date = Date().startOfMonth
    @State private var isListExpanded: Bool = false

    private var monthlyEntries: [JoyEntry] {
        InsightsCalculator.filterEntries(allEntries, for: selectedMonth)
    }
    
    private var daysNeededForReport: Int {
        InsightsCalculator.daysNeededForReport(in: monthlyEntries)
    }

    private var monthStreak: Int {
        InsightsCalculator.longestStreak(in: monthlyEntries)
    }

    private var isCurrentMonth: Bool {
        Date.isCurrentMonth(selectedMonth)
    }
    
    private var isOldestMonth: Bool {
        Date.isOldestMonth(selectedMonth: selectedMonth, allEntries: allEntries)
    }

    // MARK: - Body
    var body: some View {
        GeometryReader { geometry in
            VStack(alignment: .leading, spacing: 20) {

                Text("Insights")
                    .font(.lummiFont(size: 24))
                    .foregroundColor(themeManager.currentTheme.textColor)
                    .padding(.top, 10)
                    .frame(maxWidth: .infinity, alignment: .center)

                // MARK: - Month Selector
                HStack(spacing: 20) {
                    Button(
                        action: { changeMonth(by: -1) },
                        label: {
                            Image(systemName: "chevron.left")
                                .font(.lummiFont(size: 18))
                                .foregroundColor(themeManager.currentTheme.textColor.opacity(isOldestMonth ? 0.2 : 0.8))
                        }
                    )
                    .disabled(isOldestMonth)
                    .accessibilityIdentifier("PreviousMonthButton")
                    
                    Text(formatMonth(selectedMonth))
                        .font(.lummiFont(size: 20))
                        .foregroundColor(themeManager.currentTheme.textColor.opacity(0.7))
                        .frame(minWidth: 160, alignment: .center)
                        .accessibilityIdentifier("CurrentMonthLabel")
                    
                    Button(
                        action: { changeMonth(by: 1) },
                        label: {
                            Image(systemName: "chevron.right")
                                .font(.lummiFont(size: 18))
                                .foregroundColor(themeManager.currentTheme.textColor.opacity(isCurrentMonth ? 0.2 : 0.8))
                        }
                    )
                    .disabled(isCurrentMonth)
                    .accessibilityIdentifier("NextMonthButton")
                }
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.bottom, 10)

                // MARK: - Main Content Area
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 35) {
                        
                        let itemSize = geometry.size.width * 0.42
                        
                        // MARK: - Joys & Streak
                        HStack(spacing: 15) {
                            GlowCard(
                                value: "\(monthlyEntries.count)",
                                subtitle: "Joys",
                                gradientColors: [Color(red: 1.0, green: 0.7, blue: 0.75), Color(red: 0.95, green: 0.4, blue: 0.55)]
                            )
                            
                            GlowCard(
                                value: "\(monthStreak)",
                                subtitle: "Day streak",
                                gradientColors: [Color(red: 1.0, green: 0.8, blue: 0.3), Color(red: 0.95, green: 0.4, blue: 0.1)]
                            )
                        }
                        .frame(maxWidth: .infinity, minHeight: itemSize * 0.8)
                        
                        // MARK: - Joyful Hours
                        GlowCard(
                            value: InsightsCalculator.calculateGoldenHours(entries: monthlyEntries, locale: locale),
                            subtitle: "Joyful Hours",
                            gradientColors: [Color(red: 0.6, green: 0.3, blue: 0.8), Color(red: 1.0, green: 0.8, blue: 0.3)],
                            height: 130,
                            valueFontSize: 38,
                            valuePadding: 50
                        )
                        
                        // MARK: - All Moments
                        if !monthlyEntries.isEmpty {
                            VStack(spacing: 0) {
                                Button(
                                    action: {
                                        withAnimation(.spring(response: 0.35, dampingFraction: 0.82)) {
                                            isListExpanded.toggle()
                                        }
                                    },
                                    label: {
                                        ZStack {
                                            HStack(spacing: 8) {
                                                Text("Want to see all moments?")
                                                    .font(.lummiFont(size: 18))
                                                    .foregroundColor(themeManager.currentTheme.textColor)
                                                
                                                Image(systemName: "chevron.down")
                                                    .font(.system(size: 14, weight: .bold))
                                                    .foregroundColor(themeManager.currentTheme.textColor.opacity(0.6))
                                                    .rotationEffect(.degrees(isListExpanded ? 180 : 0))
                                            }
                                            VStack {
                                                Spacer()
                                                Text("Tap here")
                                                    .font(.lummiFont(size: 12))
                                                    .opacity(0.7)
                                                    .foregroundColor(themeManager.currentTheme.textColor.opacity(0.85))
                                                    .padding(.bottom, 16)
                                            }
                                        }
                                        .frame(maxWidth: .infinity)
                                        .frame(height: 130)
                                        .background {
                                            ZStack {
                                                RoundedRectangle(cornerRadius: 30)
                                                    .fill(
                                                        LinearGradient(
                                                            colors: [
                                                                Color(red: 1.0, green: 0.8, blue: 0.3),
                                                                Color(red: 0.2, green: 0.6, blue: 0.3)
                                                            ],
                                                            startPoint: .topLeading,
                                                            endPoint: .bottomTrailing
                                                        )
                                                    )
                                                    .blur(radius: 15)
                                                    .opacity(0.8)
                                            }
                                            .frame(maxWidth: .infinity)
                                            .padding(.horizontal, 15)
                                        }
                                    }
                                )
                                .buttonStyle(.plain)
                                .zIndex(1)
                                
                                if isListExpanded {
                                    VStack(spacing: 12) {
                                        ForEach(monthlyEntries.sorted(by: { $0.date > $1.date })) { entry in
                                            MonthlyMomentCell(entry: entry)
                                        }
                                    }
                                    .padding(.top, 35)
                                    .zIndex(0)
                                    .transition(.opacity.combined(with: .offset(y: -40)))
                                }
                            }
                            .padding(.bottom, 40)
                        }
                    }
                    .padding(.top, 30)
                    .padding(.horizontal, 10)
                    .padding(.bottom, 100)
                }
                .ignoresSafeArea(.container, edges: .bottom)
            }
        }
        .onAppear {
            selectedMonth = Date().startOfMonth
        }
    }
    
    // MARK: - UI Helpers

    private func changeMonth(by value: Int) {
        if let newMonth = Calendar.current.date(byAdding: .month, value: value, to: selectedMonth) {
            withAnimation(.spring(response: 0.35, dampingFraction: 0.82)) {
                selectedMonth = newMonth
                isListExpanded = false
            }
        }
    }
    
    private func formatMonth(_ date: Date) -> String {
        date.format("LLLL yyyy", locale: locale).capitalizedFirstLetter
    }
}

// MARK: - UI Components

struct GlowCard: View {
    @Environment(ThemeManager.self) private var themeManager
    var value: String
    var subtitle: LocalizedStringResource
    var gradientColors: [Color]
    var height: CGFloat = 170
    var valueFontSize: CGFloat = 45
    var valuePadding: CGFloat = 0

    var body: some View {
        ZStack {
            Text(value)
                .font(.lummiFont(size: valueFontSize))
                .foregroundColor(themeManager.currentTheme.textColor)
                .minimumScaleFactor(0.4)
                .lineLimit(1)
                .padding(.horizontal, valuePadding)

            VStack {
                Spacer()
                Text(subtitle)
                    .font(.lummiFont(size: 12))
                    .opacity(0.7)
                    .foregroundColor(themeManager.currentTheme.textColor.opacity(0.85))
                    .padding(.bottom, 16)
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: height)
        .background {
            RoundedRectangle(cornerRadius: 30)
                .fill(LinearGradient(colors: gradientColors, startPoint: .topLeading, endPoint: .bottomTrailing))
                .blur(radius: 15)
                .opacity(0.8)
                .padding(.horizontal, 15)
        }
    }
}

struct MonthlyMomentCell: View {
    @Environment(ThemeManager.self) private var themeManager
    @Environment(\.locale) var locale
    let entry: JoyEntry
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            VStack(alignment: .center, spacing: 2) {
                Text(entry.date.format("dd", locale: locale))
                    .font(.lummiFont(size: 18))
                    .foregroundColor(themeManager.currentTheme.textColor)
                
                Text(entry.date.format("MMM", locale: locale).capitalizedFirstLetter)
                    .font(.lummiFont(size: 11))
                    .foregroundColor(themeManager.currentTheme.textColor.opacity(0.5))
            }
            .frame(width: 35)
            .padding(.top, 4)

            Text(entry.text)
                .font(.lummiFont(size: 16))
                .foregroundColor(themeManager.currentTheme.textColor)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(16)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(themeManager.currentTheme.textColor.opacity(0.05))
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(themeManager.currentTheme.textColor.opacity(0.1), lineWidth: 1)
                        )
                )
        }
        .padding(.leading, 4)
        .padding(.trailing, 15)
    }
}
