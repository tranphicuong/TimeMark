//
//  LeaveBalanceResponse.swift
//  TimeMark
//
//  Created by Rebel on 5/6/26.
//


struct LeaveBalanceResponse: Codable {
    let success: Bool
    let data: [LeaveBalance]
}
struct LeaveBalance: Codable, Identifiable {
    let id: String
    let id_user: String
    let name: String
    let avatarURL: String
    let id_member: String
    let position: String
    let department: String
    let total_days: Int
    let used_days: Int
    let remaining_days: Int

    enum CodingKeys: String, CodingKey {
        case id = "id_balance"
        case id_user, name, avatarURL, id_member
        case position, department
        case total_days, used_days, remaining_days
    }
}
