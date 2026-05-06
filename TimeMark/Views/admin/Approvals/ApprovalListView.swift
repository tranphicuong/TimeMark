import SwiftUI

// MARK: - 3. Approval List View (NEW)
struct ApprovalListView: View {
    @StateObject private var viewModel = ApprovalListViewModel()
    @State private var showApproveModal = false
    @State private var selectedRequestId: String?
    @State private var noteText = ""
    @State private var selectedStatus: ApprovalStatus = .pending
    var body: some View {
        VStack(spacing: 0) {
            // Header

            
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 20) {
                    // Title Section
                    VStack(alignment: .leading, spacing: 8) {
                        Text("HỆ THỐNG QUẢN LÝ")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(.blue)
                        
                        Text("Phê duyệt nghỉ phép")
                            .font(.system(size: 20, weight: .bold))
                        
                        Text("Xem xét và xử lý các yêu cầu nghỉ phép đang chờ xử lý từ đội ngũ nhân viên.")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .fixedSize(horizontal: false, vertical: true)
                        
                        // New Request Counter
                        HStack {
                            Image(systemName: "calendar.badge.plus")
                                .foregroundColor(.blue)
                            Text("\(viewModel.pendingCount) Yêu cầu mới")
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
                        FilterButton(
                            title: "Chờ duyệt",
                            isSelected: viewModel.selectedFilter == .pending
                        ) {
                            viewModel.changeFilter(.pending)
                        }
                        FilterButton(
                            title: "Đã duyệt",
                            isSelected: viewModel.selectedFilter == .approved
                        ) {
                            viewModel.changeFilter(.approved)
                        }
                        FilterButton(
                            title: "Đã từ chối",
                            isSelected: viewModel.selectedFilter == .rejected
                        ) {
                            viewModel.changeFilter(.rejected)
                        }

                    }
                    .padding(4)
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                    .padding(.horizontal)
                    
                    // Request List
                    VStack(spacing: 16) {
                        ForEach(viewModel.requests) { request in
                            LeaveRequestCard(request: request,
                                             onApprove: {
                                                 selectedRequestId = request.id
                                                 selectedStatus = .approved
                                                 noteText = ""
                                                 showApproveModal = true
                                             },

                                             onReject: {
                                                 selectedRequestId = request.id
                                                 selectedStatus = .rejected
                                                 noteText = ""
                                                 showApproveModal = true
                                             })
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.bottom, 20)
            }
        }
        .onAppear {
            viewModel.fetchRequests()
        }
        .sheet(isPresented: $showApproveModal) {
            ApprovalNoteModal(
                noteText: $noteText,
                status: selectedStatus
            ) {
                handleAction()
            }
        }
    }
    
    private func handleAction() {
        guard let id = selectedRequestId else { return }

        LeaveRequestService.shared.updateLeaveStatus(
            id: id,
            status: selectedStatus,
            approvedBy: "cYJVasrkT1RQlMGUAJOoheypGvF2",
            note: noteText
        ) { success, message in
            if success {
                withAnimation(.spring()) {
                    viewModel.fetchRequests()
                }
                showApproveModal = false
            } else {
                print("Error:", message ?? "")
            }
        }
    }
    
    @ViewBuilder
    var overlayView: some View {
        if viewModel.isLoading {
            ZStack {
                Color.black.opacity(0.15)
                    .ignoresSafeArea()

                VStack(spacing: 16) {
                    ProgressView()
                        .scaleEffect(1.4)

                    Text("Đang tải dữ liệu...")
                        .font(.headline)
                }
                .padding(30)
                .background(Color.white)
                .cornerRadius(16)
            }
        }
        else if let error = viewModel.errorMessage {
            ZStack {
                Color.black.opacity(0.15)
                    .ignoresSafeArea()

                VStack(spacing: 20) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.system(size: 50))
                        .foregroundColor(.orange)

                    Text("Lỗi tải dữ liệu")
                        .font(.headline)
                        .bold()

                    Text(error)
                        .font(.caption)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)

                    Button("Tải lại") {
                        viewModel.fetchRequests()
                    }
                    .buttonStyle(.borderedProminent)
                }
                .padding()
                .background(Color.white)
                .cornerRadius(16)
            }
        }
    }
}

