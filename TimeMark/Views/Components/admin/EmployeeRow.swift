import SwiftUI
struct EmployeeRow: View {
    let employee: EmployeeColor
    
    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(employee.avatarColor.opacity(0.2))
                    .frame(width: 40, height: 40)
                Text(String(employee.name.split(separator: " ").last?.prefix(2) ?? ""))
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(employee.avatarColor)
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(employee.name)
                    .font(.system(size: 15, weight: .bold))
                Text("Mã NV: \(employee.code) • \(employee.department)")
                    .font(.system(size: 12))
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            Text("\(employee.leaveDays)")
                .font(.system(size: 14, weight: .bold))
                .frame(width: 44, height: 32)
                .background(Color.gray.opacity(0.1))
                .cornerRadius(8)
            
            Text(employee.remainingDays)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.blue)
                .frame(width: 55, height: 32)
                .background(Color.blue.opacity(0.1))
                .cornerRadius(8)
        }
        .padding(.vertical, 12)
    }
}


