import SwiftUI
struct DepartmentCard: View {
    let dept: Department
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(dept.iconColor.opacity(0.1))
                        .frame(width: 40, height: 40)
                    Image(systemName: dept.icon)
                        .foregroundColor(dept.iconColor)
                }
                Spacer()
                Image(systemName: "pencil")
                    .foregroundColor(.gray)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(dept.name)
                    .font(.system(size: 18, weight: .bold))
                Text(dept.description)
                    .font(.system(size: 13))
                    .foregroundColor(.gray)
            }
            
            HStack {
                Image(systemName: "person.circle.fill")
                    .resizable()
                    .frame(width: 32, height: 32)
                    .foregroundColor(.gray)
                
                VStack(alignment: .leading, spacing: 0) {
                    Text("TRƯỞNG PHÒNG")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(.gray)
                    Text(dept.manager)
                        .font(.system(size: 14, weight: .medium))
                }
            }
            .padding(10)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.gray.opacity(0.05))
            .cornerRadius(12)
            
            HStack {
                Text("\(dept.employeeCount) nhân sự")
                    .font(.system(size: 13))
                    .foregroundColor(.gray)
                Spacer()
                Text("Chi tiết")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(.blue)
            }
        }
        .padding(20)
        .background(Color.white)
        .cornerRadius(20)
        .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
    }
}
