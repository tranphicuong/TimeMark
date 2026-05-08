//
//  AttendanceService.swift
//  TimeMark
//
//  Created by Rebel on 5/5/26.
//

// DashboardService.swift
import Foundation

final class DashboardService {
    static let shared = DashboardService()
    private init() {}

    func fetchDashboard(
        date: String,
        completion: @escaping (Result<DashboardSummary, Error>) -> Void
    ) {
        APIService.shared.request(
            endpoint: "/api/attendance/dashboard/\(date)",
            method: "GET"
        ) { data, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            guard let data = data else { return }
            do {
                let decoded = try JSONDecoder().decode(DashboardSummaryResponse.self, from: data)
                completion(.success(decoded.data))
            } catch {
                completion(.failure(error))
            }
        }
    }

    func fetchAttendanceList(
        date: String,
        completion: @escaping (Result<[AttendanceRecord], Error>) -> Void
    ) {
        APIService.shared.request(
            endpoint: "/api/attendance/list/\(date)",
            method: "GET"
        ) { data, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            guard let data = data else { return }
            do {
                let decoded = try JSONDecoder().decode(AttendanceListResponse.self, from: data)
                completion(.success(decoded.data))
            } catch {
                completion(.failure(error))
            }
        }
    }
}
