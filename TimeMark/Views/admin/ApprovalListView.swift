import SwiftUI

// MARK: - 3. Approval List View (NEW)
struct ApprovalListView: View {
    @State private var selectedFilter: ApprovalStatus = .pending
    @State private var requests: [LeaveRequest] = [
        LeaveRequest(id: "1", employeeName: "Lê Thị Mai Anh", leaveType: "Nghỉ phép năm", dateRange: "25/03 - 27/03", reason: "Giải quyết việc gia đình ở quê, cần nghỉ 3 ngày để di chuyển và sắp xếp công việc cá nhân.", avatarName: "person.crop.square.fill", status: .pending),
        LeaveRequest(id: "2", employeeName: "Nguyễn Văn Nam", leaveType: "Nghỉ phép năm", dateRange: "30/03 - 31/03", reason: "Nghỉ phép định kỳ theo kế hoạch du lịch đã đăng ký từ đầu tháng.", avatarName: "person.crop.square.fill", status: .pending)
    ]
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Button(action: {}) {
                    Image(systemName: "line.3.horizontal")
                        .font(.title2)
                        .foregroundColor(.blue)
                }
                Spacer()
                Text("TimeMark Admin")
                    .font(.headline)
                    .foregroundColor(.blue)
                Spacer()
                Image(systemName: "person.crop.circle.fill")
                    .resizable()
                    .frame(width: 35, height: 35)
                    .foregroundColor(.gray)
            }
            .padding(.horizontal)
            .padding(.top, 10)
            
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 20) {
                    // Title Section
                    VStack(alignment: .leading, spacing: 8) {
                        Text("HỆ THỐNG QUẢN LÝ")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.blue)
                        
                        Text("Phê duyệt nghỉ phép")
                            .font(.system(size: 24, weight: .bold))
                        
                        Text("Xem xét và xử lý các yêu cầu nghỉ phép đang chờ xử lý từ đội ngũ nhân viên.")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .fixedSize(horizontal: false, vertical: true)
                        
                        // New Request Counter
                        HStack {
                            Image(systemName: "calendar.badge.plus")
                                .foregroundColor(.blue)
                            Text("03 Yêu cầu mới")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.blue)
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.blue.opacity(0.05))
                        .cornerRadius(12)
                    }
                    .padding(.horizontal)
                    .padding(.top, 20)
                    
                    // Custom Tab Switcher
                    HStack(spacing: 0) {
                        FilterButton(title: "Chờ duyệt", isSelected: selectedFilter == .pending) { selectedFilter = .pending }
                        FilterButton(title: "Đã duyệt", isSelected: selectedFilter == .approved) { selectedFilter = .approved }
                        FilterButton(title: "Đã từ chối", isSelected: selectedFilter == .rejected) { selectedFilter = .rejected }
                    }
                    .padding(4)
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                    .padding(.horizontal)
                    
                    // Request List
                    VStack(spacing: 16) {
                        ForEach(requests.filter { $0.status == selectedFilter }) { request in
                            LeaveRequestCard(request: request,
                                            onApprove: { handleAction(id: request.id, to: .approved) },
                                            onReject: { handleAction(id: request.id, to: .rejected) })
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.bottom, 20)
            }
        }
    }
    
    private func handleAction(id: String, to status: ApprovalStatus) {
        withAnimation(.spring()) {
            if let index = requests.firstIndex(where: { $0.id == id }) {
                requests[index].status = status
            }
        }
    }
}

