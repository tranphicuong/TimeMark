//
//  WorkScheduleModels.swift
//  TimeMark
//
//  Created by Doanh on 5/6/26.
//
import Foundation

// MARK: - Model
struct WorkSchedule: Decodable,Equatable {
    let id: String
    let name: String
    let check_in_time: FirebaseTimestamp
    let check_out_time: FirebaseTimestamp
    let overtime_after: FirebaseTimestamp
    let early_leave_minute: Int
    let late_after_minute: Int
    
    var checkInDate: Date { check_in_time.date }
    var checkOutDate: Date { check_out_time.date }
    var overtimeDate: Date { overtime_after.date }
}



struct WorkScheduleResponse: Decodable {
    let success: Bool
    let data: WorkSchedule?
}
