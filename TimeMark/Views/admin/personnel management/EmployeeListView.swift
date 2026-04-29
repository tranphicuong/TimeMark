import SwiftUI

struct EmployeeListView: View {
    @State private var searchText = ""
    @State private var selectedEmployee: Employee? = nil
    @State private var showLockSheet = false
    
    //delete
    @State private var showDeleteSheet = false
    @State private var selectedDeleteEmployee: Employee? = nil
    // 👇 QUAN TRỌNG: chỉ lưu 1 thằng đang mở
    @State private var openedEmployeeID: String? = nil
    
    //select position với Department
    @State private var showEditSheet = false
    @State private var selectedEditEmployee: Employee? = nil

    @State private var selectedDepartment = ""
    @State private var selectedPosition = ""
    
    //thông báo trưởng phòng đã tồn tại
    @State private var showErrorAlert = false
    @State private var errorMessage = ""
    @StateObject private var registerVM = RegisterMemberViewModel()
    
    // ✅ DÙNG VIEWMODEL
    @StateObject private var viewModel = EmployeeViewModel()
    
    var body: some View {
        VStack(spacing: 0) {
            
            // Header
            HStack {
                Button(action: {}) {
                    Image(systemName: "line.3.horizontal")
                        .font(.title2)
                }
                Spacer()
                Text("TimeMark Admin")
                    .font(.headline)
                    .foregroundColor(.blue)
                Spacer()
                Image(systemName: "person.crop.circle.fill")
                    .resizable()
                    .frame(width: 35, height: 35)
            }
            .padding()
            
            // Title + Search Section
            VStack(alignment: .leading, spacing: 15) {
                VStack(alignment: .leading, spacing: 5) {
                    Text("Quản lý nhân viên")
                        .font(.title.bold())
                    
                    // ✅ SỬA COUNT
                    Text("Tổng cộng \(viewModel.employees.count) nhân viên")
                        .foregroundColor(.gray)
                }
                
                // Search Bar + Filter Button
                HStack(spacing: 12) {
                    // Ô tìm kiếm
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.gray)
                        
                        TextField("Tìm kiếm nhân viên...", text: $searchText)
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(15)
                    
                    // Nút Filter
                    Button(action: {
                    }) {
                        Image(systemName: "line.3.horizontal.decrease")
                            .font(.system(size: 20, weight: .medium))
                            .foregroundColor(Color(.systemGray2))
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(15)
                    }
                }
            }
            .padding(.horizontal)
            
            // List
            ScrollView {
                VStack(spacing: 12) {
                    
                    // ✅ SỬA FOR EACH
                    ForEach(viewModel.employees) { employee in
                        EmployeeCard(
                            employee: employee,
                            openedID: $openedEmployeeID,
                            onEdit: {
                                selectedEditEmployee = employee
                                selectedDepartment = employee.department
                                selectedPosition = employee.position
                                showEditSheet = true
                            },
                            onLock: {
                                selectedEmployee = employee
                                showLockSheet = true
                            },
                            onDelete: {
                                selectedDeleteEmployee = employee
                                showDeleteSheet = true
                            }
                        )
                    }
                }
                .padding()
                Divider()
                    .padding(.vertical)

                VStack(alignment: .leading, spacing: 12) {
                    Text("Nhân sự đã nghỉ việc")
                        .font(.headline)
                        .padding(.horizontal)

                    ScrollView {
                        VStack(spacing: 12) {
                            ForEach(viewModel.deletedEmployees) { employee in
                                EmployeeCard(
                                    employee: employee,
                                    openedID: .constant(nil),
                                    onEdit: {},
                                    onLock: {},
                                    onDelete: {}
                                )
                            }
                        }
                        .padding(.horizontal)
                    }
                    .frame(maxHeight: 220)
                }
            }
            
            HStack {
                Spacer()
                NavigationLink(destination: AddEmployeeView()) {
                    Image(systemName: "plus")
                        .font(.title.bold())
                        .foregroundColor(.white)
                        .frame(width: 55, height: 55)
                        .background(Color.blue)
                        .clipShape(Circle())
                        .shadow(radius: 4)
                }
                .padding(.trailing, 20)
                .padding(.bottom, 10)
            }
        }
        
        // ✅ GỌI API Ở ĐÂY
        .onAppear {
            viewModel.fetchEmployees()
            viewModel.fetchDeletedEmployees()
        }
        
