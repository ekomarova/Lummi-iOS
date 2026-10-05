//
//  Required Notice: Copyright Evseniia Komarova (https://github.com/ekomarova)
//
//  Licensed under the PolyForm Noncommercial License 1.0.0.
//  See the LICENSE file in the repository root for full terms.
//  <https://polyformproject.org/licenses/noncommercial/1.0.0>
//

import SwiftUI

// Full-screen message shown when the store on the device cannot be opened. It replaces the app content instead of
// letting the user add joys to a throwaway store, and offers a retry because the cause is often temporary.
struct StorageErrorView: View {
    @State private var themeManager = ThemeManager()

    let error: any Error
    let onRetry: () -> Void

    var body: some View {
        ZStack {
            themeManager.currentTheme.bgGradient.ignoresSafeArea()

            VStack(spacing: 16) {
                Image(systemName: "exclamationmark.triangle")
                    .font(.lummiFont(size: 40))
                    .foregroundColor(themeManager.currentTheme.textColor)
                    .accessibilityHidden(true)

                Text("Can't open your joys")
                    .font(.lummiFont(size: 22))
                    .foregroundColor(themeManager.currentTheme.textColor)
                    .multilineTextAlignment(.center)
                    .accessibilityAddTraits(.isHeader)
                    .accessibilityIdentifier("StorageErrorTitle")

                Text("Lummi couldn't open its storage. Your joys haven't been deleted. Try again, or restart the app.")
                    .font(.lummiFont(size: 16))
                    .foregroundColor(themeManager.currentTheme.textColor.opacity(0.7))
                    .multilineTextAlignment(.center)

                Text(verbatim: error.localizedDescription)
                    .font(.lummiFont(size: 12))
                    .foregroundColor(themeManager.currentTheme.textColor.opacity(0.4))
                    .multilineTextAlignment(.center)
                    .accessibilityIdentifier("StorageErrorDetails")

                RecordActionButton(
                    systemImage: "arrow.clockwise",
                    title: "Try Again",
                    accessibilityID: "StorageErrorRetryButton",
                    action: onRetry
                )
                .padding(.top, 8)
            }
            .padding(.horizontal, 32)
            .frame(maxWidth: AdaptiveLayout.isPad ? 480 : .infinity)
        }
        .environment(themeManager)
        .preferredColorScheme(themeManager.isDark ? .dark : .light)
    }
}

#if DEBUG
#Preview {
    StorageErrorView(
        error: NSError(
            domain: NSCocoaErrorDomain,
            code: 134_110,
            userInfo: [NSLocalizedDescriptionKey: "The operation couldn't be completed. (Cocoa error 134110.)"]
        ),
        onRetry: { }
    )
}
#endif
