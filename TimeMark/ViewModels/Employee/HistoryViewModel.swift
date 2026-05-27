import SwiftUI
import FirebaseFirestore
import FirebaseAuth

class HistoryViewModel: ObservableObject {
    
    @Published var attendanceRecords: [AttendanceRecordEmployee] = []
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
                    AttendanceRecordEmployee(id: $0.documentID, data: $0.data())
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
    private func mergeAttendanceAndLeave(attendance: [AttendanceRecordEmployee], leaveDates: [String], year: Int, month: Int) -> [AttendanceRecordEmployee] {
        var result: [AttendanceRecordEmployee] = []
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
                result.append(AttendanceRecordEmployee(leaveDate: dateString))
            } else {
                // Mặc định vắng
                result.append(AttendanceRecordEmployee(
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
    // MARK: - Tạo danh sách ngày từ đầu tháng đến ngày hiện tại
    private func generateFullMonthDays(year: Int, month: Int, existingRecords: [AttendanceRecordEmployee]) -> [AttendanceRecordEmployee] {
        var result: [AttendanceRecordEmployee] = []
        let calendar = Calendar.current
        
        let firstDay = calendar.date(from: DateComponents(year: year, month: month, day: 1))!
        
        let today = Date()
        let currentComponents = calendar.dateComponents([.year, .month], from: today)
        let isCurrentMonth = (currentComponents.year == year && currentComponents.month == month)

        let daysToShow: Int
        if isCurrentMonth {
            daysToShow = calendar.component(.day, from: today)
        } else {
            daysToShow = calendar.range(of: .day, in: .month, for: firstDay)!.count
        }
        
        let recordDict = Dictionary(uniqueKeysWithValues: existingRecords.map { ($0.date, $0) })
        
        for day in (1...daysToShow).reversed() {
            let currentDate = calendar.date(byAdding: .day, value: day - 1, to: firstDay)!
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            formatter.timeZone = TimeZone.current
            let dateString = formatter.string(from: currentDate)
            
            if let record = recordDict[dateString] {
                result.append(record)
            } else {
                result.append(AttendanceRecordEmployee(
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