        //gọi modal chạy lock tài khoản
        .sheet(isPresented: $showLockSheet) {
            if let employee = selectedEmployee {
                lockConfirmSheet(employee: employee)
                    .presentationDetents([.height(240)])
                    .presentationDragIndicator(.visible)
            }
        }
        //xóa tài khoản
        .sheet(isPresented: $showDeleteSheet) {
            if let employee = selectedDeleteEmployee {
                deleteConfirmSheet(employee: employee)
                    .presentationDetents([.height(240)])
                    .presentationDragIndicator(.visible)
            }
        }
        //edit position và department
        .sheet(isPresented: $showEditSheet) {
            if let employee = selectedEditEmployee {
                editEmployeeSheet(employee: employee)
                    .presentationDetents([.height(350)])
                    .presentationDragIndicator(.visible)
                    .onAppear {
                        registerVM.loadFormData()
                    }
            }
        }
        .alert("Thông báo", isPresented: $showErrorAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(errorMessage)
        }
    }

    
    //modal xác nhận lock hay unlock tài khoản
    
    @ViewBuilder
    func lockConfirmSheet(employee: Employee) -> some View {
        let isLocking = employee.status == .active
        
        VStack(spacing: 20) {
            Image(systemName: isLocking ? "lock.fill" : "lock.open.fill")
                .font(.system(size: 40))
                .foregroundColor(.orange)
            
            Text(isLocking ? "Khóa tài khoản" : "Mở khóa tài khoản")
                .font(.headline)
            
            Text(
                isLocking
                ? "Bạn có chắc muốn khóa tài khoản của \(employee.name)?"
                : "Bạn có chắc muốn mở khóa tài khoản của \(employee.name)?"
            )
            .multilineTextAlignment(.center)
            .foregroundColor(.gray)
            
            HStack(spacing: 12) {
                Button("Hủy") {
                    showLockSheet = false
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color(.systemGray5))
                .cornerRadius(12)
                
                Button(isLocking ? "Khóa" : "Mở") {
                    confirmToggleLock(employee)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(.orange)
                .foregroundColor(.white)
                .cornerRadius(12)
            }
        }
        .padding()
    }
    
    
    
    //modal xoa tài khoản
    @ViewBuilder
    func deleteConfirmSheet(employee: Employee) -> some View {
        VStack(spacing: 20) {
            Image(systemName: "trash.fill")
                .font(.system(size: 40))
                .foregroundColor(.red)

            Text("Xóa tài khoản")
                .font(.headline)

            Text("Bạn có chắc muốn xóa tài khoản của \(employee.name)?")
                .multilineTextAlignment(.center)
                .foregroundColor(.gray)

            HStack(spacing: 12) {
                Button("Hủy") {
                    showDeleteSheet = false
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color(.systemGray5))
                .cornerRadius(12)

                Button("Xóa") {
                    confirmDelete(employee)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(.red)
                .foregroundColor(.white)
                .cornerRadius(12)
            }
        }
        .padding()
    }
    //modal edit
    @ViewBuilder
    func editEmployeeSheet(employee: Employee) -> some View {
        VStack(spacing: 20) {
            Text("Chỉnh sửa nhân sự")
                .font(.headline)

            if !registerVM.departments.isEmpty &&
               !registerVM.positions.isEmpty {

                DropdownField(
                    label: "PHÒNG BAN",
                    selection: $selectedDepartment,
                    options: registerVM.departments.map { $0.name }
                )

                DropdownField(
                    label: "CHỨC VỤ",
                    selection: $selectedPosition,
                    options: registerVM.positions.map { $0.name }
                )
            }

            Button("Lưu thay đổi") {
                confirmEdit(employee)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(.blue)
            .foregroundColor(.white)
            .cornerRadius(12)
        }
        .padding()
    }
    //goi api chay chức năng xóa
    func confirmDelete(_ employee: Employee) {
        showDeleteSheet = false

        viewModel.deleteEmployee(employee: employee) {
            viewModel.fetchEmployees()
        }
    }
    //goi api chạy chức năng lock va unlock tài khoản
    func confirmToggleLock(_ employee: Employee) {
        showLockSheet = false

        viewModel.toggleLock(employee: employee) {
            viewModel.fetchEmployees()
        }
    }
    // check department có trưởng phòng hay chưa
    
    func confirmEdit(_ employee: Employee) {
        guard
            let dept = registerVM.departments.first(where: {
                $0.name == selectedDepartment
            }),
            let pos = registerVM.positions.first(where: {
                $0.name == selectedPosition
            })
        else { return }

        let managerPositionId = "VqfJNhhuL0j4dv7SF7Rf"

        // check nếu set làm trưởng phòng
        if pos.id == managerPositionId {
            DepartmentService.shared.getDepartmentUsers(
                departmentId: dept.id
            ) { result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let departmentData):

                        // đã có trưởng phòng khác
                        if let leader = departmentData.leader,
                           leader.uid != employee.id {
                            errorMessage = "Phòng ban này đã có trưởng phòng"
                            showErrorAlert = true
                            return
                        }
                        saveEdit(employee, dept.id, pos.id)

                    case .failure(let error):
                        print(error.localizedDescription)
                    }
                }
            }
        } else {
            saveEdit(employee, dept.id, pos.id)
        }
        
    }
    func saveEdit(
        _ employee: Employee,
        _ deptId: String,
        _ posId: String
    ) {
        showEditSheet = false

        viewModel.editEmployee(
            employee: employee,
            departmentId: deptId,
            positionId: posId
        ) {
            viewModel.fetchEmployees()
        }
    }
}
