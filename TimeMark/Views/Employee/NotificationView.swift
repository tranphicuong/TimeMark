import SwiftUI

struct NotificationView: View {
    
    @State private var selectedTab = 0  // 0: Tất cả, 1: Chưa đọc, 2: Hệ thống
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    
                    // MARK: - FILTER TABS (giống style HistoryView)
                    HStack(spacing: 12) {
                        ForEach(0..<3, id: \.self) { index in
                            filterButton(title: titles[index], index: index)
                        }
                    }
                    .padding(.horizontal)
                    
                    // MARK: - HÔM NAY
                    sectionTitle("HÔM NAY")
                    
                    VStack(spacing: 16) {
                        notificationItem(
                            icon: "checkmark.circle.fill",
                            iconColor: .green,
                            title: "Check-in thành công",
                            desc: "Bạn đã chấm công vào làm lúc 08:00 sáng tại văn phòng Quận 1.",
                            time: "08:00 AM"
                        )
                        
                        notificationItemWithButton(
                            icon: "exclamationmark.circle.fill",
                            iconColor: .orange,
                            title: "Nhắc chưa check-in",
                            desc: "Đã quá 15 phút so với giờ bắt đầu, vui lòng thực hiện check-in ngay.",
                            time: "08:15 AM"
                        )
                    }
                    .padding(.horizontal)
                    
                    // MARK: - HÔM QUA
                    sectionTitle("HÔM QUA")
                    
                    VStack(spacing: 16) {
                        notificationItem(
                            icon: "clock.fill",
                            iconColor: .gray,
                            title: "Check-out thành công",
                            desc: "Ca làm việc của bạn đã kết thúc. Hẹn gặp lại vào ngày mai!",
                            time: "17:30 PM"
                        )
                        
                        notificationItem(
                            icon: "checkmark.circle.fill",
                            iconColor: .green,
                            title: "Check-in thành công",
                            desc: "Bạn đã bắt đầu ca làm việc sớm hơn 5 phút. Điểm cộng cho sự chuyên cần!",
                            time: "07:55 AM"
                        )
                    }
                    .padding(.horizontal)
                    
                    Spacer(minLength: 40)
                }
                .padding(.top, 8)
            }
            .background(Color(.systemGray6).ignoresSafeArea())
            .navigationTitle("Thông báo")
            .navigationBarTitleDisplayMode(.large)
        }
    }
    
    private let titles = ["Tất cả", "Chưa đọc", "Hệ thống"]
    
    // MARK: - Filter Button (style giống filter tháng ở HistoryView)
    private func filterButton(title: String, index: Int) -> some View {
        Text(title)
            .font(.subheadline)
            .fontWeight(.medium)
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .frame(maxWidth: .infinity)
            .background(selectedTab == index ? Color.blue : Color(.systemGray5))
            .foregroundColor(selectedTab == index ? .white : .primary)
            .cornerRadius(12)
            .onTapGesture {
                withAnimation(.easeInOut(duration: 0.2)) {
                    selectedTab = index
                }
            }
    }
    
    // MARK: - Section Title (giống HistoryView)
    private func sectionTitle(_ title: String) -> some View {
        Text(title)
            .font(.headline)
            .fontWeight(.semibold)
            .foregroundColor(.primary)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal)
    }
    
    // MARK: - Normal Notification Item
    private func notificationItem(
        icon: String,
        iconColor: Color,
        title: String,
        desc: String,
        time: String
    ) -> some View {
        HStack(alignment: .top, spacing: 14) {
            ZStack {
                Circle()
                    .fill(iconColor.opacity(0.15))
                    .frame(width: 44, height: 44)
                
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundColor(iconColor)
            }
            
            VStack(alignment: .leading, spacing: 6) {
                HStack(alignment: .firstTextBaseline) {
                    Text(title)
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    Spacer()
                    
                    Text(time)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Text(desc)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineSpacing(3)
            }
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(20)
        .shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: 3)
    }
    
    // MARK: - Notification Item with Button
    private func notificationItemWithButton(
        icon: String,
        iconColor: Color,
        title: String,
        desc: String,
        time: String
    ) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .top, spacing: 14) {
                ZStack {
                    Circle()
                        .fill(iconColor.opacity(0.15))
                        .frame(width: 44, height: 44)
                    
                    Image(systemName: icon)
                        .font(.title3)
                        .foregroundColor(iconColor)
                }
                
                VStack(alignment: .leading, spacing: 6) {
                    HStack(alignment: .firstTextBaseline) {
                        Text(title)
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        Spacer()
                        
                        Text(time)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Text(desc)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .lineSpacing(3)
                }
            }
            
            Button {
                print("Check-in ngay tapped")
            } label: {
                Text("Check-in ngay")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(Color.blue)
                    .cornerRadius(14)
            }
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(20)
        .shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: 3)
    }
}

#Preview {
    NotificationView()
}
