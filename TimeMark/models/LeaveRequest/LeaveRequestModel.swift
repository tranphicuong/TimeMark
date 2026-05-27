import Foundation
import FirebaseFirestore

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


struct LeaveRequestEmployee: Identifiable, Codable {
    @DocumentID var id: String?
    let id_user: DocumentReference
    let id_leave_type: DocumentReference
    let from_date: Timestamp
    let to_date: Timestamp
    let reason: String
    let status: String
    let created_at: Timestamp
    let days: Int
    let days_restored: Bool?
    
    // MARK: - Computed Properties
    var statusText: String {
        switch status.lowercased() {
        case "approved": return "Đã duyệt"
        case "rejected": return "Từ chối"
        default: return "Chờ duyệt"
        }
    }
    
    var statusColorName: String {
        switch status.lowercased() {
        case "approved": return "green"
        case "rejected": return "red"
        default: return "orange"
        }
    }
    
    var fromDateString: String {
        from_date.dateValue().formatted(date: .abbreviated, time: .omitted)
    }
    
    var toDateString: String {
        to_date.dateValue().formatted(date: .abbreviated, time: .omitted)
    }
}
