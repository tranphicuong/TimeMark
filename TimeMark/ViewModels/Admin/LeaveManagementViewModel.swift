//
//  LeaveManagementViewModel.swift
//  TimeMark
//
//  Created by Rebel on 5/6/26.
//
import Foundation
import SwiftUI
class LeaveManagementViewModel: ObservableObject {
    
    @Published var leaveType: LeaveTypeModel?
    @Published var employees: [LeaveBalance] = []
    @Published var defaultDays: String = "0"
    
    // LOAD ALL
    func loadData() {
        loadLeaveType()
        loadEmployees()
    }
    
    // LOAD leave type
    func loadLeaveType() {
        LeaveTypeService.shared.fetchLeaveType(
            id: "kt3dCcKaA46mMbfnSZAb"
        ) { data in
            DispatchQueue.main.async {
                self.leaveType = data
                self.defaultDays = "\(data?.quantity ?? 0)"
            }
        }
    }
    
    // LOAD employees
    func loadEmployees() {
        LeaveBalanceService.shared.getAllLeaveBalances { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let data):
                    self.employees = data
                    print(data)
                case .failure(let error):
                    print(error)
                }
            }
        }
    }
    
    // UPDATE
    func applyToAll() {
        guard let id = leaveType?.id,
              let quantity = Int(defaultDays) else { return }
        
        LeaveTypeService.shared.updateLeaveType(
            id: id,
            quantity: quantity
        ) { success in
            if success {
                print("Đã cập nhật phép năm")
                self.loadData()
            }
        }
    }
}
