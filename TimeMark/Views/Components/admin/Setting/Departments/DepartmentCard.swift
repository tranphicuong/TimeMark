import SwiftUI

struct DepartmentCard: View {
    let dept: DepartmentData
    var onSuccess: (() -> Void)?
    //mở chi tiết phòng ban
    var onDetail: () -> Void
    //show edit department
    @State private var showEditDepartment = false
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            VStack(alignment: .leading, spacing: 16) {
                HStack(spacing: 12) {
                    Image(systemName: dept.icon ?? "building.2.fill")
                        .font(.system(size: 22))
                        .foregroundColor(colorFromString(dept.iconColor))
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(dept.department_name)
                            .font(.system(size: 18, weight: .bold))
                        
                        Text(dept.description ?? "Chưa có mô tả")
                            .font(.system(size: 13))
                            .foregroundColor(.gray)
                            .lineLimit(2)
                    }
                    
                    Spacer()
                    
                    //edit department
                    Button {
                        showEditDepartment = true
                    } label: {
                        Image(systemName: "pencil")
                            .foregroundColor(.gray)
                    }
                }     .foregroundColor(.gray)
            }
            HStack {
                if let avatar = dept.leader?.avatarURL,
                   let url = URL(string: avatar) {
                    AsyncImage(url: url) { image in
                        image
                            .resizable()
                            .scaledToFill()
                    } placeholder: {
                        Image(systemName: "person.circle.fill")
                            .resizable()
                            .scaledToFit()
                            .foregroundColor(.gray)
                    }
                    .frame(width: 32, height: 32)
                    .clipShape(Circle())
                } else {
                    Image(systemName: "person.circle.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 32, height: 32)
                        .foregroundColor(.gray)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("TRƯỞNG PHÒNG")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(.gray)
                    
                    Text(dept.leader?.name ?? "Chưa có")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(
                            dept.leader == nil ? .gray : .primary
                        )
                }
            }
            .padding(10)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.gray.opacity(0.05))
            .cornerRadius(12)
            
            HStack {
                Text("\(dept.total) nhân sự")
                    .font(.system(size: 13))
                    .foregroundColor(.gray)
                
                Spacer()
                
                Button {
                    onDetail()
                } label: {
                    Text("Chi tiết")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(.blue)
                }
            }
        }
        .padding(20)
        .background(Color.white)
        .cornerRadius(20)
        .shadow(
            color: Color.black.opacity(0.05),
            radius: 10,
            x: 0,
            y: 5
        )
        .sheet(isPresented: $showEditDepartment) {
            EditDepartmentView(dept: dept, onSuccess: onSuccess)
        }
        
        
    }
}
