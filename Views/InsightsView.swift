//
//  Required Notice: Copyright Evseniia Komarova (https://github.com/ekomarova)
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
    // Opens a page on the Insights tab's stack.
    let onNavigate: (Route) -> Void

    var body: some View {
        InsightsMonthView(month: Date().startOfMonth, onNavigate: onNavigate)
    }
}

// Stats and entries of the given month. The query is rebuilt whenever the parent passes a new month.
private struct InsightsMonthView: View {
    @Environment(ThemeManager.self) private var themeManager
    @Environment(\.locale) var locale
    let onNavigate: (Route) -> Void

    private static let cardHeight: CGFloat = 130

    @Query private var monthlyEntries: [JoyEntry]

    init(month: Date, onNavigate: @escaping (Route) -> Void) {
        self.onNavigate = onNavigate
        _monthlyEntries = Query(filter: JoyEntry.monthPredicate(for: month), sort: \JoyEntry.date)
    }

    // MARK: - Body
    var body: some View {
        // The title's protected zone takes 12pt of the old 20pt gap (see `scrollHeaderBackground`).
        VStack(alignment: .leading, spacing: 8) {

            Text("Insights")
                .font(.lummiFont(size: 32, weight: .bold))
                .foregroundColor(themeManager.currentTheme.textColor)
                .padding(.top, 10)
                .padding(.horizontal, 20)
                .scrollHeaderBackground(alignment: .leading)

            // MARK: - Main Content Area
            ScrollView(showsIndicators: false) {
                VStack(spacing: 35) {

                    // MARK: - Highlights
                    VStack(alignment: .leading, spacing: 15) {
                        SectionHeader(title: "Highlights", leadingInset: 10)

                        // MARK: - Joys & Joyful Hours
                        HStack(spacing: 15) {
                            joysCard(height: Self.cardHeight)
                            joyfulHoursCard(height: Self.cardHeight)
                        }
                    }

                    // MARK: - Recall
                    VStack(alignment: .leading, spacing: 15) {
                        SectionHeader(title: "Recall", leadingInset: 10)

                        DisclosureRow(
                            systemImage: "list.star",
                            iconColor: AccentColors.activeDays,
                            title: "Show All Joys",
                            accessibilityID: "SeeAllJoysButton"
                        ) {
                            onNavigate(.allJoys)
                        }
                    }

                    // MARK: - Trends
                    VStack(alignment: .leading, spacing: 15) {
                        SectionHeader(title: "Trends", leadingInset: 10)

                        DisclosureRow(
                            systemImage: "chart.bar.fill",
                            iconColor: AccentColors.activeDays,
                            title: "View Trends",
                            accessibilityID: "ShowTrendsButton"
                        ) {
                            onNavigate(.trends)
                        }
                    }
                }
                .padding(.horizontal, 10)
                .padding(.bottom, 100)
            }
            .scrollClipDisabled()
            .ignoresSafeArea(.container, edges: .bottom)
        }
    }

    // MARK: - Highlight Cards

    // One value size for both cards. The Joyful Hours range is a long string, so on the narrow iPhone cards
    // it needs a smaller size to fit without being scaled down further than the numbers next to it.
    private var valueFontSize: CGFloat {
        AdaptiveLayout.isPad ? 28 : 20
    }

    private func joysCard(height: CGFloat) -> some View {
        GlowCard.joys(value: "\(monthlyEntries.count)", height: height, valueFontSize: valueFontSize, valuePadding: 12)
    }

    private func joyfulHoursCard(height: CGFloat) -> some View {
        GlowCard.joyfulHours(
            value: InsightsCalculator.calculateGoldenHours(entries: monthlyEntries, locale: locale),
            height: height,
            valueFontSize: valueFontSize,
            valuePadding: 12
        )
    }
}

// MARK: - UI Components

struct GlowCard: View {
    // The card keeps the same bright colors and dark text in light and dark mode.
    private let cardTheme = LightTheme()
    var value: String
    var subtitle: LocalizedStringResource
    var systemImage: String
    var gradientColors: [Color]
    var height: CGFloat
    var valueFontSize: CGFloat
    var valuePadding: CGFloat

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 30)
                .fill(LinearGradient(colors: gradientColors, startPoint: .leading, endPoint: .trailing))

            content
        }
        .frame(maxWidth: .infinity)
        .frame(height: height)
    }

    private var subtitleLabel: some View {
        HStack(spacing: 4) {
            Image(systemName: systemImage)
                .font(.system(size: 11, weight: .semibold))
                .foregroundColor(cardTheme.textColor)

            Text(subtitle)
                .font(.lummiFont(size: 12))
                .opacity(0.7)
                .foregroundColor(cardTheme.textColor.opacity(0.85))
        }
    }

    private var valueLabel: some View {
        Text(value)
            .font(.lummiFont(size: valueFontSize))
            .foregroundColor(cardTheme.textColor)
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
}

// Shared presets for the "Joys"/"Day Streak"/"Joyful Hours" cards shown by both Insights and Trends.
extension GlowCard {
    static func joys(value: String, height: CGFloat, valueFontSize: CGFloat, valuePadding: CGFloat) -> GlowCard {
        GlowCard(
            value: value,
            subtitle: "Joys",
            systemImage: "star.fill",
            gradientColors: AccentColors.joysGradient,
            height: height,
            valueFontSize: valueFontSize,
            valuePadding: valuePadding
        )
    }

    static func streak(value: String, height: CGFloat, valueFontSize: CGFloat, valuePadding: CGFloat) -> GlowCard {
        GlowCard(
            value: value,
            subtitle: "Day Streak",
            systemImage: "flame.fill",
            gradientColors: AccentColors.streakGradient,
            height: height,
            valueFontSize: valueFontSize,
            valuePadding: valuePadding
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
    // False for all but the latest entry of a day: the date column stays as empty space so the bubbles still align.
    var showsDate = true

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            dateLabel
                .frame(width: 35)
                .padding(.top, 4)
                .opacity(showsDate ? 1 : 0)
                .accessibilityHidden(!showsDate)

            NoteBubble {
                Text(entry.text)
                    .font(.lummiFont(size: 17))
                    .foregroundColor(themeManager.currentTheme.textColor)
            }
        }
        .padding(.leading, 4)
        .padding(.trailing, 15)
    }

    private var dateLabel: some View {
        VStack(alignment: .center, spacing: 2) {
            Text(entry.date.format("dd", locale: locale))
                .font(.lummiFont(size: 18))
                .foregroundColor(themeManager.currentTheme.textColor)

            Text(entry.date.format("MMM", locale: locale).capitalizedFirstLetter)
                .font(.lummiFont(size: 11))
                .foregroundColor(themeManager.currentTheme.textColor.opacity(0.5))
        }
    }
}

#if DEBUG
#Preview {
    InsightsView(onNavigate: { _ in })
        .previewEnvironment()
}
#endif
