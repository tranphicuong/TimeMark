import SwiftUI

struct NotificationView: View {
    
    @State private var selectedTab = 0
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                
                // HEADER
                HStack {
                    Image(systemName: "square.grid.2x2.fill")
                        .foregroundColor(.blue)
                    
                    Spacer()
                    
                    Text("TimeMark")
                        .font(.headline)
                        .foregroundColor(.blue)
                    
                    Spacer()
                    
                    Image(systemName: "person.crop.circle.fill")
                        .font(.title2)
                        .foregroundColor(.orange)
                }
                .padding(.horizontal)
                
                // TITLE
                VStack(alignment: .leading, spacing: 4) {
                    Text("Thông báo")
                        .font(.title)
                        .bold()
                    
                    Text("Cập nhật hoạt động mới nhất của bạn")
                        .foregroundColor(.gray)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)
                
                // FILTER
                HStack(spacing: 10) {
                    filterButton("Tất cả", index: 0)
                    filterButton("Chưa đọc", index: 1)
                    filterButton("Hệ thống", index: 2)
                }
                .padding(.horizontal)
                
                // TODAY
                sectionTitle("HÔM NAY")
                
                VStack(spacing: 12) {
                    
                    notificationItem(
                        icon: "checkmark",
                        iconColor: .green,
                        title: "Check-in thành công",
                        desc: "Bạn đã chấm công vào làm lúc 08:00 sáng tại văn phòng Quận 1.",
                        time: "08:00 AM"
                    )
                    
                    notificationItemWithButton(
                        icon: "exclamationmark",
                        iconColor: .orange,
                        title: "Nhắc chưa check-in",
                        desc: "Đã quá 15 phút so với giờ bắt đầu, vui lòng thực hiện check-in ngay.",
                        time: "08:15 AM"
                    )
                }
                .padding(.horizontal)
                
                // YESTERDAY
                sectionTitle("HÔM QUA")
                
                VStack(spacing: 12) {
                    
                    notificationItem(
                        icon: "clock",
                        iconColor: .gray,
                        title: "Check-out thành công",
                        desc: "Ca làm việc của bạn đã kết thúc. Hẹn gặp lại vào ngày mai!",
                        time: "17:30 PM"
                    )
                    
                    notificationItem(
                        icon: "checkmark",
                        iconColor: .green,
                        title: "Check-in thành công",
                        desc: "Bạn đã bắt đầu ca làm việc sớm hơn 5 phút. Điểm cộng cho sự chuyên cần!",
                        time: "07:55 AM"
                    )
                }
                .padding(.horizontal)
                
                Spacer(minLength: 30)
            }
        }
        .background(Color(.systemGray6).ignoresSafeArea())
    }
}

// MARK: - COMPONENTS

func filterButton(_ title: String, index: Int) -> some View {
    @State var selected = false
    
    return Text(title)
        .font(.subheadline)
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(index == 0 ? Color.blue : Color(.systemGray5))
        .foregroundColor(index == 0 ? .white : .black)
        .cornerRadius(20)
}

func sectionTitle(_ title: String) -> some View {
    HStack {
        Text(title)
            .font(.caption)
            .foregroundColor(.gray)
        Spacer()
        Rectangle()
            .fill(Color.gray.opacity(0.3))
            .frame(height: 1)
    }
    .padding(.horizontal)
}

func notificationItem(icon: String, iconColor: Color, title: String, desc: String, time: String) -> some View {
    HStack(alignment: .top, spacing: 12) {
        
        ZStack {
            Circle()
                .fill(iconColor.opacity(0.2))
                .frame(width: 40, height: 40)
            
            Image(systemName: icon)
                .foregroundColor(iconColor)
        }
        
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(title)
                    .bold()
                Spacer()
                Text(time)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            Text(desc)
                .font(.subheadline)
                .foregroundColor(.gray)
        }
    }
    .padding()
    .background(Color.white)
    .cornerRadius(16)
}

func notificationItemWithButton(icon: String, iconColor: Color, title: String, desc: String, time: String) -> some View {
    VStack(alignment: .leading, spacing: 10) {
        
        HStack(alignment: .top, spacing: 12) {
            ZStack {
                Circle()
                    .fill(iconColor.opacity(0.2))
                    .frame(width: 40, height: 40)
                
                Image(systemName: icon)
                    .foregroundColor(iconColor)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(title)
                        .bold()
                    Spacer()
                    Text(time)
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                
                Text(desc)
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
        }
        
        Button("Check-in ngay") {
            print("Go check-in")
        }
        .foregroundColor(.blue)
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(Color.blue.opacity(0.1))
        .cornerRadius(10)
    }
    .padding()
    .background(Color.white)
    .cornerRadius(16)
}
