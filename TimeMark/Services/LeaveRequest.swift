import FirebaseFirestore

struct LeaveRequest: Identifiable, Codable {
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
