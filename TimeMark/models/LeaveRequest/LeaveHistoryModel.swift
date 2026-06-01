//
//  LeaveHistoryModel.swift
//  TimeMark
//
//  Created by Rebel on 6/2/26.
//

struct LeaveHistory: Codable, Identifiable {
    let action: String
    let approved_by: String
    let note: String?
    let created_at: FirestoreTimestamp
    let leave_request_id: LeaveRequestRef
    let user_name: String?
    let from_date: FirestoreTimestamp?
    let to_date: FirestoreTimestamp?
    
    var id: String { "\(leave_request_id.requestId)_\(created_at._seconds)" }
}
struct LeaveRequestRef: Codable {
    let _path: LeaveRequestPath
    
    var requestId: String {
        _path.segments.last ?? ""
    }
}

struct LeaveRequestPath: Codable {
    let segments: [String]
}

struct LeaveHistoryResponse: Codable {
    let success: Bool
    let data: [LeaveHistory]
}
