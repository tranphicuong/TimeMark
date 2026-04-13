import SwiftUI

struct RootView: View {
    
    @AppStorage("hasSeenOnboarding") var hasSeenOnboarding = false
    
    @StateObject var noti = NotificationService.shared
    
    @StateObject private var authVM = AuthViewModel.shared
    
    var body: some View {
        ZStack {
            
            Group {
                if authVM.isCheckingAuth{
                    ZStack{
                        Color.blue.ignoresSafeArea()
                        
                        VStack(spacing: 20) {
                            Image(systemName: "clock.arrow.circlepath")
                                .font(.system(size: 60))
                                .foregroundColor(.blue)
                                .padding(24)
                                .background(Color.white)
                                .clipShape(RoundedRectangle(cornerRadius: 24))
                            
                            Text("TimeMark")
                                .font(.title)
                                .bold()
                                .foregroundColor(.white)
                            
                            ProgressView()
                                .tint(.white)
                        }
                    }
                }
                else if !hasSeenOnboarding {
                    OnboardingView()
                }
                else if !authVM.isLoggedIn {
                    LoginView()
                }
                else if authVM.userRole == "admin" {
                    Text("Admin Dashboard - Đang phát triển")
                        .font(.largeTitle)
                }
                else {
                    EmployeeTabView()
                }
            }
            
            VStack {
                if noti.showBanner {
                    FakePushBanner(title: noti.bannerTitle, message: noti.bannerBody)
                        .transition(.move(edge: .top).combined(with: .opacity))
                }
                Spacer()
            }
            .animation(.easeInOut, value: noti.showBanner)
        }
        .onChange(of: authVM.isLoggedIn) { loggedIn in
                   if loggedIn {
                       // Bắt đầu lắng nghe notification sau khi đăng nhập
                       NotificationService.shared.startListening()
                   } else {
                       NotificationService.shared.stopListening()
                   }
               }
           }
       }
