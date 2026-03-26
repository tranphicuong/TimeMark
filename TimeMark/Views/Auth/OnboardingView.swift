import SwiftUI

struct OnboardingView: View {
    @State private var currentPage = 0
    @AppStorage("hasSeenOnboarding") var hasSeenOnboarding = false
    
    var body: some View {
        VStack {
            
            // Header
            HStack {
                Text("TimeMark")
                    .foregroundColor(.blue)
                    .fontWeight(.bold)
                Spacer()
            }
            .padding()
            
            // Swipe area
            TabView(selection: $currentPage) {
                
                OnboardItem(
                    title: "Chấm công hiện đại",
                    desc: "QR và GPS nhanh chóng, chính xác",
                    image: "clock"
                ).tag(0)
                
                OnboardItem(
                    title: "Quản lý dễ dàng",
                    desc: "Theo dõi lịch sử chấm công",
                    image: "chart.bar"
                ).tag(1)
                
                OnboardItem(
                    title: "Tiện lợi",
                    desc: "Mọi lúc mọi nơi",
                    image: "location"
                ).tag(2)
                
            }
            .tabViewStyle(PageTabViewStyle())
            
            // Dots
            HStack(spacing: 8) {
                ForEach(0..<3) { index in
                    Circle()
                        .fill(index == currentPage ? Color.blue : Color.gray)
                        .frame(width: 8, height: 8)
                }
            }
            
            // Button
            Button(action: {
                if currentPage < 2 {
                    currentPage += 1
                } else {
                    hasSeenOnboarding = true
                }
            }) {
                Text(currentPage == 2 ? "Bắt đầu" : "Tiếp tục")
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(12)
            }
            .padding()
        }
    }
}
