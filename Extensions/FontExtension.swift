import SwiftUI

enum AdaptiveLayout {
    static var isPad: Bool {
        UIDevice.current.userInterfaceIdiom == .pad
    }
    
    static func getSize(for base: CGFloat) -> CGFloat {
        return isPad ? base * 1.5 : base
    }
}

extension Font {
    static func lummiFont(size: CGFloat, weight: Font.Weight = .light) -> Font {
        let scaledSize = AdaptiveLayout.getSize(for: size)
        return .system(size: scaledSize, weight: weight, design: .monospaced)
    }
}
