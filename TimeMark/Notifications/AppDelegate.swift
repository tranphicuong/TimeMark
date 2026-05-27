import UIKit
import FirebaseCore
import FirebaseMessaging
import UserNotifications
import FirebaseAuth
import FirebaseFirestore

class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate, MessagingDelegate {
    
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        
        FirebaseApp.configure()
        
        // Cấu hình Notification
        UNUserNotificationCenter.current().delegate = self
        
        // Xin quyền
        NotificationService.shared.requestPermission()
        
        // Lên lịch nhắc trễ giờ (8:15 sáng)
        NotificationService.shared.scheduleLateReminder()
        
        // Đăng ký FCM
        Messaging.messaging().delegate = self
        
        return true
    }
    
    // MARK: - Nhận Device Token
    func application(_ application: UIApplication,
                     didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Messaging.messaging().apnsToken = deviceToken
       
    }
    
    // MARK: - Firebase Messaging Token
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        guard let token = fcmToken else { return }
       
        // Lưu token vào user document
        if let uid = Auth.auth().currentUser?.uid {
            Firestore.firestore().collection("users").document(uid).setData([
                "fcmToken": token
            ], merge: true)
        }
    }
    
    // MARK: - Hiển thị thông báo khi app đang mở
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner, .sound, .badge])
    }
    
    // MARK: - Người dùng click vào thông báo
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        completionHandler()
    }
}
