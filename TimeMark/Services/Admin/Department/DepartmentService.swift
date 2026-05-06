import Foundation

final class DepartmentService {
    static let shared = DepartmentService()

    private init() {}

    // MARK: - Common Error
    private var noDataError: NSError {
        NSError(
            domain: "DepartmentService",
            code: -1,
            userInfo: [
                NSLocalizedDescriptionKey: "Không nhận được dữ liệu từ server"
            ]
        )
    }
    // MARK: - Get All Departments
    func getAllDepartments(
        completion: @escaping (Result<[DepartmentData], Error>) -> Void
    ) {
        APIService.shared.request(
            endpoint: "/api/department",
            method: "GET"
        ) { data, error in

            if let error = error {
                completion(.failure(error))
                return
            }

            guard let data = data else {
                completion(.failure(self.noDataError))
                return
            }

            if let jsonString = String(data: data, encoding: .utf8) {
                print("📦 Get All Departments Response:", jsonString)
            }

            do {
                let decoded = try JSONDecoder().decode(
                    DepartmentListResponse.self,
                    from: data
                )

                var results: [DepartmentData] = []
                let group = DispatchGroup()

                for item in decoded.data {
                    group.enter()

                    DepartmentService.shared.getDepartmentUsers(
                        departmentId: item.id
                    ) { result in
                        switch result {
                        case .success(let department):
                            results.append(department)

                        case .failure(let error):
                            print("❌ Lỗi department \(item.id):", error.localizedDescription)
                        }

                        group.leave()
                    }
                }

                group.notify(queue: .main) {
                    completion(.success(results))
                }

            } catch {
                print("❌ Decode departments error:", error)
                completion(.failure(error))
            }
        }
    }
    // MARK: - Get Department Users
    func getDepartmentUsers(
        departmentId: String,
        completion: @escaping (Result<DepartmentData, Error>) -> Void
    ) {
        APIService.shared.request(
            endpoint: "/api/department/\(departmentId)/users",
            method: "GET"
        ) { data, error in

            if let error = error {
                completion(.failure(error))
                return
            }

            guard let data = data else {
                completion(.failure(self.noDataError))
                return
            }

            if let jsonString = String(data: data, encoding: .utf8) {
                print("📦 Department Users Response:", jsonString)
            }

            do {
                let decoded = try JSONDecoder().decode(
                    DepartmentResponse.self,
                    from: data
                )

                completion(.success(decoded.data))

            } catch {
                print("❌ Decode users error:", error)
                completion(.failure(error))
            }
        }
    }

    // MARK: - Create Department
    func createDepartment(
        name: String,
        icon: String,
        description: String,
        iconColor: String,
        completion: @escaping (Result<DepartmentActionData, Error>) -> Void
    ) {
        let body: [String: Any] = [
            "name": name,
            "icon": icon,
            "description": description,
            "iconColor": iconColor
        ]

        APIService.shared.request(
            endpoint: "/api/department/create",
            method: "POST",
            body: body
        ) { data, error in

            if let error = error {
                completion(.failure(error))
                return
            }

            guard let data = data else {
                completion(.failure(self.noDataError))
                return
            }

            if let jsonString = String(data: data, encoding: .utf8) {
                print("📦 Create Department Response:", jsonString)
            }

            do {
                let decoded = try JSONDecoder().decode(
                    DepartmentActionResponse.self,
                    from: data
                )

                completion(.success(decoded.data))

            } catch {
                print("❌ Create decode error:", error)
                completion(.failure(error))
            }
        }
    }

    // MARK: - Update Department
    func updateDepartment(
        id: String,
        name: String,
        icon: String,
        description: String,
        iconColor: String,
        completion: @escaping (Result<DepartmentActionData, Error>) -> Void
    ) {
        let body: [String: Any] = [
            "name": name,
            "icon": icon,
            "description": description,
            "iconColor": iconColor
        ]

        APIService.shared.request(
            endpoint: "/api/department/\(id)",
            method: "PATCH",
            body: body
        ) { data, error in

            if let error = error {
                completion(.failure(error))
                return
            }

            guard let data = data else {
                completion(.failure(self.noDataError))
                return
            }

            if let jsonString = String(data: data, encoding: .utf8) {
                print("📦 Update Department Response:", jsonString)
            }

            do {
                let decoded = try JSONDecoder().decode(
                    DepartmentActionResponse.self,
                    from: data
                )

                completion(.success(decoded.data))

            } catch {
                print("❌ Update decode error:", error)
                completion(.failure(error))
            }
        }
    }

    // MARK: - Delete Department
    func deleteDepartment(
        id: String,
        completion: @escaping (Result<String, Error>) -> Void
    ) {
        APIService.shared.request(
            endpoint: "/api/department/\(id)",
            method: "DELETE"
        ) { data, error in

            if let error = error {
                completion(.failure(error))
                return
            }

            guard let data = data else {
                let noDataError = NSError(
                    domain: "DepartmentService",
                    code: -1,
                    userInfo: [
                        NSLocalizedDescriptionKey: "Không có dữ liệu trả về"
                    ]
                )
                completion(.failure(noDataError))
                return
            }

            do {
                let decoded = try JSONDecoder().decode(
                    DeleteDepartmentResponse.self,
                    from: data
                )

                completion(.success(decoded.message))

            } catch {
                completion(.failure(error))
            }
        }
    }
}
