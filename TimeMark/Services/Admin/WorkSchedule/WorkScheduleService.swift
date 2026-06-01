//
//  WorkScheduleService.swift
//  TimeMark
//
//  Created by Rebel on 5/6/26.
//
import Foundation
// MARK: - Service
class WorkScheduleService {
    static let shared = WorkScheduleService()
    private init() {}
    
    func getWorkSchedule(completion: @escaping (WorkSchedule?) -> Void) {
        APIService.shared.request(endpoint: "/api/work_schedule") { data, error in
            guard let data = data, error == nil else {
                completion(nil)
                return
            }
            
            // Log raw JSON
            if let json = String(data: data, encoding: .utf8) {
                print("📦 Raw JSON: \(json)")
            }
            
            do {
                let response = try JSONDecoder().decode(WorkScheduleResponse.self, from: data)
                print("✅ Decoded: \(String(describing: response.data))")
                completion(response.data)
            } catch {
                print("❌ Decode error: \(error)")
                completion(nil)
            }
        }
    }
    
    func updateWorkSchedule(
        id: String,
        checkIn: String,
        checkOut: String,
        lateAfterMinute: Int,
        completion: @escaping (Bool) -> Void
    ) {
        print("service: in \(checkIn), out \(checkOut)")
        
        let body: [String: Any] = [
            "check_in_time":checkIn,
            "check_out_time": checkOut,
            "late_after_minute": lateAfterMinute,
            "early_leave_minute": lateAfterMinute
        ]     
        
        APIService.shared.request(
            endpoint: "/api/work_schedule/\(id)",
            method: "PUT",
            body: body
        ) { data, error in
            guard let data = data, error == nil else {
                completion(false)
                return
            }
            let response = try? JSONDecoder().decode(BaseResponse.self, from: data)
            completion(response?.success ?? false)
        }
    }
}

struct BaseResponse: Codable {
    let success: Bool
    let message: String?
}
