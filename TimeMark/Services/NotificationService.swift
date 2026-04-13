import Foundation
import FirebaseFirestore
import FirebaseAuth
import UserNotifications
import FirebaseMessaging
import SwiftUI
import UIKit

class NotificationService: ObservableObject {
    
    static let shared = NotificationService()
    private let db = Firestore.firestore()
    private var listener: ListenerRegistration?
    
    @Published var notifications: [NotificationItem] = []
    @Published var unreadCount: Int = 0
    

    @Published var showBanner = false
    @Published var bannerTitle = ""
    @Published var bannerBody = ""
    
    // MARK: - Request Permission
    func requestPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, _ in
            if granted {
                DispatchQueue.main.async {
                    UIApplication.shared.registerForRemoteNotifications()
                }
            }
        }
    }
    
    // MARK: - Lên lịch nhắc trễ giờ check-in (8:15 sáng)
    func scheduleLateReminder(startHour: Int = 8, startMinute: Int = 0, grace: Int = 15) {
        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: ["late_reminder"])
        
        let content = UNMutableNotificationContent()
        content.title = "⚠️ Nhắc nhở chấm công"
        content.body = "Đã \(grace) phút kể từ giờ bắt đầu. Bạn đã check-in chưa?"
        content.sound = .default
        
        var date = DateComponents()
        date.hour = startHour
        date.minute = startMinute + grace
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: date, repeats: true)
        let request = UNNotificationRequest(identifier: "late_reminder", content: content, trigger: trigger)
        
        center.add(request)
    }
    
    // MARK: - Realtime Listener
    func startListening() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let userRef = db.document("users/\(uid)")
        
        listener = db.collection("notification")
            .whereField("id_user", isEqualTo: userRef)
            .order(by: "created_at", descending: true)
            .addSnapshotListener { [weak self] snapshot, error in
                guard let self = self else { return }
                
                if let error = error {
                    print("Notification listener error: \(error.localizedDescription)")
                    return
                }
                
                snapshot?.documentChanges.forEach { change in
                    if change.type == .added {
                        let data = change.document.data()
                        
                        if (data["is_read"] as? Bool) == false {
                            let title = data["title"] as? String ?? "TimeMark"
                            let body = data["content"] as? String ?? ""
                   
                            DispatchQueue.main.async {
                                self.bannerTitle = title
                                self.bannerBody = body
                                self.showBanner = true
                                
                                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                                    self.showBanner = false
                                }
                            }
                            
                           
                            self.sendPushNotification(title: title, body: body)
                        }
                    }
                }
                
                DispatchQueue.main.async {
                    self.notifications = snapshot?.documents.compactMap {
                        NotificationItem(id: $0.documentID, data: $0.data())
                    } ?? []
                    
                    self.unreadCount = self.notifications.filter { !$0.isRead }.count
                    UIApplication.shared.applicationIconBadgeNumber = self.unreadCount
                }
            }
    }
    
    // MARK: - Fake Push Notification
    private func sendPushNotification(title: String, body: String) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.subtitle = "TimeMark"
        content.body = body
        content.sound = .default
        content.badge = NSNumber(value: self.unreadCount + 1)
        
 
        content.threadIdentifier = "timemark_notifications"
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        
        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request)
    }
    
    // MARK: - Tạo thông báo
    func notifyCheckIn() {
        saveToFirestore(
            title: "Check-in thành công",
            content: "Bạn đã chấm công lúc \(now()). Chúc bạn một ngày làm việc hiệu quả!",
            type: "checkin"
        )
    }
    
    func notifyCheckOut() {
        saveToFirestore(
            title: "Check-out thành công",
            content: "Ca làm việc hôm nay đã kết thúc. Hẹn gặp lại ngày mai!",
            type: "checkout"
        )
    }
    
    private func saveToFirestore(title: String, content: String, type: String) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let userRef = db.document("users/\(uid)")
        
        let data: [String: Any] = [
            "id_user": userRef,
            "title": title,
            "content": content,
            "type": type,
            "is_read": false,
            "read_at": NSNull(),
            "created_at": Timestamp(date: Date())
        ]
        
        db.collection("notification").addDocument(data: data)
    }
    
    // MARK: - Đánh dấu đã đọc
    func markAsRead(_ id: String) {
        db.collection("notification").document(id).updateData([
            "is_read": true,
            "read_at": Timestamp(date: Date())
        ])
    }
    
    func markAllAsRead() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let userRef = db.document("users/\(uid)")
        
        db.collection("notification")
            .whereField("id_user", isEqualTo: userRef)
            .whereField("is_read", isEqualTo: false)
            .getDocuments { snapshot, _ in
                snapshot?.documents.forEach {
                    $0.reference.updateData([
                        "is_read": true,
                        "read_at": Timestamp(date: Date())
                    ])
                }
            }
    }
    
    func stopListening() {
        listener?.remove()
    }
    
    private func now() -> String {
        let f = DateFormatter()
        f.dateFormat = "HH:mm"
        return f.string(from: Date())
    }
}

