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
                        
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFill()
                        
                    case .failure:
                        Image(systemName: "person.fill")
                            .foregroundColor(.blue)
                        
                    @unknown default:
                        EmptyView()
                    }
                }
            } else {
                Image(systemName: "person.fill")
                    .foregroundColor(.blue)
            }
        }
        .frame(width: size, height: size)
        .clipShape(Circle())
    }
}
