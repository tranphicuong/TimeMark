
import Foundation
import FirebaseFirestore
import FirebaseAuth
import UserNotifications
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

    // MARK: - Xin quyền
    func requestPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, _ in
            if granted {
                DispatchQueue.main.async {
                    UIApplication.shared.registerForRemoteNotifications()
                }
            }
        }
    }

    // MARK: - Lên lịch nhắc trễ
    func scheduleLateReminder(startHour: Int = 8, startMinute: Int = 0, grace: Int = 15) {
        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: ["late_reminder"])

        let content = UNMutableNotificationContent()
        content.title = "Nhắc nhở chấm công"
        content.body  = "Đã \(grace) phút kể từ giờ bắt đầu. Bạn đã check-in chưa?"
        content.sound = .default

        var date        = DateComponents()
        date.hour       = startHour
        date.minute     = startMinute + grace

        let trigger = UNCalendarNotificationTrigger(dateMatching: date, repeats: true)
        center.add(UNNotificationRequest(identifier: "late_reminder", content: content, trigger: trigger))
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
                    print("Listener error: \(error.localizedDescription)")
                    return
                }

                // Push khi có thông báo mới
                snapshot?.documentChanges.forEach { change in
                    if change.type == .added {
                        let data = change.document.data()
                        if (data["is_read"] as? Bool) == false {
                            let title = data["title"]   as? String ?? "TimeMark"
                            let body  = data["content"] as? String ?? ""
                            DispatchQueue.main.async {
                                self.bannerTitle = title
                                self.bannerBody  = body
                                self.showBanner  = true
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

    // MARK: - Push local
    private func sendPushNotification(title: String, body: String) {
        let content             = UNMutableNotificationContent()
        content.title           = title
        content.subtitle        = "TimeMark"
        content.body            = body
        content.sound           = .default
        content.badge           = NSNumber(value: unreadCount + 1)
        content.threadIdentifier = "timemark_notifications"

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        UNUserNotificationCenter.current().add(
            UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        )
    }

    // MARK: - Tạo thông báo check-in
    func notifyCheckIn() {
        saveToFirestore(
            title: "Check-in thành công ",
            content: "Bạn đã chấm công vào làm lúc \(now()). Chúc bạn một ngày làm việc hiệu quả!",
            type: "checkin"
        )
    }

    // MARK: - Tạo thông báo check-out
    func notifyCheckOut() {
        saveToFirestore(
            title: "Check-out thành công ",
            content: "Ca làm việc hôm nay đã kết thúc lúc \(now()). Hẹn gặp lại ngày mai!",
            type: "checkout"
        )
    }

    // MARK: - Lưu Firestore
    private func saveToFirestore(title: String, content: String, type: String) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let userRef = db.document("users/\(uid)")

        db.collection("notification").addDocument(data: [
            "id_user":    userRef,
            "title":      title,
            "content":    content,
            "type":       type,
            "is_read":    false,
            "read_at":    NSNull(),
            "created_at": Timestamp(date: Date())
        ])
    }

    // MARK: - Đánh dấu đã đọc
    func markAsRead(_ id: String) {
        db.collection("notification").document(id).updateData([
            "is_read": true,
            "read_at": Timestamp(date: Date())
        ])
        if let i = notifications.firstIndex(where: { $0.id == id }) {
            notifications[i].isRead = true
            unreadCount = max(0, unreadCount - 1)
        }
    }

    // MARK: - Đánh dấu tất cả đã đọc
    func markAllAsRead() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let userRef = db.document("users/\(uid)")

        db.collection("notification")
            .whereField("id_user", isEqualTo: userRef)
            .whereField("is_read", isEqualTo: false)
            .getDocuments { snapshot, _ in
                snapshot?.documents.forEach {
                    $0.reference.updateData(["is_read": true, "read_at": Timestamp(date: Date())])
                }
            }
        notifications = notifications.map { var n = $0; n.isRead = true; return n }
        unreadCount = 0
    }

    // MARK: - XOA THONG BAO
    func deleteNotification(_ id: String) {
        db.collection("notification").document(id).delete { error in
            if let error = error {
                print(" Xoá notification lỗi: \(error.localizedDescription)")
            } else {
                print("Đã xoá notification: \(id)")
            }
        }
        // Xoá khỏi local list ngay lập tức (không cần chờ Firestore)
        notifications.removeAll { $0.id == id }
        unreadCount = notifications.filter { !$0.isRead }.count
    }

    // MARK: - Xoa nhieu thong bao
    func deleteNotifications(ids: Set<String>) {
        let batch = db.batch()
        ids.forEach { id in
            let ref = db.collection("notification").document(id)
            batch.deleteDocument(ref)
        }
        batch.commit { error in
            if let error = error {
                print(" Xoá batch lỗi: \(error.localizedDescription)")
            } else {
                print("Đã xoá \(ids.count) notifications")
            }
        }
        notifications.removeAll { ids.contains($0.id) }
        unreadCount = notifications.filter { !$0.isRead }.count
    }

    // MARK: -Xoa all noti
    func deleteAllNotifications() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let userRef = db.document("users/\(uid)")

        db.collection("notification")
            .whereField("id_user", isEqualTo: userRef)
            .getDocuments { [weak self] snapshot, _ in
                guard let self = self else { return }

                let batch = self.db.batch()
                snapshot?.documents.forEach { batch.deleteDocument($0.reference) }
                batch.commit { error in
                    if error == nil {
                        print(" Đã xoá tất cả notifications")
                    }
                }
            }
        notifications.removeAll()
        unreadCount = 0
    }

    // MARK: - danh dau chua doc
    func db_markAsUnread(_ id: String) {
        db.collection("notification").document(id).updateData([
            "is_read": false,
            "read_at": NSNull()
        ])
        if let i = notifications.firstIndex(where: { $0.id == id }) {
            notifications[i].isRead = false
            unreadCount += 1
        }
    }

    func stopListening() { listener?.remove() }

    private func now() -> String {
        let f = DateFormatter(); f.dateFormat = "HH:mm"; return f.string(from: Date())
    }
}
