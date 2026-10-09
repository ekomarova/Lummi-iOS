//
//  Required Notice: Copyright Evseniia Komarova (https://github.com/ekomarova)
//
//  Licensed under the PolyForm Noncommercial License 1.0.0.
//  See the LICENSE file in the repository root for full terms.
//  <https://polyformproject.org/licenses/noncommercial/1.0.0>
//

import UIKit

// Appearance of the native tab bar before iOS 26.
enum TabBarAppearance {
    // On iOS 18-25 the tab bar switches between `scrollEdgeAppearance` (transparent by default) and
    // `standardAppearance` depending on whether scrollable content reaches under it, so its look changes from tab to tab.
    // Using the system's default background (material plus hairline) for both keeps the bar identical everywhere
    // and never lets it blend into the page. iOS 26 keeps its own Liquid Glass bar.
    static func configure() {
        if #available(iOS 26, *) { return }
        let appearance = UITabBarAppearance()
        appearance.configureWithDefaultBackground()
        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }
}
