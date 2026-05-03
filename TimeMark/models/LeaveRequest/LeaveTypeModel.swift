import Foundation

struct LeaveTypeModel: Codable, Identifiable, Hashable {
    let id: String
    let name: String
    let daynumber: Int?
    let description: String?
    let quantity: Int?
}

struct LeaveTypeResponse: Codable {
    let success: Bool
    let data: [LeaveTypeModel]
}
