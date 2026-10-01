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

// Insights screen: stats and a report for the current month.
// The child view below fetches only that month's entries.
struct InsightsView: View {
    @Binding var isShowingAllJoys: Bool
    @Binding var isShowingTrends: Bool

    var body: some View {
        InsightsMonthView(month: Date().startOfMonth, isShowingAllJoys: $isShowingAllJoys, isShowingTrends: $isShowingTrends)
    }
}

// Stats and entries of the given month. The query is rebuilt whenever the parent passes a new month.
private struct InsightsMonthView: View {
    @Environment(ThemeManager.self) private var themeManager
    @Environment(\.locale) var locale
    @Binding var isShowingAllJoys: Bool
    @Binding var isShowingTrends: Bool

    // On iPhone the Joys and Day Streak cards are stacked to take the height of the Joyful Hours card
    private static let phoneCardHeight: CGFloat = 130
    private static let phoneStackSpacing: CGFloat = 10

    @Query private var monthlyEntries: [JoyEntry]

    init(month: Date, isShowingAllJoys: Binding<Bool>, isShowingTrends: Binding<Bool>) {
        _isShowingAllJoys = isShowingAllJoys
        _isShowingTrends = isShowingTrends
        _monthlyEntries = Query(filter: JoyEntry.monthPredicate(for: month), sort: \JoyEntry.date)
    }

    private var monthStreak: Int {
        InsightsCalculator.longestStreak(in: monthlyEntries)
    }

    // MARK: - Body
    var body: some View {
        if isShowingAllJoys {
            AllJoysView(entries: monthlyEntries, isShowingAllJoys: $isShowingAllJoys)
        } else if isShowingTrends {
            TrendsView(isShowingTrends: $isShowingTrends)
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

                // MARK: - Main Content Area
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 35) {

                        // MARK: - Highlights
                        VStack(alignment: .leading, spacing: 15) {
                            Text("Highlights")
                                .font(.lummiFont(size: 20, weight: .bold))
                                .foregroundColor(themeManager.currentTheme.textColor)
                                // Scroll content has 10pt horizontal padding; add 10 more to match Insights' 20pt inset
                                .padding(.leading, 10)

                            if AdaptiveLayout.isPad {
                                // MARK: - Joys, Joyful Hours & Streak (iPad: one row of squares)
                                let padCardSize = (geometry.size.width - 50) / 3

                                HStack(spacing: 15) {
                                    joysCard(height: padCardSize)
                                        .frame(width: padCardSize)

                                    joyfulHoursCard(height: padCardSize, valuePadding: 12)
                                        .frame(width: padCardSize)

                                    streakCard(height: padCardSize)
                                        .frame(width: padCardSize)
                                }
                            } else {
                                // MARK: - Joys & Streak stacked, next to Joyful Hours
                                let compactHeight = (Self.phoneCardHeight - Self.phoneStackSpacing) / 2

                                HStack(spacing: 15) {
                                    VStack(spacing: Self.phoneStackSpacing) {
                                        joysCard(height: compactHeight, isCompact: true)
                                        streakCard(height: compactHeight, isCompact: true)
                                    }

                                    joyfulHoursCard(height: Self.phoneCardHeight, valuePadding: 12)
                                }
                            }
                        }

                        // MARK: - Recall
                        VStack(alignment: .leading, spacing: 15) {
                            Text("Recall")
                                .font(.lummiFont(size: 20, weight: .bold))
                                .foregroundColor(themeManager.currentTheme.textColor)
                                // Scroll content has 10pt horizontal padding; add 10 more to match Insights' 20pt inset
                                .padding(.leading, 10)

                            DisclosureRow(
                                systemImage: "list.star",
                                iconColor: AccentColors.activeDays,
                                title: "Show All Joys",
                                accessibilityID: "SeeAllJoysButton"
                            ) {
                                withAnimation(.lummiSpring) {
                                    isShowingAllJoys = true
                                }
                            }
                        }

                        // MARK: - Trends
                        VStack(alignment: .leading, spacing: 15) {
                            Text("Trends")
                                .font(.lummiFont(size: 20, weight: .bold))
                                .foregroundColor(themeManager.currentTheme.textColor)
                                // Scroll content has 10pt horizontal padding; add 10 more to match Insights' 20pt inset
                                .padding(.leading, 10)

                            DisclosureRow(
                                systemImage: "chart.bar.fill",
                                iconColor: AccentColors.activeDays,
                                title: "View Trends",
                                accessibilityID: "ShowTrendsButton"
                            ) {
                                withAnimation(.lummiSpring) {
                                    isShowingTrends = true
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 10)
                    .padding(.bottom, 100)
                }
                .ignoresSafeArea(.container, edges: .bottom)
            }
        }
    }

    // MARK: - Highlight Cards

    // One value size for all three cards. The Joyful Hours range is a long string, so on the narrow iPhone cards
    // it needs a smaller size to fit without being scaled down further than the numbers next to it.
    private var valueFontSize: CGFloat {
        AdaptiveLayout.isPad ? 28 : 20
    }

