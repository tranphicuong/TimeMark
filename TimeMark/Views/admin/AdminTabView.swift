import SwiftUI

struct AdminTabView: View {
    var body: some View {
        TabView{
            DashboardView()
                .tabItem{
                    Image(systemName:"square.grid.2x2.fill")
                    Text("Dashboard")
                }
            NavigationStack {
                           EmployeeListView()
                       }
                .tabItem{
                    Image(systemName:"person.2.fill")
                    Text("Nhân viên")
                }
            ApprovalListView()
                .tabItem {
                    Image(systemName: "calendar.badge.checkmark")
                    Text("Phê duyệt")
                }
            AdminSettingsView()
                .tabItem{
                    Image(systemName: "gearshape.fill")
                    Text("cài đặt")
                }
        }
        .accentColor(.blue)

    }
}
