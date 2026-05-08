struct LeaveTypeResponse: Codable {
    let message: String
    let data: LeaveTypeModel
}

struct LeaveTypeModel: Codable, Identifiable {
    let id: String
    let name: String
    let description: String
    let daynumber: Int
    let quantity: Int
}
