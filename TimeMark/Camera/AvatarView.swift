import SwiftUI

struct AvatarView: View {
    
    var size: CGFloat = 60
    var avatarURL: String
    
    var body: some View {
        ZStack {
            Circle()
                .fill(Color.blue.opacity(0.15))
            
            if let url = URL(string: avatarURL), !avatarURL.isEmpty {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .empty:
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .blue))
                        
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFill()
                        
                    case .failure:
                        placeholder
                        
                    @unknown default:
                        placeholder
                    }
                }
                .transition(.opacity.animation(.easeInOut))
            } else {
                placeholder
            }
        }
        .frame(width: size, height: size)
        .clipShape(Circle())
    }
    
    private var placeholder: some View {
        Image(systemName: "person.fill")
            .font(.system(size: size * 0.45))
            .foregroundColor(.blue.opacity(0.7))
    }
}
