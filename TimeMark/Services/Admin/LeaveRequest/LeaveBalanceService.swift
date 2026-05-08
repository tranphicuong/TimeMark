//
//  LeaveBalanceService.swift
//  TimeMark
//
//  Created by Rebel on 5/6/26.
//
import Foundation
class LeaveBalanceService {
    
    static let shared = LeaveBalanceService()
    
    func getAllLeaveBalances(completion: @escaping (Result<[LeaveBalance], Error>) -> Void) {
        APIService.shared.request(endpoint: "/api/leave_balance/") { data, error in
            
            if let error = error {
                print("❌ Network error:", error)
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                print("❌ Data nil")
                return
            }
            
            // In raw JSON ra xem
            print("✅ Raw JSON:", String(data: data, encoding: .utf8) ?? "không đọc được")
            
            do {
                let decoded = try JSONDecoder().decode(LeaveBalanceResponse.self, from: data)
                completion(.success(decoded.data))
            } catch {
                print("❌ Decode error:", error)
                completion(.failure(error))
            }
        }
    }
}
