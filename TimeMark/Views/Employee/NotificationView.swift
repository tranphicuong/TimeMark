import SwiftUI

struct NotificationView: View {
    
    @StateObject private var service = NotificationService.shared 
    @State private var selectedTab = 0
    private let tabs = ["Tất cả", "Chưa đọc", "Hệ thống"]
    
    var filtered: [NotificationItem] {
        switch selectedTab {
        case 1: return service.notifications.filter { !$0.isRead }
        case 2: return service.notifications.filter { $0.type == "system" }
        default: return service.notifications
        }
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Filter tabs
                    HStack(spacing: 10) {
                        ForEach(0..<3, id: \.self) { i in
                            Button {
                                withAnimation(.easeInOut(duration: 0.2)) { selectedTab = i }
                            } label: {
                                Text(tabs[i])
                                    .font(.subheadline).fontWeight(.medium)
                                    .frame(maxWidth: .infinity).padding(.vertical, 12)
                                    .background(selectedTab == i ? Color.blue : Color(.systemGray5))
                                    .foregroundColor(selectedTab == i ? .white : .primary)
                                    .cornerRadius(12)
                            }
                        }
                    }
                    .padding(.horizontal)
                    
                    if filtered.isEmpty {
                        VStack(spacing: 12) {
                            Image(systemName: "bell.slash").font(.system(size: 44)).foregroundColor(.gray.opacity(0.4))
                            Text("Không có thông báo").font(.subheadline).foregroundColor(.gray)
                        }
                        .padding(.top, 100)
                    } else {
                        let grouped = Dictionary(grouping: filtered) {
                            Calendar.current.startOfDay(for: $0.createdAt)
                        }
                        ForEach(grouped.keys.sorted(by: >), id: \.self) { date in
                            VStack(alignment: .leading, spacing: 12) {
                                Text(sectionLabel(date))
                                    .font(.headline).fontWeight(.semibold)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(.horizontal)
                                
                                ForEach(grouped[date] ?? []) { item in
                                    notifRow(item)
                                        .padding(.horizontal)
                                        .onTapGesture {
                                            if !item.isRead {
                                                service.markAsRead(item.id)
                                            }
                                        }
                                }
                            }
                        }
                    }
                    Spacer(minLength: 40)
                }
                .padding(.top, 8)
            }
            .background(Color(.systemGray6).ignoresSafeArea())
            .navigationTitle("Thông báo")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                if service.unreadCount > 0 {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Đọc hết") { service.markAllAsRead() }
                            .font(.subheadline).foregroundColor(.blue)
                    }
                }
            }
            .onAppear {
                service.startListening()
            }
            .onDisappear {
                service.stopListening()
            }
        }
    }
    
    // MARK: - Notification Row
    @ViewBuilder
    func notifRow(_ item: NotificationItem) -> some View {
        HStack(alignment: .top, spacing: 14) {
            ZStack {
                Circle().fill(iconColor(item.type).opacity(0.15)).frame(width: 44, height: 44)
                Image(systemName: iconName(item.type)).font(.title3).foregroundColor(iconColor(item.type))
            }
            
            VStack(alignment: .leading, spacing: 6) {
                HStack(alignment: .firstTextBaseline) {
                    Text(item.title)
                        .font(.headline)
                        .fontWeight(item.isRead ? .regular : .semibold)
                    Spacer()
                    Text(timeAgo(item.createdAt)).font(.caption).foregroundColor(.secondary)
                }
                Text(item.content)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineSpacing(3)
                
                if item.type == "late_reminder" && !item.isRead {
                    Button { service.markAsRead(item.id) } label: {
                        Text("Check-in ngay")
                            .font(.subheadline).fontWeight(.semibold)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                            .background(Color.blue)
                            .cornerRadius(12)
                    }
                    .padding(.top, 4)
                }
            }
            
            if !item.isRead {
                Circle().fill(Color.blue).frame(width: 8, height: 8).padding(.top, 4)
            }
        }
        .padding(16)
        .background(item.isRead ? Color.white : Color.blue.opacity(0.03))
        .cornerRadius(20)
        .shadow(color: .black.opacity(0.05), radius: 6, x: 0, y: 2)
    }
    
    // MARK: - Helper Functions
    func iconName(_ type: String) -> String {
        switch type {
        case "checkin": return "checkmark.circle.fill"
        case "checkout": return "clock.fill"
        case "late_reminder": return "exclamationmark.circle.fill"
        default: return "bell.fill"
        }
    }
    
    func iconColor(_ type: String) -> Color {
        switch type {
        case "checkin": return .green
        case "checkout": return .gray
        case "late_reminder": return .orange
        default: return .blue
        }
    }
    
    func timeAgo(_ date: Date) -> String {
        let d = Int(Date().timeIntervalSince(date))
        if d < 60 { return "Vừa xong" }
        if d < 3600 { return "\(d/60) phút trước" }
        if d < 86400 { return "\(d/3600) giờ trước" }
        let f = DateFormatter(); f.dateFormat = "dd/MM"; return f.string(from: date)
    }
    
    func sectionLabel(_ date: Date) -> String {
        let c = Calendar.current
        if c.isDateInToday(date) { return "HÔM NAY" }
        if c.isDateInYesterday(date) { return "HÔM QUA" }
        let f = DateFormatter(); f.locale = Locale(identifier: "vi_VN"); f.dateFormat = "EEEE, dd/MM"
        return f.string(from: date).uppercased()
    }
}
