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
    
    func saveWorkSchedule(checkIn: Date, checkOut: Date, lateAfterMinute: Int) {
        guard let id = workSchedule?.id else {
            print("❌ [WorkScheduleVM] workSchedule?.id is NIL - cannot save")
            return
        }

        
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        formatter.timeZone = TimeZone.current

        isLoading = true
        
        WorkScheduleService.shared.updateWorkSchedule(
            id: id,
            checkIn: formatter.string(from: checkIn),
            checkOut: formatter.string(from: checkOut),
            lateAfterMinute: lateAfterMinute
        ) { [weak self] success in
            DispatchQueue.main.async {
                self?.isLoading = false
                print("📩 [WorkScheduleVM] API response - success: \(success)")
                if success {
                    self?.showSuccess = true
                    print("✅ [WorkScheduleVM] Update successful")
                } else {
                    self?.errorMessage = "Cập nhật thất bại"
                    self?.showError = true
                    print("❌ [WorkScheduleVM] Update failed")
                }
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
