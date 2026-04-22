import Foundation

struct DepartmentResponse: Codable {
    let message: String
    let data: DepartmentData
}

struct DepartmentData: Codable, Identifiable ,Hashable {
    var id: String { department_id }
    let department_id: String
    let department_name: String
    let description: String?
    let icon : String?
    let iconColor : String?
    let total: Int
    let leader: Leader?
    let users: [DepartmentUser]
}

struct Leader: Codable , Hashable{
    let uid: String
    let name: String
    let email: String
    let avatarURL: String?
}

struct DepartmentUser: Codable, Identifiable ,Hashable{
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
extension DepartmentUser {
    var toEmployee: Employee {
        Employee(
            id: uid,
            email: email,
            name: name,
            id_member: id_member,
            position: position,
            department: "",
            status: isActive ? .active : .locked,
            imageName: avatarURL ?? "person.circle.fill"
        )
    }
}
//list department
struct DepartmentListItem: Identifiable {
    let id: String
    let name: String
}
