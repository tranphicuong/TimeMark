struct LeaveRequest: Identifiable {
    let id: String
    let employeeName: String
    let leaveType: String
    let dateRange: String
    let reason: String
    let avatarName: String
    var status: ApprovalStatus
}

enum ApprovalStatus: String {
    case pending = "CHỜ DUYỆT"
    case approved = "ĐÃ DUYỆT"
    case rejected = "ĐÃ TỪ CHỐI"
}
