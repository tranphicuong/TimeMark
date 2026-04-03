import SwiftUI

struct CheckInRow: View {
    let name: String
    let department: String
    let time: String
    let status: String
    let image: String
    var isLate: Bool = false
    
    var body: some View {
        HStack(spacing: 12) {
            ZStack(alignment: .bottomTrailing) {
                Image(systemName: image)
                    .resizable()
                    .frame(width: 45, height: 45)
                    .foregroundColor(.gray.opacity(0.5))
                Circle()
                    .fill(Color.green)
                    .frame(width: 12, height: 12)
                    .overlay(Circle().stroke(Color.white, lineWidth: 2))
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(name)
                    .font(.system(size: 15, weight: .semibold))
                Text(department)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 2) {
                Text(time)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(isLate ? .orange : .blue)
                Text(status)
                    .font(.system(size: 9, weight: .bold))
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color(.systemGray6).opacity(0.5))
        .cornerRadius(15)
    }
}
