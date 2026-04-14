import Foundation

class EmployeeService {
    
    static let shared = EmployeeService()
    
    // 🔹 CREATE USER
    func createUser(body: [String: Any], completion: @escaping (Data?, Error?) -> Void) {
        APIService.shared.request(
            endpoint: "/api/employee/create",
            method: "POST",
            body: body,
            completion: completion
        )
    }
    
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
    
    // 🔹 DELETE
    func deleteUser(uid: String, completion: @escaping (Data?, Error?) -> Void) {
        APIService.shared.request(
            endpoint: "/api/employee/\(uid)",
            method: "DELETE",
            completion: completion
        )
    }
}
