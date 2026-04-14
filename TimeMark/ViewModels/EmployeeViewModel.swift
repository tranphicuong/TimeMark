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
                    Employee(
                        id: item.uid,
                        name: item.name,
                        role: "Nhân viên",
                        employeeID: item.uid,
                        status: item.isActive ? .active : .locked,
                        imageName: "person.circle.fill",
                        checkInTime: nil
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
