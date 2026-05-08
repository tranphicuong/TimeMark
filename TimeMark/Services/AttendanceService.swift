import Foundation
import FirebaseFirestore
import FirebaseAuth
import CoreLocation

class AttendanceService {
    
    private let db = Firestore.firestore()
    static let shared = AttendanceService()
    
    // MARK: - Work Schedule Cache
    private var workSchedule: WorkSchedule?
    
    struct WorkSchedule {
        let checkInTime: DateComponents
        let checkOutTime: DateComponents
        let earlyLeaveMinute: Int
        let lateAfterMinute: Int
        let overtimeAfter: DateComponents
    }
    
    // MARK: - Load Work Schedule (ĐÃ SỬA)
    func loadWorkSchedule(completion: @escaping (Bool) -> Void) {
        print("🔍 Đang load work_schedule...")
        
        db.collection("work_schedule")
            .limit(to: 1)
            .getDocuments { [weak self] snapshot, error in
                if let error = error {
                    print("Lỗi Firestore: \(error.localizedDescription)")
                    completion(false)
                    return
                }
                
                guard let doc = snapshot?.documents.first else {
                    print("Không tìm thấy document nào trong collection work_schedule")
                    completion(false)
                    return
                }
                
                let data = doc.data()
                print("Tìm thấy ca làm việc - Document ID: \(doc.documentID)")
                print("Data: \(data)")
                
                let schedule = WorkSchedule(
                    checkInTime: self?.parseTimeFromTimestamp(data["check_in_time"]) ?? DateComponents(hour: 8, minute: 0),
                    checkOutTime: self?.parseTimeFromTimestamp(data["check_out_time"]) ?? DateComponents(hour: 17, minute: 0),
                    earlyLeaveMinute: data["early_leave_minute"] as? Int ?? 15,
                    lateAfterMinute: data["late_after_minute"] as? Int ?? 15,
                    overtimeAfter: self?.parseTimeFromTimestamp(data["overtime_after"]) ?? DateComponents(hour: 18, minute: 0)
                )
                
                self?.workSchedule = schedule
                completion(true)
            }
    }
    private func parseTimeFromTimestamp(_ value: Any?) -> DateComponents {
        if let timestamp = value as? Timestamp {
            let date = timestamp.dateValue()
            let calendar = Calendar.current
            let hour = calendar.component(.hour, from: date)
            let minute = calendar.component(.minute, from: date)
            return DateComponents(hour: hour, minute: minute)
        }
        
        // Fallback nếu là String
        if let timeString = value as? String {
            return parseTime(timeString)
        }
        
        return DateComponents(hour: 8, minute: 0)
    }
    
    private func parseTime(_ timeString: String) -> DateComponents {
        let components = timeString.split(separator: ":")
        guard components.count == 2,
              let hour = Int(components[0]),
              let minute = Int(components[1]) else {
            return DateComponents(hour: 8, minute: 0)
        }
        return DateComponents(hour: hour, minute: minute)
    }
    
    // MARK: - Public Getters cho UI
    func getWorkStartString() -> String {
        guard let schedule = workSchedule else { return "08:00" }
        return String(format: "%02d:%02d", schedule.checkInTime.hour ?? 8, schedule.checkInTime.minute ?? 0)
    }
    
    func getWorkEndString() -> String {
        guard let schedule = workSchedule else { return "17:00" }
        return String(format: "%02d:%02d", schedule.checkOutTime.hour ?? 17, schedule.checkOutTime.minute ?? 0)
    }
    
    private func getTodayWorkStart() -> Date {
        guard let schedule = workSchedule else {
            var comp = Calendar.current.dateComponents([.year, .month, .day], from: Date())
            comp.hour = 8
            comp.minute = 0
            return Calendar.current.date(from: comp) ?? Date()
        }
        
        var comp = Calendar.current.dateComponents([.year, .month, .day], from: Date())
        comp.hour = schedule.checkInTime.hour
        comp.minute = schedule.checkInTime.minute
        return Calendar.current.date(from: comp) ?? Date()
    }
    
