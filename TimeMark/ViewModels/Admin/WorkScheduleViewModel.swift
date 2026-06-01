//
//  WorkScheduleViewModel.swift
//  TimeMark
//
//  Created by Doanh on 5/6/26.
//

import Foundation
import SwiftUI


// MARK: - ViewModel
class WorkScheduleViewModel: ObservableObject {
    @Published var workSchedule: WorkSchedule?
    @Published var isLoading = false
    @Published var showSuccess = false
    @Published var errorMessage = ""
    @Published var showError = false
    
    func saveWorkSchedule(checkIn: String, checkOut: String, lateAfterMinute: Int) {
        guard let id = workSchedule?.id else { return }
        
        print("🕐 checkIn: \(checkIn), checkOut: \(checkOut)")
        
        isLoading = true
        WorkScheduleService.shared.updateWorkSchedule(
            id: id,
            checkIn: checkIn,
            checkOut: checkOut,
            lateAfterMinute: lateAfterMinute
        ) { [weak self] success in
            DispatchQueue.main.async {
                self?.isLoading = false
                if success { self?.showSuccess = true }
                else { self?.errorMessage = "Cập nhật thất bại"; self?.showError = true }
            }
        }
    }

    func fetchWorkSchedule() {
        isLoading = true
        print("🔍 [WorkScheduleVM] Fetching work schedule...")
        WorkScheduleService.shared.getWorkSchedule { [weak self] schedule in
            DispatchQueue.main.async {
                self?.isLoading = false
                self?.workSchedule = schedule
            }
        }
    }
}
