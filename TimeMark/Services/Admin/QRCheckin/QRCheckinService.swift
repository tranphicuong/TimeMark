
import Foundation

final class QRCheckinService {
    static let shared = QRCheckinService()
    private init() {}

    // Lấy QR hiện tại (admin polling)
    func getCurrentQR(completion: @escaping (Result<QRData, Error>) -> Void) {
        APIService.shared.request(
            endpoint: "/api/qr_checkin/current",
            method: "GET"
        ) { data, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            guard let data = data else {
                completion(.failure(NSError(domain: "QRService", code: -1,
                    userInfo: [NSLocalizedDescriptionKey: "Không có dữ liệu"])))
                return
            }
            do {
                let decoded = try JSONDecoder().decode(QRCurrentResponse.self, from: data)
                completion(.success(decoded.data))
            } catch {
                completion(.failure(error))
            }
        }
    }

    // Tạo QR mới thủ công
    func generateQR(completion: @escaping (Result<QRData, Error>) -> Void) {
        APIService.shared.request(
            endpoint: "/api/qr_checkin/generate",
            method: "POST"
        ) { data, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            guard let data = data else {
                completion(.failure(NSError(domain: "QRService", code: -1,
                    userInfo: [NSLocalizedDescriptionKey: "Không có dữ liệu"])))
                return
            }
            do {
                let decoded = try JSONDecoder().decode(QRCurrentResponse.self, from: data)
                completion(.success(decoded.data))
            } catch {
                completion(.failure(error))
            }
        }
    }
}