    // MARK: - Check-in 
    func checkIn(
        location: CLLocation,
        imgCheckinURL: String?,
        completion: @escaping (Bool, String) -> Void
    ) {
        guard let uid = Auth.auth().currentUser?.uid else {
            completion(false, "Chưa đăng nhập")
            return
        }
        
        let today = todayString()
        let userRef = db.document("users/\(uid)")
        let now = Date()
        let workStart = getTodayWorkStart()
        
        let lateMinutes = max(0, Int(now.timeIntervalSince(workStart) / 60))
        let status = lateMinutes <= 0 ? "on-time" : "late"
        
        db.collection("attendance")
            .whereField("id_user", isEqualTo: userRef)
            .whereField("date", isEqualTo: today)
            .getDocuments { [weak self] snapshot, error in
                guard let self = self else { return }
                
                if let error = error {
                    completion(false, "Lỗi kiểm tra: \(error.localizedDescription)")
                    return
                }
                
                if let docs = snapshot?.documents, !docs.isEmpty {
                    completion(false, "Bạn đã check-in hôm nay rồi")
                    return
                }
                
                let data: [String: Any] = [
                    "id_user": userRef,
                    "date": today,
                    "check_in": Timestamp(date: now),
                    "check_out": NSNull(),
                    "img_checkin": imgCheckinURL ?? "",
                    "img_checkout": "",
                    "status": status,
                    "late_minutes": lateMinutes,
                    "early_minutes": NSNull(),
                    "overtime_minutes": NSNull(),
                    "created_at": Timestamp(date: now)
                ]
                
                self.db.collection("attendance").addDocument(data: data) { error in
                    if let error = error {
                        completion(false, "Check-in thất bại: \(error.localizedDescription)")
                    } else {
                        let msg = lateMinutes > 0
                            ? "Check-in thành công! (Trễ \(lateMinutes) phút)"
                            : "Check-in thành công! Đúng giờ"
                        completion(true, msg)
                    }
                }
            }
    }
    
    // MARK: - Check-out
    func checkOut(
        imgCheckoutURL: String?,
        completion: @escaping (Bool, String) -> Void
    ) {
        guard let uid = Auth.auth().currentUser?.uid else {
            completion(false, "Chưa đăng nhập")
            return
        }
        
        let today = todayString()
        let userRef = db.document("users/\(uid)")
        
        db.collection("attendance")
            .whereField("id_user", isEqualTo: userRef)
            .whereField("date", isEqualTo: today)
            .getDocuments { snapshot, error in
                if let error = error {
                    completion(false, "Lỗi: \(error.localizedDescription)")
                    return
                }
                
                guard let doc = snapshot?.documents.first else {
                    completion(false, "Chưa có bản ghi check-in hôm nay")
                    return
                }
                
                if doc.data()["check_out"] is Timestamp {
                    completion(false, "Bạn đã check-out hôm nay rồi")
                    return
                }
                
                var updateData: [String: Any] = ["check_out": Timestamp(date: Date())]
                
                if let url = imgCheckoutURL {
                    updateData["img_checkout"] = url
                }
                
                doc.reference.updateData(updateData) { error in
                    if let error = error {
                        completion(false, "Check-out thất bại")
                    } else {
                        completion(true, "Check-out thành công!")
                    }
                }
            }
    }
    
    private func todayString() -> String {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        return f.string(from: Date())
    }
    
    // MARK: - QR Check-in Token
    func getCurrentQRToken(completion: @escaping (String?) -> Void) {
        db.collection("qr_checkin")
            .whereField("isUsed", isEqualTo: false)
            .order(by: "createdAt", descending: true)  // Lấy token mới nhất
            .limit(to: 1)
            .getDocuments { snapshot, error in
                if let error = error {
                    print("❌ Lỗi lấy QR Token: \(error.localizedDescription)")
                    completion(nil)
                    return
                }
                
                guard let doc = snapshot?.documents.first,
                      let token = doc.data()["token"] as? String else {
                    print("⚠️ Không tìm thấy QR token hợp lệ")
                    completion(nil)
                    return
                }
                
                print("✅ Lấy QR Token thành công: \(token.prefix(20))...")
                completion(token)
            }
    }
}
