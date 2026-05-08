
import Foundation
class LeaveTypeService {
    static let shared = LeaveTypeService()
    private init() {}

    // ✅ GET theo ID (đúng với backend)
    func fetchLeaveType(
        id: String,
        completion: @escaping (LeaveTypeModel?) -> Void
    ) {
        APIService.shared.request(
            endpoint: "/api/leave_type/\(id)"
        ) { data, error in

            guard let data = data, error == nil else {
                completion(nil)
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
                print("Decode error:", error)
                completion(nil)
            }
        }
    }
    func fetchLeaveTypes(completion: @escaping ([LeaveTypeModel]) -> Void) {
        APIService.shared.request(endpoint: "/api/leave_type") { data, error in
            guard let data = data, error == nil else {
                completion([])
                return
            }
            do {
                // tuỳ response backend trả về array hay wrapped
                let result = try JSONDecoder().decode([LeaveTypeModel].self, from: data)
                DispatchQueue.main.async {
                    completion(result)
                }
            } catch {
                print("Decode error:", error)
                completion([])
            }
        }
    }
    // ✅ UPDATE số ngày phép
    func updateLeaveType(
        id: String,
        quantity: Int,
        completion: @escaping (Bool) -> Void
    ) {
        let body: [String: Any] = [
            "quantity": quantity
        ]

        APIService.shared.request(
            endpoint: "/api/leave_type/\(id)",
            method: "PUT",
            body: body
        ) { _, error in
            DispatchQueue.main.async {
                completion(error == nil)
            }
        }
    }
}
