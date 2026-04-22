import Foundation

class EmployeeViewModel: ObservableObject {
    
    @Published var employees: [Employee] = []
    
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
                        status = .onLeave
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
}
