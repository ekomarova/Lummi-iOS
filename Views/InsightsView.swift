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
    @Binding var isShowingAllJoys: Bool
    @State private var selectedMonth: Date = Date().startOfMonth

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
        if isShowingAllJoys {
            AllJoysView(entries: monthlyEntries, isShowingAllJoys: $isShowingAllJoys)
        } else {
            insightsContent
        }
    }

    private var insightsContent: some View {
        GeometryReader { geometry in
            VStack(alignment: .leading, spacing: 20) {

                Text("Insights")
                    .font(.lummiFont(size: 24, weight: .bold))
                    .foregroundColor(themeManager.currentTheme.textColor)
                    .padding(.top, 10)
                    .padding(.horizontal, 20)

                // MARK: - Month Selector
                HStack(spacing: 20) {
                    Button(
                        action: { changeMonth(by: -1) },
                        label: {
                            Circle()
                                .fill(themeManager.currentTheme.textColor.opacity(0.05))
                                .adaptiveGlass(in: Circle())
                                .frame(width: 36, height: 36)
                                .overlay(
                                    Image(systemName: "chevron.left")
                                        .font(.lummiFont(size: 16, weight: .bold))
                                        .foregroundColor(themeManager.currentTheme.textColor.opacity(isOldestMonth ? 0.2 : 0.8))
                                )
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
                            Circle()
                                .fill(themeManager.currentTheme.textColor.opacity(0.05))
                                .adaptiveGlass(in: Circle())
                                .frame(width: 36, height: 36)
                                .overlay(
                                    Image(systemName: "chevron.right")
                                        .font(.lummiFont(size: 16, weight: .bold))
                                        .foregroundColor(themeManager.currentTheme.textColor.opacity(isCurrentMonth ? 0.2 : 0.8))
                                )
                        }
                    )
                    .disabled(isCurrentMonth)
                    .accessibilityIdentifier("NextMonthButton")
                }
                .frame(maxWidth: .infinity, alignment: .center)

                // MARK: - Main Content Area
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 35) {

                        let itemSize = geometry.size.width * 0.09

                        Text("Highlights")
                            .font(.lummiFont(size: 20, weight: .bold))
                            .foregroundColor(themeManager.currentTheme.textColor)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            // Scroll content has 10pt horizontal padding; add 10 more to match Insights' 20pt inset
                            .padding(.leading, 10)

                        if AdaptiveLayout.isPad {
                            // MARK: - Joys, Streak & Joyful Hours (iPad: one row of squares)
                            let padCardSize = (geometry.size.width - 50) / 3

                            HStack(spacing: 15) {
                                GlowCard(
                                    value: "\(monthlyEntries.count)",
                                    subtitle: "Joys",
                                    gradientColors: [Color(red: 1.0, green: 0.7, blue: 0.75), Color(red: 0.95, green: 0.4, blue: 0.55)],
                                    height: padCardSize,
                                    valueFontSize: 28,
                                    valuePadding: 12
                                )
                                .frame(width: padCardSize)

                                GlowCard(
                                    value: InsightsCalculator.calculateGoldenHours(entries: monthlyEntries, locale: locale),
                                    subtitle: "Joyful Hours",
                                    gradientColors: [Color(red: 0.6, green: 0.3, blue: 0.8), Color(red: 1.0, green: 0.8, blue: 0.3)],
                                    height: padCardSize,
                                    valueFontSize: 28,
                                    valuePadding: 12
                                )
                                .frame(width: padCardSize)

                                GlowCard(
                                    value: "\(monthStreak)",
                                    subtitle: "Day streak",
                                    gradientColors: [Color(red: 1.0, green: 0.8, blue: 0.3), Color(red: 0.95, green: 0.4, blue: 0.1)],
                                    height: padCardSize,
                                    valueFontSize: 28,
                                    valuePadding: 12
                                )
                                .frame(width: padCardSize)
                            }
                            // VStack spacing is 35; pull up so the gap to Highlights matches the 15pt gap below
                            .padding(.top, -26)
                        } else {
                            // MARK: - Joys & Streak
                            HStack(spacing: 15) {
                                GlowCard(
                                    value: "\(monthlyEntries.count)",
                                    subtitle: "Joys",
                                    gradientColors: [Color(red: 1.0, green: 0.7, blue: 0.75), Color(red: 0.95, green: 0.4, blue: 0.55)],
                                    valueFontSize: 28,
                                    valuePadding: 12
                                )

                                GlowCard(
                                    value: "\(monthStreak)",
                                    subtitle: "Day streak",
                                    gradientColors: [Color(red: 1.0, green: 0.8, blue: 0.3), Color(red: 0.95, green: 0.4, blue: 0.1)],
                                    valueFontSize: 28,
                                    valuePadding: 12
                                )
                            }
                            .frame(maxWidth: .infinity, minHeight: itemSize * 0.65)
                            // VStack spacing is 35; pull up so the gap to Highlights matches the 15pt gap below
                            .padding(.top, -26)

                            // MARK: - Joyful Hours
                            GlowCard(
                                value: InsightsCalculator.calculateGoldenHours(entries: monthlyEntries, locale: locale),
                                subtitle: "Joyful Hours",
                                gradientColors: [Color(red: 0.6, green: 0.3, blue: 0.8), Color(red: 1.0, green: 0.8, blue: 0.3)],
                                height: 100,
                                valueFontSize: 28,
                                valuePadding: 30
                            )
                            // VStack spacing is 35; pull up so the gap to Joys/Day streak matches their 15pt gap
                            .padding(.top, -20)
                        }
                        
                        // MARK: - Recall
                        if !monthlyEntries.isEmpty {
                            Text("Recall")
                                .font(.lummiFont(size: 20, weight: .bold))
                                .foregroundColor(themeManager.currentTheme.textColor)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                // Scroll content has 10pt horizontal padding; add 10 more to match Insights' 20pt inset
                                .padding(.leading, 10)

                            Button(
                                action: {
                                    withAnimation(.spring(response: 0.35, dampingFraction: 0.82)) {
                                        isShowingAllJoys = true
                                    }
                                },
                                label: {
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
                                            .opacity(0.35)
                                            .adaptiveGlass(in: RoundedRectangle(cornerRadius: 30))

                                        HStack {
                                            Text("See all joys")
                                                .font(.lummiFont(size: 18))
                                                .foregroundColor(themeManager.currentTheme.textColor)

                                            Spacer()

                                            Image(systemName: "chevron.right")
                                                .font(.system(size: 14, weight: .bold))
                                                .foregroundColor(themeManager.currentTheme.textColor.opacity(0.6))
                                        }
                                        .padding(.horizontal, 26)
                                    }
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 52)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 30)
                                            .stroke(themeManager.currentTheme.textColor.opacity(0.15), lineWidth: 1)
                                    )
                                }
                            )
                            .buttonStyle(.plain)
                            .accessibilityIdentifier("SeeAllJoysButton")
                            // VStack spacing is 35; pull up so the gap to Recall matches the 15pt gap above
                            // (extra offset vs. the -20 used elsewhere compensates for the Text's own line-height padding)
                            .padding(.top, -26)
                        }
                    }
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
            RoundedRectangle(cornerRadius: 30)
                .fill(LinearGradient(colors: gradientColors, startPoint: .topLeading, endPoint: .bottomTrailing))
                .opacity(0.35)
                .adaptiveGlass(in: RoundedRectangle(cornerRadius: 30))

            Text(value)
                .font(.lummiFont(size: valueFontSize))
                .foregroundColor(themeManager.currentTheme.textColor)
                .minimumScaleFactor(0.3)
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
        .overlay(
            RoundedRectangle(cornerRadius: 30)
                .stroke(themeManager.currentTheme.textColor.opacity(0.15), lineWidth: 1)
        )
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
                .padding(20)
                .frame(maxWidth: .infinity, alignment: .leading)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.white.opacity(0.25), lineWidth: 1)
                )
        }
        .padding(.leading, 4)
        .padding(.trailing, 15)
    }
}

