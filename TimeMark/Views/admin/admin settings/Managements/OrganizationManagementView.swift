import SwiftUI

// MARK: - MODELS


// MARK: - MAIN VIEW

struct OrganizationManagementView: View {
    @State private var selectedTab = 0
    
    @State private var showAddDepartment = false
    @State private var showAddPosition = false
    @State private var departments: [DepartmentData] = []

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
        .onAppear {
            loadDepartments()
        }
    }
    
    // MARK: Header
    func loadDepartments() {
        DepartmentFirebaseService.shared.getAllDepartments { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let data):
                    self.departments = data
                    print(data)
                    
                case .failure(let error):
                    print("❌ Lỗi load department:", error.localizedDescription)
                }
            }
        }
        
    }
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
            Position(id: "0001",name: "Trưởng phòng", description: "Quản lý phòng ban"),
            Position(id:"0002",name: "Nhân viên",description: "Thực thi công việc")
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


