import Foundation

struct EmployeeResponse: Codable {
    let message: String
    let data: [EmployeeAPI]
}

struct EmployeeAPI: Codable {
    let uid: String
    let email: String
    let name: String
    let phone: String?
    let id_role: String
    let isActive: Bool
}
