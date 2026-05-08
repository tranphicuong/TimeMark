//
//  LeaveRequestService.swift
//  TimeMark
//
//  Created by Rebel on 4/29/26.
//

import Foundation

class LeaveRequestService
{
    static let shared = LeaveRequestService()
    private init() {}
    func fetchLeaveRequests(
        status: ApprovalStatus,
        completion: @escaping ([LeaveRequest]) -> Void
    ) {
        
        
        APIService.shared.request(
            endpoint: "/api/leave_request?status=\(status.rawValue)"
            
        ) { data, error in

            if let error = error {
                print("error:", error)
                completion([])
                return
            }

            guard let data = data else {
                completion([])
                return
            }

            do {
                let result = try JSONDecoder().decode(
                    LeaveRequestResponse.self,
                    from: data
                )

                completion(result.data)

            } catch {
                print("decode error:", error)
                completion([])
            }
        }
    }
    
    func updateLeaveStatus(
        id: String,
        status: ApprovalStatus,
        approvedBy: String,
        note: String,
        completion: @escaping (Bool, String?) -> Void
    )
    {
        let body: [String: Any] = [
            "status": status.rawValue,
            "approved_by": approvedBy,
            "note": note
        ]

        APIService.shared.request(
            endpoint: "/api/leave_request/\(id)/status",
            method: "PATCH",
            body: body
        ) { data, error in

            DispatchQueue.main.async {
                if let error = error {
                    completion(false, error.localizedDescription)
                    return
                }

                guard let data = data else {
                    completion(false, "No response data")
                    return
                }

                do {
                    let response = try JSONSerialization.jsonObject(
                        with: data
                    ) as? [String: Any]

                    let success = response?["success"] as? Bool ?? false
                    let message = response?["message"] as? String

                    completion(success, message)
                } catch {
                    completion(false, error.localizedDescription)
                }
            }
        }
    }
}
