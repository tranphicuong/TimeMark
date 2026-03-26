import SwiftUI

struct OnboardItem: View {
    var title: String
    var desc: String
    var image: String
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: image)
                .font(.system(size: 80))
                .foregroundColor(.blue)
            
            Text(title)
                .font(.title)
                .bold()
            
            Text(desc)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
    }
}
