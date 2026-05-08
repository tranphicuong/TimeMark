import SwiftUI
import FirebaseFirestore
import FirebaseAuth

class HistoryViewModel: ObservableObject {
    
    @Published var attendanceRecords: [AttendanceRecord] = []
    @Published var isLoading = false
    @Published var totalHours: Double = 0.0
    @Published var workDays: Int = 0
    @Published var lateCount: Int = 0
    @Published var absentCount: Int = 0
    @Published var leaveCount: Int = 0
    
    static let shared = HistoryViewModel()
    
    private let db = Firestore.firestore()
    
    // MARK: - Load theo tháng
    func loadHistory(year: Int, month: Int) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        isLoading = true
        let userRef = db.document("users/\(uid)")
        
        let calendar = Calendar.current
        guard let firstDay = calendar.date(from: DateComponents(year: year, month: month, day: 1)),
              let range = calendar.range(of: .day, in: .month, for: firstDay) else {
            return
        }
        
        let lastDay = range.count
        let startDateStr = String(format: "%04d-%02d-01", year, month)
        let endDateStr   = String(format: "%04d-%02d-%02d", year, month, lastDay)
        
        // Load Attendance
        db.collection("attendance")
            .whereField("id_user", isEqualTo: userRef)
            .whereField("date", isGreaterThanOrEqualTo: startDateStr)
            .whereField("date", isLessThanOrEqualTo: endDateStr)
            .order(by: "date", descending: true)
            .getDocuments { [weak self] snapshot, error in
                guard let self = self else { return }
                
                let existingAttendance = snapshot?.documents.compactMap {
                    AttendanceRecord(id: $0.documentID, data: $0.data())
                } ?? []
                
                // Load Leave Requests (nghỉ phép)
                self.loadApprovedLeaveRequests(year: year, month: month, userRef: userRef) { leaveDates in
                    DispatchQueue.main.async {
                        self.isLoading = false
                        
                        self.attendanceRecords = self.mergeAttendanceAndLeave(
                            attendance: existingAttendance,
                            leaveDates: leaveDates,
                            year: year,
                            month: month
                        )
                        
                        self.calculateStats()
                    }
                }
            }
    }

    // MARK: - Load đơn nghỉ phép đã duyệt
    private func loadApprovedLeaveRequests(year: Int, month: Int, userRef: DocumentReference, completion: @escaping ([String]) -> Void) {
        
        let calendar = Calendar.current
        
        // Tạo ngày đầu tháng
        var startComponents = DateComponents(year: year, month: month, day: 1)
        guard let startOfMonth = calendar.date(from: startComponents) else {
            completion([])
            return
        }
        
        // Tạo ngày cuối tháng
        var endComponents = DateComponents(year: year, month: month, day: 31)
        let endOfMonth = calendar.date(from: endComponents) ?? calendar.date(byAdding: .month, value: 1, to: startOfMonth)!
        
        db.collection("leave_request")
            .whereField("id_user", isEqualTo: userRef)
            .whereField("status", isEqualTo: "approved")
            .whereField("from_date", isGreaterThanOrEqualTo: Timestamp(date: startOfMonth))
            .whereField("to_date", isLessThanOrEqualTo: Timestamp(date: endOfMonth))
            .getDocuments { snapshot, error in
                
                if let error = error {
                    print("❌ Lỗi load leave_request: \(error.localizedDescription)")
                    completion([])
                    return
                }
                
                guard let documents = snapshot?.documents else {
                    completion([])
                    return
                }
                
                var leaveDates: [String] = []
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy-MM-dd"
                
                for doc in documents {
                    let data = doc.data()
                    
                    if let fromTS = data["from_date"] as? Timestamp,
                       let toTS = data["to_date"] as? Timestamp {
                        
                        let fromDate = fromTS.dateValue()
                        let toDate = toTS.dateValue()
                        
                        var current = fromDate
                        while current <= toDate {
                            let dateStr = formatter.string(from: current)
                            leaveDates.append(dateStr)
                            guard let nextDate = calendar.date(byAdding: .day, value: 1, to: current) else { break }
                            current = nextDate
                        }
                    }
                }
                completion(leaveDates)
            }
    }

    // MARK: - Merge Attendance + Leave
    private func mergeAttendanceAndLeave(attendance: [AttendanceRecord], leaveDates: [String], year: Int, month: Int) -> [AttendanceRecord] {
        var result: [AttendanceRecord] = []
        let leaveSet = Set(leaveDates)
        let attendanceDict = Dictionary(uniqueKeysWithValues: attendance.map { ($0.date, $0) })
        
        let calendar = Calendar.current
        let firstDay = calendar.date(from: DateComponents(year: year, month: month, day: 1))!
        let today = Date()
        let isCurrentMonth = calendar.component(.year, from: today) == year && calendar.component(.month, from: today) == month
        let daysToShow = isCurrentMonth ? calendar.component(.day, from: today) : calendar.range(of: .day, in: .month, for: firstDay)!.count
        
        for day in (1...daysToShow).reversed() {
            let currentDate = calendar.date(byAdding: .day, value: day - 1, to: firstDay)!
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            let dateString = formatter.string(from: currentDate)
            
            if let record = attendanceDict[dateString] {
                result.append(record)
            } else if leaveSet.contains(dateString) {
                // Ưu tiên hiển thị Nghỉ phép
                result.append(AttendanceRecord(leaveDate: dateString))
            } else {
                // Mặc định vắng
                result.append(AttendanceRecord(
                    id: "empty-\(dateString)",
                    data: [
                        "date": dateString,
                        "status": "absent",
                        "check_in": nil,
                        "check_out": nil
                    ]
                ))
            }
        }
        return result
    }
    // MARK: - Tạo danh sách ngày từ đầu tháng đến ngày hiện tại
    private func generateFullMonthDays(year: Int, month: Int, existingRecords: [AttendanceRecord]) -> [AttendanceRecord] {
        var result: [AttendanceRecord] = []
        let calendar = Calendar.current
        
        // Ngày đầu tháng
        let firstDay = calendar.date(from: DateComponents(year: year, month: month, day: 1))!
        
        // Ngày hiện tại
        let today = Date()
        let currentComponents = calendar.dateComponents([.year, .month], from: today)
        let isCurrentMonth = (currentComponents.year == year && currentComponents.month == month)

        let daysToShow: Int

        if isCurrentMonth {
            daysToShow = calendar.component(.day, from: today)
        } else {
            daysToShow = calendar.range(of: .day, in: .month, for: firstDay)!.count
        }
        
        for day in (1...daysToShow).reversed() {
            let currentDate = calendar.date(byAdding: .day, value: day - 1, to: firstDay)!
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            formatter.timeZone = TimeZone.current

            let dateString = formatter.string(from: currentDate)
            // Tìm record có sẵn
            let recordDict = Dictionary(uniqueKeysWithValues: existingRecords.map { ($0.date, $0) })

            if let record = recordDict[dateString] {
                result.append(record)
            } else {
               
                result.append(AttendanceRecord(
                    id: "empty-\(dateString)",
                    data: [
                        "date": dateString,
                        "status": "Vắng",
                        "check_in": nil,
                        "check_out": nil
                    ]
                ))
            }
        }
        
        return result
    }
    
    private func calculateStats() {
        totalHours = 0.0
        workDays = 0
        lateCount = 0
        absentCount = 0
        leaveCount = 0
        
        for record in attendanceRecords {
            if record.isOnLeave {
                leaveCount += 1
            }
            if record.isAbsent {
                absentCount += 1
            } else if let checkIn = record.checkIn, let checkOut = record.checkOut {
                let hours = checkOut.timeIntervalSince(checkIn) / 3600
                totalHours += hours
                workDays += 1
            }
            
            if record.isLate {
                lateCount += 1
            }
            
        }
    }
}

// MARK: - Model
struct AttendanceRecord: Identifiable {
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
