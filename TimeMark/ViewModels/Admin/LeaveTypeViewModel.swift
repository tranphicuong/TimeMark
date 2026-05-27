//
//  LeaveTypeViewModel.swift
//  TimeMark
//
//  Created by Rebel on 5/6/26.
//
import Foundation
import SwiftUI

class LeaveTypeViewModel: ObservableObject {
    
    @Published var leaveType: LeaveTypeModel?
    @Published var isLoading = false
    
    // ✅ LOAD
    func loadLeaveType() {
        isLoading = true
        
        LeaveTypeService.shared.fetchLeaveType(
            id: "kt3dCcKaA46mMbfnSZAb"
        ) { data in
            
            DispatchQueue.main.async {
                self.leaveType = data
                self.isLoading = false
                
                if let quantity = data?.quantity {
                    print("Số ngày phép:", quantity)
                }
            }
        }
    }
    
    // ✅ UPDATE
    func updateLeaveDays(newValue: Int) {
        guard let id = leaveType?.id else { return }
        
        LeaveTypeService.shared.updateLeaveType(
            id: id,
            quantity: newValue
        ) { success in
            
            DispatchQueue.main.async {
                if success {
                    print("Update thành công")
                    self.loadLeaveType() // reload lại
                }
            }
        }
    }
}
