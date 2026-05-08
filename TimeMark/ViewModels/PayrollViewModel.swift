//
//  PayrollViewModel.swift
//  TimeMark
//
//  Created by Rebel on 5/8/26.
//

// ViewModels/PayrollViewModel.swift

import Foundation
import SwiftUI

@MainActor
class PayrollViewModel: ObservableObject {
    
    // ─── Published State ──────────────────────
    @Published var selectedYear: Int
    @Published var selectedMonth: Int
    @Published var isLoading = false
    @Published var exportedURL: URL? = nil
    @Published var showShareSheet = false
    @Published var errorMessage: String? = nil
    @Published var showError = false
    
    // ─── Data ─────────────────────────────────
    let years = Array(2024...2030)
    let months: [(Int, String)] = [
        (1,"Tháng 1"),(2,"Tháng 2"),(3,"Tháng 3"),(4,"Tháng 4"),
        (5,"Tháng 5"),(6,"Tháng 6"),(7,"Tháng 7"),(8,"Tháng 8"),
        (9,"Tháng 9"),(10,"Tháng 10"),(11,"Tháng 11"),(12,"Tháng 12"),
    ]
    
    private let service = PayrollService.shared
    
    init() {
        let now = Date()
        let cal = Calendar.current
        selectedYear  = cal.component(.year,  from: now)
        selectedMonth = cal.component(.month, from: now)
    }
    
    // ─── Export ───────────────────────────────
    func exportPayroll() {
        Task {
            isLoading = true
            defer { isLoading = false }
            
            do {
                let url = try await service.exportPayroll(
                    year: selectedYear,
                    month: selectedMonth
                )
                exportedURL    = url
                showShareSheet = true
            } catch {
                errorMessage = error.localizedDescription
                showError    = true
            }
        }
    }
    
    // ─── Computed ─────────────────────────────
    var monthName: String {
        months.first(where: { $0.0 == selectedMonth })?.1 ?? "Tháng \(selectedMonth)"
    }
    
    var exportButtonTitle: String {
        isLoading ? "Đang tạo file..." : "Xuất Excel \(monthName)/\(selectedYear)"
    }
}
