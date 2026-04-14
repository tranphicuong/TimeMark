import SwiftUI

// MARK: - MODELS

struct Department: Identifiable {
    let id = UUID()
    let name: String
    let description: String
    let manager: String
    let employeeCount: Int
    let icon: String
    let iconColor: Color
}

struct Position: Identifiable {
    let id = UUID()
    let name: String
    let description: String
    let level: String
}

// MARK: - MAIN VIEW

struct OrganizationManagementView: View {
    @State private var selectedTab = 0
    
    @State private var showAddDepartment = false
    @State private var showAddPosition = false
    
    let departments = [
        Department(name: "Phòng Kỹ thuật", description: "Phát triển sản phẩm & Hạ tầng", manager: "Lê Anh Tuấn", employeeCount: 12, icon: "cpu", iconColor: .blue),
        Department(name: "Phòng Nhân sự", description: "Tuyển dụng & Đào tạo", manager: "Nguyễn Thu Hà", employeeCount: 5, icon: "person.2.fill", iconColor: .orange),
        Department(name: "Phòng Kinh doanh", description: "Thị trường & Sales", manager: "Trần Minh Hoàng", employeeCount: 24, icon: "briefcase.fill", iconColor: .indigo)
    ]
    
    var body: some View {
        VStack(spacing: 0) {
            
            // MARK: Tabs
            HStack(spacing: 0) {
                TabButton(title: "Phòng ban", isSelected: selectedTab == 0) {
                    selectedTab = 0
                }
                TabButton(title: "Chức danh", isSelected: selectedTab == 1) {
                    selectedTab = 1
                }
            }
            .padding(.horizontal, 20)
            .background(Color.white)
            
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    
                    header
                    
                    if selectedTab == 0 {
                        departmentSection
                    } else {
                        positionSection
                    }
                }
                .padding(20)
            }
            .background(Color(uiColor: .systemGroupedBackground))
        }
        .navigationTitle("Quản lý Tổ chức")
        .sheet(isPresented: $showAddDepartment) {
            AddDepartmentView()
        }
        .sheet(isPresented: $showAddPosition) {
            AddPositionView()
        }
    }
    
    // MARK: Header
    
    var header: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Cấu trúc tổ chức")
                .font(.system(size: 24, weight: .bold))
            Text("Quản lý phòng ban và chức danh.")
                .font(.system(size: 14))
                .foregroundColor(.gray)
        }
        .padding(.top, 20)
    }
    
    // MARK: Department UI
    
    var departmentSection: some View {
        VStack(spacing: 16) {
            
            Button {
                showAddDepartment = true
            } label: {
                HStack {
                    Image(systemName: "plus")
                    Text("Thêm phòng ban")
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
    }
    
    // MARK: Position UI
    
    var positionSection: some View {
        VStack(spacing: 16) {
            
            Button {
                showAddPosition = true
            } label: {
                HStack {
                    Image(systemName: "plus")
                    Text("Tạo chức danh")
                        .fontWeight(.bold)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.green)
                .foregroundColor(.white)
                .cornerRadius(12)
            }
            
            ForEach(samplePositions) { pos in
                VStack(alignment: .leading, spacing: 8) {
                    Text(pos.name)
                        .font(.headline)
                    Text(pos.description)
                        .foregroundColor(.gray)
                    Text("Level: \(pos.level)")
                        .font(.caption)
                        .foregroundColor(.blue)
                }
                .padding()
                .background(Color.white)
                .cornerRadius(12)
            }
        }
    }
    
    // MARK: Sample Data
    
    var samplePositions: [Position] {
        [
            Position(name: "Trưởng phòng", description: "Quản lý phòng ban", level: "Senior"),
            Position(name: "Nhân viên", description: "Thực thi công việc", level: "Junior")
        ]
    }
}

// MARK: - COMPONENTS

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

struct departmentCard: View {
    let dept: Department
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: dept.icon)
                .foregroundColor(.white)
                .padding()
                .background(dept.iconColor)
                .cornerRadius(10)
            
            VStack(alignment: .leading, spacing: 6) {
                Text(dept.name)
                    .font(.headline)
                Text(dept.description)
                    .font(.subheadline)
                    .foregroundColor(.gray)
                Text("Trưởng phòng: \(dept.manager)")
                    .font(.caption)
                    .foregroundColor(.blue)
            }
            
            Spacer()
            
            Text("\(dept.employeeCount)")
                .font(.title3)
                .bold()
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
    }
}

// MARK: - ADD DEPARTMENT

struct AddDepartmentView: View {
    @Environment(\.dismiss) var dismiss
    
    @State private var name = ""
    @State private var description = ""
    @State private var manager = ""
    
    var body: some View {
        NavigationView {
            Form {
                TextField("Tên phòng ban", text: $name)
                TextField("Mô tả", text: $description)
                TextField("Trưởng phòng", text: $manager)
            }
            .navigationTitle("Tạo phòng ban")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Hủy") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Xác nhận") {
                        // 👉 CALL API HERE
                        print("Create Department:", name)
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - ADD POSITION

struct AddPositionView: View {
    @Environment(\.dismiss) var dismiss
    
    @State private var name = ""
    @State private var description = ""
    @State private var level = ""
    
    var body: some View {
        NavigationView {
            Form {
                TextField("Tên chức danh", text: $name)
                TextField("Mô tả", text: $description)
                TextField("Level", text: $level)
            }
            .navigationTitle("Tạo chức danh")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Hủy") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Xác nhận") {
                        // 👉 CALL API HERE
                        print("Create Position:", name)
                        dismiss()
                    }
                }
            }
        }
    }
}
