

struct DepartmentActionResponse: Codable {
    let message: String
    let data: DepartmentActionData
}

struct DepartmentActionData: Codable {
    let id: String
    let name: String
}
struct DeleteDepartmentResponse: Codable {
    let message: String
}
