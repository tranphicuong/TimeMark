
import SwiftUI

struct RootView: View {
    @AppStorage("hasSeenOnboarding") var hasSeenOnboarding = false
    @AppStorage("isLoggedIn") var isLoggedIn = false
    @AppStorage("userRole") var userRole = ""

    var body: some View {
        if !hasSeenOnboarding {
            OnboardingView()
        } else if !isLoggedIn {	
            LoginView()
        } else if userRole == "admin" {
            AdminTabView()
        } else {
            EmployeeTabView() // ← đã kết nối HomeView
        }
    }
}

