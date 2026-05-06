import SwiftUI
 enum EmployeeStatus: String {
    case active = "HOẠT ĐỘNG"
    case onLeave = "NGHỈ PHÉP"
    case locked = "ĐÃ KHÓA"
    
    var color: Color {
        switch self {
        case .active: return Color.green
        case .onLeave: return Color.gray
        case .locked: return Color.red
        }
    }
}



struct StatCard: View {
    let title: String
    let value: String
    let subValue: String
    let icon: String
    let color: Color
    let isDark: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                ZStack {
                    Circle()
                        .fill(isDark ? Color.white.opacity(0.2) : color.opacity(0.1))
                        .frame(width: 35, height: 35)
                    Image(systemName: icon)
                        .foregroundColor(isDark ? .white : color)
                }
                Spacer()
                if !subValue.isEmpty {
                    Text(subValue)
                        .font(.system(size: 10, weight: .bold))
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(isDark ? Color.white.opacity(0.2) : Color.green.opacity(0.1))
                        .foregroundColor(isDark ? .white : .green)
                        .cornerRadius(10)
                }
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(isDark ? .white.opacity(0.8) : .secondary)
                Text(value)
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(isDark ? .white : .primary)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(isDark ? color : Color.white)
        .cornerRadius(20)
        .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(isDark ? Color.clear : Color.gray.opacity(0.1), lineWidth: 1)
        )
    }
}
