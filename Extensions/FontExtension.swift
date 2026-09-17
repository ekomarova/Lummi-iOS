//
//  Copyright (c) 2026, Evseniia Komarova.
//  All rights reserved.
//
//  Licensed under the PolyForm Noncommercial License 1.0.0.
//  See the LICENSE file in the repository root for full terms.
//  <https://polyformproject.org/licenses/noncommercial/1.0.0>
//

import SwiftUI

enum AdaptiveLayout {
    static var isPad: Bool {
        UIDevice.current.userInterfaceIdiom == .pad
    }
}

extension Font {
    static func lummiFont(size: CGFloat, weight: Font.Weight = .light) -> Font {
        return .system(size: size, weight: weight, design: .default)
    }
}
