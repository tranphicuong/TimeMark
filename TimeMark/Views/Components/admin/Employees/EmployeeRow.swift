import SwiftUI
struct EmployeeRow: View {
    let employee: LeaveBalance

    var body: some View {
        HStack(spacing: 12) {
            // Avatar
            AsyncImage(url: URL(string: employee.avatarURL)) { phase in
                switch phase {
                case .success(let image):
                    image
                        .resizable()
                        .scaledToFill()
                        .frame(width: 44, height: 44)
                        .clipShape(Circle())
                case .failure, .empty:
                    Circle()
                        .fill(Color.blue.opacity(0.15))
                        .frame(width: 44, height: 44)
                        .overlay(
                            Text(String(employee.name.prefix(1)))
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(.blue)
                        )
                @unknown default:
                    Circle()
                        .fill(Color.gray.opacity(0.2))
                        .frame(width: 44, height: 44)
                }
            }

            // Tên + phòng ban
            VStack(alignment: .leading, spacing: 2) {
                Text(employee.name)
                    .font(.system(size: 15, weight: .semibold))
                Text("\(employee.position) · \(employee.department)")
                    .font(.system(size: 12))
                    .foregroundColor(.gray)
                    .lineLimit(1)
            }

            Spacer()

            // Số ngày
            VStack(alignment: .trailing, spacing: 2) {
                Text("\(employee.total_days) ngày")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(.blue)
                Text("còn \(employee.remaining_days)")
                    .font(.system(size: 11))
                    .foregroundColor(.gray)
            }
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 4)
    }
}


