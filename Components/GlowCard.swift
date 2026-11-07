//
//  Required Notice: Copyright Evseniia Komarova (https://github.com/ekomarova)
//
//  Licensed under the PolyForm Noncommercial License 1.0.0.
//  See the LICENSE file in the repository root for full terms.
//  <https://polyformproject.org/licenses/noncommercial/1.0.0>
//

import SwiftUI

// A highlight card: one bright gradient, a big value in the middle and a caption at the bottom.
// Shared by Insights and Trends. The text scales with the system text size and shrinks to fit the card's width.
struct GlowCard: View {
    // Sizes of a card. Each screen has its own set, so its cards stay in step with each other.
    struct Metrics {
        let height: CGFloat
        let valueFontSize: CGFloat
        let valuePadding: CGFloat

        private static let cardHeight: CGFloat = 130

        // One value size for both Insights cards. The Joyful Hours range is a long string, so on the narrow iPhone
        // cards it needs a smaller size to fit without being scaled down further than the numbers next to it.
        static var insights: Metrics {
            Metrics(height: cardHeight, valueFontSize: AdaptiveLayout.isPad ? 28 : 20, valuePadding: 12)
        }

        // The three-across row of count cards on Trends.
        static let trends = Metrics(height: cardHeight, valueFontSize: 26, valuePadding: 8)

        // Joyful Hours on Trends: full-width on iPhone, since the "HH:mm - HH:mm" value is wider than a short number
        // and doesn't fit the three-across row; a quarter of the row on iPad, hence the smaller padding.
        // `valueFontSize` still matches the other cards for a consistent look.
        static var trendsJoyfulHours: Metrics {
            Metrics(height: cardHeight, valueFontSize: 26, valuePadding: AdaptiveLayout.isPad ? 12 : 30)
        }
    }

    // The caption is a little fainter than the value (about the same as the two stacked opacities it had before).
    private static let captionOpacity = 0.6

    // Grows with the text size the user picked in Settings (1 at the default size), so the card and its text scale together.
    // Capped so the largest text sizes don't turn the cards into a wall of color.
    @ScaledMetric(relativeTo: .title) private var textScale: CGFloat = 1
    private static let maxTextScale: CGFloat = 1.5
    private var scale: CGFloat { min(textScale, Self.maxTextScale) }

    // The four highlights shown by both Insights and Trends: each has its own caption, icon and color.
    enum Kind {
        case joys
        case activeDays
        case streak
        case joyfulHours

        var subtitle: LocalizedStringResource {
            switch self {
            case .joys: "Joys"
            case .activeDays: "Active Days"
            case .streak: "Day Streak"
            case .joyfulHours: "Joyful Hours"
            }
        }

        var systemImage: String {
            switch self {
            case .joys: "star.fill"
            case .activeDays: "calendar"
            case .streak: "flame.fill"
            case .joyfulHours: "sun.max.fill"
            }
        }

        var gradientColors: [Color] {
            switch self {
            case .joys: AccentColors.joysGradient
            case .activeDays: AccentColors.activeDaysGradient
            case .streak: AccentColors.streakGradient
            case .joyfulHours: AccentColors.joyfulHoursGradient
            }
        }
    }

    let kind: Kind
    let value: String
    let metrics: Metrics

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 30)
                .fill(LinearGradient(colors: kind.gradientColors, startPoint: .leading, endPoint: .trailing))

            content
        }
        .frame(maxWidth: .infinity)
        .frame(height: metrics.height * scale)
    }

    private var subtitleLabel: some View {
        HStack(spacing: 4) {
            Image(systemName: kind.systemImage)
                .font(.lummiFont(size: 11 * scale, weight: .semibold))
                .foregroundColor(AccentColors.glowCardText)

            Text(kind.subtitle)
                .font(.lummiFont(size: 12 * scale))
                .foregroundColor(AccentColors.glowCardText.opacity(Self.captionOpacity))
                .lineLimit(1)
                .minimumScaleFactor(0.6)
        }
    }

    private var valueLabel: some View {
        Text(value)
            .font(.lummiFont(size: metrics.valueFontSize * scale))
            .foregroundColor(AccentColors.glowCardText)
            .minimumScaleFactor(0.3)
            .lineLimit(1)
    }

    // Value in the middle, subtitle at the bottom
    private var content: some View {
        ZStack {
            valueLabel
                .padding(.horizontal, metrics.valuePadding)

            VStack {
                Spacer()
                subtitleLabel
                    .padding(.bottom, 16)
            }
        }
    }
}

#if DEBUG
#Preview {
    VStack(spacing: 15) {
        HStack(spacing: 15) {
            GlowCard(kind: .joys, value: "42", metrics: .insights)
            GlowCard(kind: .joyfulHours, value: "18:00 - 21:00", metrics: .insights)
        }
        HStack(spacing: 15) {
            GlowCard(kind: .joys, value: "42", metrics: .trends)
            GlowCard(kind: .activeDays, value: "17", metrics: .trends)
            GlowCard(kind: .streak, value: "5", metrics: .trends)
        }
    }
    .padding(20)
    .previewEnvironment()
}

#Preview("Largest text") {
    HStack(spacing: 15) {
        GlowCard(kind: .joys, value: "42", metrics: .insights)
        GlowCard(kind: .joyfulHours, value: "18:00 - 21:00", metrics: .insights)
    }
    .padding(20)
    .dynamicTypeSize(DynamicTypeSize.lummiSupportedRange.upperBound)
    .previewEnvironment()
}
#endif
