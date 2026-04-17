import Foundation
import FirebaseFirestore
import FirebaseAuth
import CoreLocation

class AttendanceService {
    
    private let db = Firestore.firestore()
    static let shared = AttendanceService()
    
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
        // Kiểm tra đã có bản ghi hôm nay chưa
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
                let workStart = self.getWorkStartTime()           // 08:00 hôm nay
                            let minutesLate = now.timeIntervalSince(workStart) / 60
                            
                            let status: String = minutesLate <= 0 ? "normal" : "trễ"
                
                let data: [String: Any] = [
                    "id_user": userRef,
                    "date": today,
                    "check_in": Timestamp(date: Date()),
                    "check_out": NSNull(),
                    "img_checkin": imgCheckinURL ?? "",
                    "img_checkout": "",
                    "status": status,
                    "early_minutes": NSNull(),
                    "late_minutes": NSNull(),
                    "overtime_minutes": NSNull(),
                    "created_at": Timestamp(date: Date())
                ]
                
                self.db.collection("attendance").addDocument(data: data) { error in
                    if let error = error {
                        completion(false, "Check-in thất bại: \(error.localizedDescription)")
                    } else {
                        completion(true, "Check-in thành công!")
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
                
                var updateData: [String: Any] = [
                    "check_out": Timestamp(date: Date())
                ]
                
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
    // MARK: - Helper: Giờ bắt đầu làm việc (08:00)
    private func getWorkStartTime() -> Date {
        let calendar = Calendar.current
        var components = calendar.dateComponents([.year, .month, .day], from: Date())
        components.hour = 8
        components.minute = 0
        components.second = 0
        return calendar.date(from: components) ?? Date()
    }
    private func todayString() -> String {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        return f.string(from: Date())
    }
}
