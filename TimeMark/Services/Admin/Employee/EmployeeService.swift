import Foundation

class EmployeeService {
    
    static let shared = EmployeeService()
    

    
    // 🔹 GET ALL USERS
    func getAllUsers(completion: @escaping (Data?, Error?) -> Void) {
        APIService.shared.request(
            endpoint: "/api/employee",
            method: "GET",
            completion: completion
        )
    }
    
    // 🔹 TOGGLE STATUS
    func toggleStatus(uid: String, isActive: Bool, completion: @escaping (Data?, Error?) -> Void) {
        APIService.shared.request(
            endpoint: "/api/employee/status/\(uid)",
            method: "PATCH",
            body: ["isActive": isActive],
            completion: completion
        )
    }
    
    
}
