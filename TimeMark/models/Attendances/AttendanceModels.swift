//
//  AttendanceModels.swift
//  TimeMark
//
//  Created by Rebel on 5/5/26.
//

// DashboardModel.swift
import Foundation

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
