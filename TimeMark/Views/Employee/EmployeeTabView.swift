
import SwiftUI
    
struct EmployeeTabView: View {
    @StateObject var noti = NotificationService.shared
    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("Home")
                }

            HistoryView()
                .tabItem {
                    Image(systemName: "clock.arrow.circlepath")
                    Text("Lịch sử")
                }

            NotificationView()
                .tabItem {
                    Image(systemName: "bell.fill")
                    Text("Thông báo")
                }.badge(noti.unreadCount)

            ProfileView()
                .tabItem {
                    Image(systemName: "person.fill")
                    Text("Hồ sơ")
                }
        }
        .accentColor(.blue)
    }
}
