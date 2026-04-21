import Foundation

struct EmployeeResponse: Codable {
    let message: String
    let data: [EmployeeAPI]
}

struct EmployeeAPI: Codable {
    let uid: String
    let email: String
    let name: String
    let id_member: String
    //position
    //id
    let id_position: String
    //name
    let position: String
    //department
    //id
    let id_department: String
    //name
    let department: String


    
    let isActive: Bool
    let isDeleted: Bool
}
