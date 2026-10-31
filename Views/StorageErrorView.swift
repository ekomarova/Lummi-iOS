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
            themeManager.currentTheme.backgroundColor.ignoresSafeArea()

            VStack(spacing: 16) {
                Image(systemName: "exclamationmark.triangle")
                    .lummiScaledFont(size: 40, relativeTo: .largeTitle)
                    .foregroundColor(themeManager.currentTheme.textColor)
                    .accessibilityHidden(true)

                Text("Can't open your joys")
                    .lummiScaledFont(size: 22, relativeTo: .title2)
                    .foregroundColor(themeManager.currentTheme.textColor)
                    .multilineTextAlignment(.center)
                    .accessibilityAddTraits(.isHeader)
                    .accessibilityIdentifier("StorageErrorTitle")

                Text("Lummi couldn't open its storage. Your joys haven't been deleted. Try again, or restart the app.")
                    .lummiScaledFont(size: 16, relativeTo: .callout)
                    .foregroundColor(themeManager.currentTheme.textColor.opacity(0.7))
                    .multilineTextAlignment(.center)

                Text(verbatim: error.localizedDescription)
                    .lummiScaledFont(size: 12, relativeTo: .caption)
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
        .appTheme(themeManager)
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
