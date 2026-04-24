import SwiftUI

struct NeonStarView: View {
    let primary: Color
    let secondary: Color
    let blur: CGFloat
    
    var body: some View {
        ZStack {
            Image(systemName: "star.fill")
                .font(.system(size: 55))
                .foregroundColor(secondary.opacity(0.2))
                .blur(radius: blur)
            
            Image(systemName: "star.fill")
                .font(.system(size: 40))
                .foregroundColor(primary.opacity(0.35))
                .blur(radius: blur/2)
            
            Image(systemName: "star.fill")
                .font(.system(size: 30))
                .foregroundColor(primary.opacity(0.5))
                .blur(radius: 1.5)
        }
    }
}
