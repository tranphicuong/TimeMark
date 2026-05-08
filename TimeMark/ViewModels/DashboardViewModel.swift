//
//  DashboardViewModel.swift
//  TimeMark
//
//  Created by Rebel on 5/5/26.
//

// DashboardViewModel.swift
import Foundation

final class DashboardViewModel: ObservableObject {
    @Published var summary: DashboardSummary?
    @Published var attendanceList: [AttendanceRecord] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    func load() {
        let today = Self.todayString()
        print(today)
        isLoading = true

        DashboardService.shared.fetchDashboard(date: today) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let data): self?.summary = data
                case .failure(let err): self?.errorMessage = err.localizedDescription
                }
            }
        }

        DashboardService.shared.fetchAttendanceList(date: today) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                switch result {
                case .success(let list): self?.attendanceList = list
                case .failure(let err): self?.errorMessage = err.localizedDescription
                }
            }
        }
    }

    static func todayString() -> String {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        return f.string(from: Date())
    }

    static func formatTimestamp(_ ts: FirebaseTimestamp?) -> String {
        guard let ts = ts else { return "--" }
        let date = ts.date
        let f = DateFormatter()
        f.dateFormat = "HH:mm"
        f.timeZone = TimeZone.current
        return f.string(from: date)
    }
}
