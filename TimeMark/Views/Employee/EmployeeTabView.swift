
import SwiftUI

struct EmployeeTabView: View {
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
                }

            ProfileView()
                .tabItem {
                    Image(systemName: "person.fill")
                    Text("Hồ sơ")
                }
        }
        .accentColor(.blue)
    }
}
