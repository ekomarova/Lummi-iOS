import SwiftUI

extension Font {
    static func lummiFont(size: CGFloat, weight: Font.Weight = .light) -> Font {
        return .system(size: size, weight: weight, design: .monospaced)
    }
}
