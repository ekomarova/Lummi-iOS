//
//  Copyright (c) 2026, Evseniia Komarova.
//  All rights reserved.
//
//  Licensed under the PolyForm Noncommercial License 1.0.0.
//  See the LICENSE file in the repository root for full terms.
//  <https://polyformproject.org/licenses/noncommercial/1.0.0>
//

import SwiftUI

extension View {
    // Applies the native Liquid Glass material on iOS 26+, falling back to
    // `.ultraThinMaterial` on earlier versions.
    @ViewBuilder
    func adaptiveGlass<S: Shape>(in shape: S, interactive: Bool = true) -> some View {
        if #available(iOS 26, *) {
            self.glassEffect(interactive ? .clear.interactive() : .clear, in: shape)
        } else {
            self
                .background(.ultraThinMaterial)
                .clipShape(shape)
        }
    }
}
