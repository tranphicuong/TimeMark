import SwiftUI

struct FakePushBanner: View {
    var title: String
    var message: String
    
    var body: some View {   
        HStack(spacing: 12) {
            Image(systemName: "bell.fill")
                .font(.title2)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .bold()
                
                Text(message)
                    .font(.subheadline)
                    .lineLimit(2)
            }
            
            Spacer()
        }
        .padding()
        .background(.white)
        .cornerRadius(16)
        .shadow(radius: 5)
        .padding(.horizontal)
    }
}
