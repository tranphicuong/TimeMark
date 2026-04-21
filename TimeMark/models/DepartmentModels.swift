import Foundation

struct DepartmentResponse: Codable {
    let message: String
    let data: DepartmentData
}

struct DepartmentData: Codable, Identifiable {
    var id: String { department_id }

    let department_id: String
    let department_name: String
    let total: Int
    let leader: Leader?
    let users: [DepartmentUser]
}

struct Leader: Codable {
    let uid: String
    let name: String
    let email: String
    let avatarURL: String?
}

struct DepartmentUser: Codable, Identifiable {
    var id: String { uid }

    let uid: String
    let id_member: String
    let name: String
    let email: String
    let phone: String?
    let position: String
    let isActive: Bool
    let avatarURL: String?
}

//list department
struct DepartmentListItem: Identifiable {
    let id: String
    let name: String
}
