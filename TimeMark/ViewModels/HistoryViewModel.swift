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
    
    static let shared = HistoryViewModel()
    
    private let db = Firestore.firestore()
    
    // MARK: - Load theo tháng
    func loadHistory(year: Int, month: Int) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        isLoading = true
        let userRef = db.document("users/\(uid)")
        
        let calendar = Calendar.current

        guard let firstDay = calendar.date(from: DateComponents(year: year, month: month, day: 1)),
              let range = calendar.range(of: .day, in: .month, for: firstDay)
        else {
            return
        }

        let lastDay = range.count

        let startDate = String(format: "%04d-%02d-01", year, month)
        let endDate   = String(format: "%04d-%02d-%02d", year, month, lastDay)
        db.collection("attendance")
            .whereField("id_user", isEqualTo: userRef)
            .whereField("date", isGreaterThanOrEqualTo: startDate)
            .whereField("date", isLessThanOrEqualTo: endDate)
            .order(by: "date", descending: true)
            .getDocuments { [weak self] snapshot, error in
                guard let self = self else { return }
                
                DispatchQueue.main.async {
                    self.isLoading = false
                    
                    let existing = snapshot?.documents.compactMap {
                        AttendanceRecord(id: $0.documentID, data: $0.data())
                    } ?? []
                    
                    // Chỉ tạo ngày từ đầu tháng đến ngày hiện tại
                    self.attendanceRecords = self.generateFullMonthDays(
                        year: year,
                        month: month,
                        existingRecords: existing
                    )
                    
                    self.calculateStats()
                }
            }
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
                // Ngày chưa check-in → hiển thị "VẮNG"
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
        
        for record in attendanceRecords {
            if record.status?.lowercased() == "vắng" {
                absentCount += 1
            } else if let checkIn = record.checkIn, let checkOut = record.checkOut {
                let hours = checkOut.timeIntervalSince(checkIn) / 3600
                totalHours += hours
                workDays += 1
            }
            
            if let status = record.status, status.lowercased().contains("trễ") {
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
}