    private func joysCard(height: CGFloat, isCompact: Bool = false) -> some View {
        GlowCard.joys(value: "\(monthlyEntries.count)", height: height, valueFontSize: valueFontSize, valuePadding: 12, isCompact: isCompact)
    }

    private func streakCard(height: CGFloat, isCompact: Bool = false) -> some View {
        GlowCard.streak(value: "\(monthStreak)", height: height, valueFontSize: valueFontSize, valuePadding: 12, isCompact: isCompact)
    }

    private func joyfulHoursCard(height: CGFloat, valuePadding: CGFloat) -> some View {
        GlowCard.joyfulHours(
            value: InsightsCalculator.calculateGoldenHours(entries: monthlyEntries, locale: locale),
            height: height,
            valueFontSize: valueFontSize,
            valuePadding: valuePadding
        )
    }
}

// MARK: - UI Components

struct GlowCard: View {
    @Environment(ThemeManager.self) private var themeManager
    var value: String
    var subtitle: LocalizedStringResource
    var systemImage: String
    var iconColor: Color?
    var gradientColors: [Color]
    var height: CGFloat = 170
    var valueFontSize: CGFloat = 45
    var valuePadding: CGFloat = 0
    // Low card: the subtitle and the value share one row instead of being stacked
    var isCompact = false

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 30)
                .fill(LinearGradient(colors: gradientColors, startPoint: .topLeading, endPoint: .bottomTrailing))
                .opacity(0.35)
                .adaptiveGlass(in: RoundedRectangle(cornerRadius: 30))

            if isCompact {
                compactContent
            } else {
                content
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: height)
        .overlay(
            RoundedRectangle(cornerRadius: 30)
                .stroke(themeManager.currentTheme.textColor.opacity(CardOpacity.prominentStroke), lineWidth: 1)
        )
    }

    private var subtitleLabel: some View {
        HStack(spacing: 4) {
            Image(systemName: systemImage)
                .font(.system(size: 11, weight: .semibold))
                .foregroundColor(iconColor ?? gradientColors.first ?? themeManager.currentTheme.textColor)

            Text(subtitle)
                .font(.lummiFont(size: 12))
                .opacity(0.7)
                .foregroundColor(themeManager.currentTheme.textColor.opacity(0.85))
        }
    }

    private var valueLabel: some View {
        Text(value)
            .font(.lummiFont(size: valueFontSize))
            .foregroundColor(themeManager.currentTheme.textColor)
            .minimumScaleFactor(0.3)
            .lineLimit(1)
    }

    // Value in the middle, subtitle at the bottom
    private var content: some View {
        ZStack {
            valueLabel
                .padding(.horizontal, valuePadding)

            VStack {
                Spacer()
                subtitleLabel
                    .padding(.bottom, 16)
            }
        }
    }

    // Subtitle on the leading edge, value on the trailing edge
    private var compactContent: some View {
        HStack(spacing: 8) {
            subtitleLabel
                .lineLimit(1)
                .minimumScaleFactor(0.7)
            Spacer(minLength: 0)
            valueLabel
        }
        .padding(.horizontal, 20)
    }
}

// Shared presets for the "Joys"/"Day Streak"/"Joyful Hours" cards shown by both Insights and Trends.
extension GlowCard {
    static func joys(value: String, height: CGFloat, valueFontSize: CGFloat, valuePadding: CGFloat, isCompact: Bool = false) -> GlowCard {
        GlowCard(
            value: value,
            subtitle: "Joys",
            systemImage: "star.fill",
            iconColor: AccentColors.joys,
            gradientColors: AccentColors.joysGradient,
            height: height,
            valueFontSize: valueFontSize,
            valuePadding: valuePadding,
            isCompact: isCompact
        )
    }

    static func streak(value: String, height: CGFloat, valueFontSize: CGFloat, valuePadding: CGFloat, isCompact: Bool = false) -> GlowCard {
        GlowCard(
            value: value,
            subtitle: "Day Streak",
            systemImage: "flame.fill",
            iconColor: AccentColors.streak,
            gradientColors: AccentColors.streakGradient,
            height: height,
            valueFontSize: valueFontSize,
            valuePadding: valuePadding,
            isCompact: isCompact
        )
    }

    static func joyfulHours(value: String, height: CGFloat, valueFontSize: CGFloat, valuePadding: CGFloat) -> GlowCard {
        GlowCard(
            value: value,
            subtitle: "Joyful Hours",
            systemImage: "sun.max.fill",
            gradientColors: AccentColors.joyfulHoursGradient,
            height: height,
            valueFontSize: valueFontSize,
            valuePadding: valuePadding
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

            NoteBubble {
                Text(entry.text)
                    .font(.lummiFont(size: 17))
                    .foregroundColor(themeManager.currentTheme.textColor)
            }
        }
        .padding(.leading, 4)
        .padding(.trailing, 15)
    }
}

#if DEBUG
#Preview {
    InsightsView(isShowingAllJoys: .constant(false), isShowingTrends: .constant(false))
        .previewEnvironment()
}
#endif
