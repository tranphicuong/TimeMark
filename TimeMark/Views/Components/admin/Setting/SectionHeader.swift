import SwiftUI

struct SectionHeader: View {
    let title: String
    
    var body: some View {
        Text(title.uppercased())
            .font(.system(size: 14, weight: .bold))
            .foregroundColor(.gray)
            .padding(.top, 24)
            .padding(.bottom, 8)
    }
}
