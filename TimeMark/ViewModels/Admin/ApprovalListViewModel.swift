//
//  ApprovalListViewModel.swift
//  TimeMark
//
//  Created by Rebel on 4/29/26.
//

import Foundation

class ApprovalListViewModel: ObservableObject {
    @Published var requests: [LeaveRequest] = []
    @Published var selectedFilter: ApprovalStatus = .pending
    @Published var isLoading: Bool = false
    @Published var pendingCount: Int = 0
    @Published var errorMessage: String? = nil
    func fetchRequests() {
        isLoading = true
        errorMessage = nil

        LeaveRequestService.shared.fetchLeaveRequests(status: selectedFilter) { [weak self] data in
            guard let self = self else { return }

            DispatchQueue.main.async {
                self.isLoading = false
                self.requests = data
            }
        }
        fetchPendingCount()
    }
    //đếm số đơn xin off chưa được duyệt
    func fetchPendingCount() {
        LeaveRequestService.shared.fetchLeaveRequests(status: .pending) { [weak self] data in
            DispatchQueue.main.async {
                self?.pendingCount = data.count
            }
        }
    }
    func changeFilter(_ status: ApprovalStatus) {
        selectedFilter = status
        fetchRequests()
    }
}
