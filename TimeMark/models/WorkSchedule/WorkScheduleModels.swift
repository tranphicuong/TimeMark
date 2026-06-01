import Foundation

// MARK: - Model
struct WorkSchedule: Decodable, Equatable {
    let id: String
    let name: String
    let check_in_time: String    // "HH:mm"
    let check_out_time: String   // "HH:mm"
    let overtime_after: String   // "HH:mm"
    let early_leave_minute: Int
    let late_after_minute: Int
}

struct WorkScheduleResponse: Decodable {
    let success: Bool
    let data: WorkSchedule?
}
