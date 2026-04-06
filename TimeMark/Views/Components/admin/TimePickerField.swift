import SwiftUI

struct TimePickerField: View {
    let label: String
    @Binding var time: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(label)
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(.gray)
            
            HStack {
                Text(time)
                    .font(.system(size: 14, weight: .bold))
                Spacer()
                Image(systemName: "clock")
                    .foregroundColor(.gray)
            }
            .padding(.horizontal, 12)
            .frame(height: 44)
            .background(Color.gray.opacity(0.1))
            .cornerRadius(8)
        }
    }
}

