//
//  AttendanceModels.swift
//  TimeMark
//
//  Created by Rebel on 5/5/26.
//

// DashboardModel.swift
import Foundation
import FirebaseFirestore
import SwiftUI

struct DashboardSummary: Decodable {
    let date: String
    let total_active: Int
    let total_present: Int
    let total_late: Int
    let total_on_leave: Int
    let total_absent: Int
}

struct DashboardSummaryResponse: Decodable {
    let success: Bool
    let data: DashboardSummary
}

struct AttendanceUser: Decodable {
    let uid: String
    let name: String
    let email: String?
    let avatarURL: String?
    let position: String?
    let department: String?
}

struct AttendanceRecord: Decodable, Identifiable {
    let attendance_id: String
    let check_in: FirebaseTimestamp?
    let check_out: FirebaseTimestamp?
    let status: String?
    let late_minutes: Int?
    let early_minutes: Int?
    let overtime_minutes: Int?
    let img_checkin: String?
    let img_checkout: String?
    let user: AttendanceUser

    var id: String { attendance_id }
}

struct AttendanceListResponse: Decodable {
    let success: Bool
    let data: [AttendanceRecord]
}
struct AttendanceRecordEmployee: Identifiable {
    let id: String
    let date: String
    let checkIn: Date?
    let checkOut: Date?
    let status: String?
    let totalHours: String
    
    // Thêm thông tin nghỉ phép
    var leaveType: String? = nil
    var isOnLeave: Bool = false
    
    // MARK: - Hiển thị Tiếng Việt
    var displayStatus: String {
        if isOnLeave {
            return "Nghỉ phép"
        }
        
        guard let status = status?.lowercased() else { return "Đúng giờ" }
        
        switch status {
        case "present", "on-time":
            return "Đúng giờ"
        case "late":
            return "Trễ"
        case "absent", "vắng":
            return "Vắng"
        case "early-leave":
            return "Về sớm"
        default:
            return status.uppercased()
        }
    }
    
    var statusColor: Color {
        if isOnLeave { return .purple }
        guard let status = status?.lowercased() else { return .green }
        if status == "late" { return .orange }
        if status == "absent" || status == "vắng" { return .red }
        if status == "early-leave" { return .yellow }
        return .green
    }
    
    var isLate: Bool {
        guard let status = status?.lowercased() else { return false }
        return status == "late"
    }
    
    var isAbsent: Bool {
        guard let status = status?.lowercased() else { return false }
        return (status == "absent" || status == "vắng") && !isOnLeave
    }
    
    init(id: String, data: [String: Any]) {
        self.id = id
        self.date = data["date"] as? String ?? ""
        self.checkIn = (data["check_in"] as? Timestamp)?.dateValue()
        self.checkOut = (data["check_out"] as? Timestamp)?.dateValue()
        self.status = data["status"] as? String
        
        if let ci = checkIn, let co = checkOut {
            let hours = (co.timeIntervalSince(ci) / 3600)
            self.totalHours = String(format: "%.1f h", hours)
        } else {
            self.totalHours = "0.0 h"
        }
    }
    
    // Constructor cho ngày nghỉ phép
    init(leaveDate: String) {
        self.id = "leave-\(leaveDate)"
        self.date = leaveDate
        self.checkIn = nil
        self.checkOut = nil
        self.status = nil
        self.totalHours = "0.0 h"
        self.leaveType = "annual"
        self.isOnLeave = true
    }
}
