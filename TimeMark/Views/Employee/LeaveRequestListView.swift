import SwiftUI

struct LeaveRequestListView: View {
    @StateObject private var vm = LeaveRequestListViewModel()
    
    var body: some View {
        NavigationStack {
            VStack {
                if vm.isLoading && vm.leaveRequests.isEmpty {
                    ProgressView("Đang tải danh sách...")
                        .frame(maxHeight: .infinity)
                } else if vm.leaveRequests.isEmpty {
                    EmptyStateView()
                } else {
                    List {
                        ForEach(vm.leaveRequests) { request in
                            LeaveRequestRow(request: request)
                        }
                    }
                    .listStyle(.insetGrouped)
                    .refreshable {
                        vm.refresh()
                    }
                }
            }
            .navigationTitle("Danh sách đơn nghỉ phép")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                Button(action: vm.refresh) {
                    Image(systemName: "arrow.clockwise")
                }
            }
            .alert("Lỗi", isPresented: .constant(vm.errorMessage != nil)) {
                Button("OK") { vm.errorMessage = nil }
            } message: {
                Text(vm.errorMessage ?? "")
            }
        }
    }
}

// MARK: - Row
struct LeaveRequestRow: View {
    let request: LeaveRequest
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                VStack(alignment: .leading) {
                    Text("\(request.fromDateString) → \(request.toDateString)")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                    
                    Text("\(request.days) ngày")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                StatusBadge(status: request.statusText, colorName: request.statusColorName)
            }
            
            Text(request.reason)
                .font(.body)
                .lineLimit(2)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Status Badge
struct StatusBadge: View {
    let status: String
    let colorName: String
    
    var body: some View {
        Text(status)
            .font(.caption)
            .fontWeight(.semibold)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(backgroundColor.opacity(0.15))
            .foregroundColor(foregroundColor)
            .cornerRadius(20)
    }
    
    private var foregroundColor: Color {
        switch colorName.lowercased() {
        case "green": return .green
        case "red":   return .red
        default:      return .orange
        }
    }
    
    private var backgroundColor: Color {
        switch colorName.lowercased() {
        case "green": return .green
        case "red":   return .red
        default:      return .orange
        }
    }
}
struct EmptyStateView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "calendar.badge.exclamationmark")
                .font(.system(size: 60))
                .foregroundColor(.gray)
            
            Text("Chưa có đơn nghỉ phép nào")
                .font(.headline)
            
            Text("Bạn chưa gửi đơn nghỉ phép nào.\nHãy tạo đơn mới ngay!")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxHeight: .infinity)
    }
}
