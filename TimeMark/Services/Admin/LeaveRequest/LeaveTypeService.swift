//
//  LeaveTypeService.swift
//  TimeMark
//
//  Created by Doanh on 4/29/26.
//

import Foundation

class LeaveTypeService {
    static let shared = LeaveTypeService()
    private init() {}

    func fetchLeaveTypes(
        completion: @escaping ([LeaveTypeModel]) -> Void
    ) {
        APIService.shared.request(
            endpoint: "/leave_type"
        ) { data, error in

            guard let data = data, error == nil else {
                completion([])
                return
            }

            do {
                let result = try JSONDecoder().decode(
                    LeaveTypeResponse.self,
                    from: data
                )

                DispatchQueue.main.async {
                    completion(result.data)
                }
            } catch {
                print(error)
                completion([])
            }
        }
    }
}
