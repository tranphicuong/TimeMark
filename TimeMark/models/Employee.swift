import SwiftUI

// 🔥 ENUM (ĐẶT Ở ĐÂY)
enum EmployeeStatusApi: String {
    case active = "HOẠT ĐỘNG"
    case onLeave = "NGHỈ PHÉP"
    case locked = "ĐÃ KHÓA"
    
    var color: Color {
        switch self {
        case .active: return .green
        case .onLeave: return .gray
        case .locked: return .red
        }
    }
}

// 🔥 MODEL
struct Employee: Identifiable {
    let id: String
    let name: String
    let role: String
    let employeeID: String
    let status: EmployeeStatusApi
    let imageName: String
    let checkInTime: String?
}
