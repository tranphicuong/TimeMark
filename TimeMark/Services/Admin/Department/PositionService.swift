import Foundation

final class PositionService {
    static let shared = PositionService()
    private init() {}

    // MARK: - Common Error
    private var noDataError: NSError {
        NSError(
            domain: "PositionService",
            code: -1,
            userInfo: [
                NSLocalizedDescriptionKey: "Không nhận được dữ liệu từ server"
            ]
        )
    }

    // MARK: - Get All Positions
    func getAllPositions(
        completion: @escaping (Result<[Position], Error>) -> Void
    ) {
        APIService.shared.request(
            endpoint: "/api/position",
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
                print("📦 Positions Response:", jsonString)
            }

            do {
                let decoded = try JSONDecoder().decode(
                    PositionListResponse.self,
                    from: data
                )

                completion(.success(decoded.data))

            } catch {
                print("❌ Decode positions error:", error)
                completion(.failure(error))
            }
        }
    }

    // MARK: - Create Position
    func createPosition(
        name: String,
        description: String,
        completion: @escaping (Result<String, Error>) -> Void
    ) {
        let body: [String: Any] = [
            "name": name,
            "description": description
        ]

        APIService.shared.request(
            endpoint: "/api/position/create",
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
                print("📦 Create Position Response:", jsonString)
            }

            do {
                let decoded = try JSONDecoder().decode(
                    PositionActionResponse.self,
                    from: data
                )

                completion(.success(decoded.data.message))

            } catch {
                completion(.failure(error))
            }
        }
    }

    // MARK: - Delete Position
    func deletePosition(
        id: String,
        completion: @escaping (Result<String, Error>) -> Void
    ) {
        APIService.shared.request(
            endpoint: "/api/position/delete/\(id)",
            method: "DELETE"
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
                print("📦 Delete Position Response:", jsonString)
            }

            do {
                let decoded = try JSONDecoder().decode(
                    DeletePositionResponse.self,
                    from: data
                )

                completion(.success(decoded.message))

            } catch {
                completion(.failure(error))
            }
        }
    }
}
