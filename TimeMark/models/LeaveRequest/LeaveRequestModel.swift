import Foundation
enum ApprovalStatus: String, Codable {
    case pending
    case approved
    case rejected
    case cancelled
}
struct LeaveRequestResponse: Codable {
    let success: Bool
    let data: [LeaveRequest]
}

struct LeaveRequest: Codable, Identifiable {
    let id: String
    let user: UserInfo?
    let leave_type: LeaveType?
    let from_date: FirestoreTimestamp
    let to_date: FirestoreTimestamp
    let reason: String
    var status: ApprovalStatus
    let approved_by: UserInfo?
    let approved_at: FirestoreTimestamp?
    let created_at: FirestoreTimestamp
}

struct UserInfo: Codable {
    let id: String
    let email: String?
    let name: String?
    
}

struct LeaveType: Codable {
    let id: String
    let name: String?
}

struct FirestoreTimestamp: Codable {
    let _seconds: Int
    let _nanoseconds: Int
}
