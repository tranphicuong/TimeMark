import Foundation
import FirebaseFirestore

struct NotificationItem: Identifiable {
    var id: String
    var title: String
    var content: String
    var type: String
    var isRead: Bool
    var createdAt: Date
    
    init(id: String, data: [String: Any]) {
        self.id = id
        self.title = data["title"] as? String ?? ""
        self.content = data["content"] as? String ?? ""
        self.type = data["type"] as? String ?? "system"
        self.isRead = data["is_read"] as? Bool ?? false
        self.createdAt = (data["created_at"] as? Timestamp)?.dateValue() ?? Date()
    }
}
