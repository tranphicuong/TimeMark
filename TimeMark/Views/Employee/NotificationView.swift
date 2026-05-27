import SwiftUI

struct NotificationView: View {
    
    @StateObject private var service = NotificationService.shared
    @State private var selectedTab = 0
    @State private var showDeleteAllConfirm = false
    @State private var itemToDelete: String? = nil
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
            VStack(spacing: 0) {
                // Filter tabs
                HStack(spacing: 10) {
                    ForEach(0..<3, id: \.self) { i in
                        Button {
                            withAnimation(.easeInOut(duration: 0.2)) { selectedTab = i }
                        } label: {
                            Text(tabs[i])
                                .font(.subheadline).fontWeight(.medium)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .background(selectedTab == i ? Color.blue : Color(.systemGray5))
                                .foregroundColor(selectedTab == i ? .white : .primary)
                                .cornerRadius(12)
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.vertical, 8)
                
                if filtered.isEmpty {
                    emptyView
                } else {
                    List {
                        let grouped = Dictionary(grouping: filtered) {
                            Calendar.current.startOfDay(for: $0.createdAt)
                        }
                        
                        ForEach(grouped.keys.sorted(by: >), id: \.self) { date in
                            Section(header:
                                Text(sectionLabel(date))
                                    .font(.headline)
                                    .foregroundColor(.primary)
                                    .textCase(.uppercase)
                                    .padding(.top, 8)
                            ) {
                                ForEach(grouped[date] ?? []) { item in
                                    notifRow(item)
                                        .listRowSeparator(.hidden)
                                        .listRowBackground(Color.white)
                                }
                            }
                        }
                    }
                    .listStyle(.plain)
                }
            }
            .background(Color(.systemGray6).ignoresSafeArea())
            .navigationTitle("Thông báo")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                if service.unreadCount > 0 {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button("Đọc hết") { service.markAllAsRead() }
                    }
                }
                if !service.notifications.isEmpty {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(role: .destructive) {
                            showDeleteAllConfirm = true
                        } label: {
                            Image(systemName: "trash")
                        }
                    }
                }
            }
            // Xác nhận xóa tất cả
            .confirmationDialog("Xoá tất cả thông báo?", isPresented: $showDeleteAllConfirm) {
                Button("Xoá tất cả", role: .destructive) {
                    service.deleteAllNotifications()
                }
                Button("Huỷ", role: .cancel) {}
            }
            // Xác nhận xóa từng cái
            .confirmationDialog("Xoá thông báo này?", isPresented: Binding(
                get: { itemToDelete != nil },
                set: { if !$0 { itemToDelete = nil }}
            )) {
                Button("Xoá", role: .destructive) {
                    if let id = itemToDelete {
                        service.deleteNotification(id)
                        itemToDelete = nil
                    }
                }
                Button("Huỷ", role: .cancel) { itemToDelete = nil }
            }
            .onAppear { service.startListening() }
            .onDisappear { service.stopListening() }
        }
    }
    
    // MARK: - Row với Swipe Delete
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
            }
            
            if !item.isRead {
                Circle().fill(Color.blue).frame(width: 8, height: 8).padding(.top, 6)
            }
        }
        .onTapGesture {
               if !item.isRead {
                   service.markAsRead(item.id)
               }
           }
        .padding(.vertical, 8)

        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
            Button(role: .destructive) {
                itemToDelete = item.id
            } label: {
                Label("Xoá", systemImage: "trash.fill")
            }
        }
    }
    
    var emptyView: some View {
        VStack(spacing: 12) {
            Image(systemName: "bell.slash").font(.system(size: 48)).foregroundColor(.gray.opacity(0.4))
            Text("Không có thông báo").font(.subheadline).foregroundColor(.gray)
        }
        .frame(maxHeight: .infinity)
    }
    
    // MARK: - Helpers
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
