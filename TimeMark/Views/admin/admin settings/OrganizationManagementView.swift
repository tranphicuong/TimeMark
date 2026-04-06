import SwiftUI
struct Department: Identifiable {
    let id = UUID()
    let name: String
    let description: String
    let manager: String
    let employeeCount: Int
    let icon: String
    let iconColor: Color
}

struct OrganizationManagementView: View {
    @State private var selectedTab = 0
    
    let departments = [
        Department(name: "Phòng Kỹ thuật", description: "Phát triển sản phẩm & Hạ tầng", manager: "Lê Anh Tuấn", employeeCount: 12, icon: "cpu", iconColor: .blue),
        Department(name: "Phòng Nhân sự", description: "Tuyển dụng & Đào tạo", manager: "Nguyễn Thu Hà", employeeCount: 5, icon: "person.2.fill", iconColor: .orange),
        Department(name: "Phòng Kinh doanh", description: "Thị trường & Sales", manager: "Trần Minh Hoàng", employeeCount: 24, icon: "briefcase.fill", iconColor: .indigo)
    ]
    
    var body: some View {
        VStack(spacing: 0) {
            // Custom Tabs
            HStack(spacing: 0) {
                TabButton(title: "Phòng ban", isSelected: selectedTab == 0) { selectedTab = 0 }
                TabButton(title: "Chức danh", isSelected: selectedTab == 1) { selectedTab = 1 }
            }
            .padding(.horizontal, 20)
            .background(Color.white)
            
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Cấu trúc phòng ban")
                            .font(.system(size: 24, weight: .bold))
                        Text("Quản lý các đơn vị và nhân sự chủ chốt.")
                            .font(.system(size: 14))
                            .foregroundColor(.gray)
                    }
                    .padding(.top, 20)
                    
                    Button(action: {}) {
                        HStack {
                            Image(systemName: "plus.square.fill.on.square.fill")
                            Text("Thêm phòng ban mới")
                                .fontWeight(.bold)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                    }
                    
                    ForEach(departments) { dept in
                        DepartmentCard(dept: dept)
                    }
                }
                .padding(20)
            }
            .background(Color(uiColor: .systemGroupedBackground))
        }
        .navigationBarTitle("Quản lý Tổ chức", displayMode: .inline)
        .navigationBarItems(trailing: HStack(spacing: 20) {
            Image(systemName: "magnifyingglass")
            Image(systemName: "bell")
        })
    }
}


struct TabButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 12) {
                Text(title)
                    .font(.system(size: 15, weight: isSelected ? .bold : .medium))
                    .foregroundColor(isSelected ? .blue : .gray)
                
                Rectangle()
                    .fill(isSelected ? Color.blue : Color.clear)
                    .frame(height: 2)
            }
            .frame(maxWidth: .infinity)
        }
    }
}
