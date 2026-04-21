import Foundation



final class DepartmentService {
    static let shared = DepartmentService()

    private init() {}

    func getDepartmentUsers(
        departmentId: String,
        completion: @escaping (Result<DepartmentData, Error>) -> Void
    ) {
        APIService.shared.request(
            endpoint: "/api/department/\(departmentId)/users",
            method: "GET"
        ) { data, error in

            // lỗi từ API
            if let error = error {
                completion(.failure(error))
                return
            }

            // không có data
            guard let data = data else {
                let noDataError = NSError(
                    domain: "DepartmentService",
                    code: -1,
                    userInfo: [
                        NSLocalizedDescriptionKey: "Không nhận được dữ liệu từ server"
                    ]
                )
                completion(.failure(noDataError))
                return
            }

            // debug JSON trả về
            if let jsonString = String(data: data, encoding: .utf8) {
                print("📦 Department Response:", jsonString)
            }

            do {
                let decoded = try JSONDecoder().decode(
                    DepartmentResponse.self,
                    from: data
                )

                completion(.success(decoded.data))

            } catch {
                print("❌ Decode error:", error)
                completion(.failure(error))
            }
        }
    }
}