struct AllJoysView: View {
    @Environment(ThemeManager.self) private var themeManager
    let entries: [JoyEntry]
    @Binding var isShowingAllJoys: Bool

    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                Text("All joys")
                    .font(.lummiFont(size: 24, weight: .bold))
                    .foregroundColor(themeManager.currentTheme.textColor)
                    .frame(maxWidth: .infinity, alignment: .center)

                HStack {
                    Button(
                        action: {
                            withAnimation(.spring(response: 0.35, dampingFraction: 0.82)) {
                                isShowingAllJoys = false
                            }
                        },
                        label: {
                            Circle()
                                .fill(themeManager.currentTheme.textColor.opacity(0.05))
                                .adaptiveGlass(in: Circle())
                                .frame(width: 44, height: 44)
                                .overlay(
                                    Image(systemName: "arrow.left")
                                        .font(.lummiFont(size: 16, weight: .bold))
                                        .foregroundColor(themeManager.currentTheme.textColor)
                                )
                        }
                    )
                    .buttonStyle(.plain)
                    .accessibilityIdentifier("AllJoysBackButton")

                    Spacer()
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 10)

            ScrollView(showsIndicators: false) {
                VStack(spacing: 12) {
                    ForEach(entries.sorted(by: { $0.date > $1.date })) { entry in
                        MonthlyMomentCell(entry: entry)
                    }
                }
                .padding(.top, 30)
                .padding(.horizontal, 10)
                .padding(.bottom, 100)
            }
            .ignoresSafeArea(.container, edges: .bottom)
        }
        .transition(.move(edge: .trailing).combined(with: .opacity))
    }
}
