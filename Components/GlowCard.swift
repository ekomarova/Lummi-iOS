//
//  Required Notice: Copyright Evseniia Komarova (https://github.com/ekomarova)
//
//  Licensed under the PolyForm Noncommercial License 1.0.0.
//  See the LICENSE file in the repository root for full terms.
//  <https://polyformproject.org/licenses/noncommercial/1.0.0>
//

import SwiftUI

// A highlight card: one bright gradient, a big value in the middle and a caption at the bottom.
// Shared by Insights and Trends.
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

    // The card keeps the same bright colors and dark text in light and dark mode.
    private let cardTheme = LightTheme()
    var value: String
    var subtitle: LocalizedStringResource
    var systemImage: String
    var gradientColors: [Color]
    var metrics: Metrics

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 30)
                .fill(LinearGradient(colors: gradientColors, startPoint: .leading, endPoint: .trailing))

            content
        }
        .frame(maxWidth: .infinity)
        .frame(height: metrics.height)
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
            .font(.lummiFont(size: metrics.valueFontSize))
            .foregroundColor(cardTheme.textColor)
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

// Shared presets for the cards shown by both Insights and Trends.
extension GlowCard {
    static func joys(value: String, metrics: Metrics) -> GlowCard {
        GlowCard(
            value: value,
            subtitle: "Joys",
            systemImage: "star.fill",
            gradientColors: AccentColors.joysGradient,
            metrics: metrics
        )
    }

    static func activeDays(value: String, metrics: Metrics) -> GlowCard {
        GlowCard(
            value: value,
            subtitle: "Active Days",
            systemImage: "calendar",
            gradientColors: AccentColors.activeDaysGradient,
            metrics: metrics
        )
    }

    static func streak(value: String, metrics: Metrics) -> GlowCard {
        GlowCard(
            value: value,
            subtitle: "Day Streak",
            systemImage: "flame.fill",
            gradientColors: AccentColors.streakGradient,
            metrics: metrics
        )
    }

    static func joyfulHours(value: String, metrics: Metrics) -> GlowCard {
        GlowCard(
            value: value,
            subtitle: "Joyful Hours",
            systemImage: "sun.max.fill",
            gradientColors: AccentColors.joyfulHoursGradient,
            metrics: metrics
        )
    }
}

#if DEBUG
#Preview {
    VStack(spacing: 15) {
        HStack(spacing: 15) {
            GlowCard.joys(value: "42", metrics: .insights)
            GlowCard.joyfulHours(value: "18:00 - 21:00", metrics: .insights)
        }
        HStack(spacing: 15) {
            GlowCard.joys(value: "42", metrics: .trends)
            GlowCard.activeDays(value: "17", metrics: .trends)
            GlowCard.streak(value: "5", metrics: .trends)
        }
    }
    .padding(20)
    .previewEnvironment()
}
#endif
