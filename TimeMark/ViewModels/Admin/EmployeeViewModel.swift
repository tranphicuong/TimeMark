import Foundation

class EmployeeViewModel: ObservableObject {
    
    @Published var employees: [Employee] = []
    @Published var deletedEmployees: [Employee] = []
    
    //fetch tất cả các user còn hoạt động
    func fetchEmployees() {
        EmployeeService.shared.getAllUsers { data, error in
            
            if let error = error {
                print("❌ API ERROR:", error)
                return
            }
            
            guard let data = data else { return }
            
            do {
                let decoded = try JSONDecoder().decode(EmployeeResponse.self, from: data)
                
                let mapped = decoded.data.map { item in
                    let status: EmployeeStatusApi
                    
                    if item.isDeleted {
                        status = .resigned
                    } else if item.isActive {
                        status = .active
                    } else {
                        status = .locked
                    }
                    return Employee(
                        id: item.uid,
                        email: item.email,
                        name: item.name,
                        
                        id_member: item.id_member,
                        position: item.position,
                        department: item.department,
                        status: status,
                        imageName: item.avatarURL ?? "person.circle.fill"
                        
                    )
                }
                
                DispatchQueue.main.async {
                    self.employees = mapped
                }
                
            } catch {
                print("❌ DECODE ERROR:", error)
            }
        }
    }
    // lấy tất cả user cho playoff
    func fetchDeletedEmployees() {
        UserServices.shared.getAllDeletedUsers { data, error in
            if let error = error {
                print("❌ Deleted API ERROR:", error)
                return
            }

            guard let data = data else { return }

            do {
                let decoded = try JSONDecoder().decode(
                    EmployeeResponse.self,
                    from: data
                )

                let mapped = decoded.data.map { item in
                    Employee(
                        id: item.uid,
                        email: item.email,
                        name: item.name,
                        id_member: item.id_member,
                        position: item.position,
                        department: item.department,
                        status: .resigned,
                        imageName: item.avatarURL ?? "person.circle.fill"
                    )
                }

                DispatchQueue.main.async {
                    self.deletedEmployees = mapped
                }

            } catch {
                print("❌ Decode deleted error:", error)
            }
        }
    }
    //lock/unlock tài khoản
    func toggleLock(
        employee: Employee,
        completion: @escaping () -> Void
    ) {
        let newStatus = employee.status != .active
        
        UserServices.shared.toggleUserStatus(
            uid: employee.id,
            isActive: newStatus
        ) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    self?.fetchEmployees()
                    completion()
                    
                case .failure(let error):
                    print("❌ Lock failed:", error.localizedDescription)
                }
            }
        }
    }
    //xóa tài khoảnn nhân sự
    func deleteEmployee(
        employee: Employee,
        completion: @escaping () -> Void
    ) {
        UserServices.shared.deleteUser(
            uid: employee.id
        ) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    self?.fetchEmployees()
                    completion()

                case .failure(let error):
                    print("❌ Delete failed:", error.localizedDescription)
                }
            }
        }
    }
    //chỉnh sửa vị trí và phòng ban
    func editEmployee(
        employee: Employee,
        departmentId: String,
        positionId: String,
        completion: @escaping () -> Void
    ) {
        UserServices.shared.editUser(
            uid: employee.id,
            idPosition: positionId,
            idDepartment: departmentId
        ) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    self?.fetchEmployees()
                    completion()

                case .failure(let error):
                    print("❌ Edit failed:", error.localizedDescription)
                }
            }
        }
    }
}
