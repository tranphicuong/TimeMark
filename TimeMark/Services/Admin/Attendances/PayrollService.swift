//
//  PayrollService.swift
//  TimeMark
//
//  Created by Rebel on 5/8/26.
//
// Services/PayrollService.swift

import Foundation

class PayrollService {
    static let shared = PayrollService()
    private init() {}
    
    // ← đổi thành URL Render của bạn
    private let baseURL = "https://backend-timemark.onrender.com"
    
    func exportPayroll(year: Int, month: Int) async throws -> URL {
        let monthParam = String(format: "%04d-%02d", year, month)
        
        guard let url = URL(string: "\(baseURL)/api/payroll/export?month=\(monthParam)") else {
            throw PayrollError.invalidURL
        }
        
        let (tempURL, response) = try await URLSession.shared.download(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw PayrollError.noResponse
        }
        
        guard httpResponse.statusCode == 200 else {
            throw PayrollError.serverError(httpResponse.statusCode)
        }
        
        // Lưu file vào thư mục tạm với tên rõ ràng
        let filename = "cham-cong-\(monthParam).xlsx"
        let destURL = FileManager.default.temporaryDirectory
            .appendingPathComponent(filename)
        
        try? FileManager.default.removeItem(at: destURL)
        try FileManager.default.moveItem(at: tempURL, to: destURL)
        
        return destURL
    }
}

enum PayrollError: LocalizedError {
    case invalidURL
    case noResponse
    case serverError(Int)
    case fileSaveError
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:         return "URL không hợp lệ"
        case .noResponse:         return "Không nhận được phản hồi từ server"
        case .serverError(let c): return "Server lỗi: \(c)"
        case .fileSaveError:      return "Không lưu được file"
        }
    }
}
