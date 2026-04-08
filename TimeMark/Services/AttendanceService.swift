import Foundation
import FirebaseFirestore
import FirebaseAuth
import CoreLocation

class AttendanceService {
    
    private let db = Firestore.firestore()
    static let shared = AttendanceService()
    
    // MARK: - Check-in với ảnh
    func checkIn(location: CLLocation, faceImageBase64: String?, completion: @escaping (Bool, String) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else {
            completion(false, "Chưa đăng nhập")
            return
        }
        
        let today = todayString()
        
        db.collection("attendance")
            .whereField("user_id", isEqualTo: uid)
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
                    "user_id": uid,
                    "date": today,
                    "check_in": Timestamp(date: Date()),
                    "check_out": NSNull(),
                    "status": "present",
                    "latitude": location.coordinate.latitude,
                    "longitude": location.coordinate.longitude,
                    "face_image": faceImageBase64 ?? "",
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
    
    func checkOut(completion: @escaping (Bool, String) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else {
            completion(false, "Chưa đăng nhập")
            return
        }
        
        let today = todayString()
        
        db.collection("attendance")
            .whereField("user_id", isEqualTo: uid)
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
                
                doc.reference.updateData(["check_out": Timestamp(date: Date())]) { error in
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
}
