//
//  QRCheckinViewModel.swift
//  TimeMark
//
//  Created by Rebel on 5/6/26.
//

import SwiftUI
import CoreImage.CIFilterBuiltins

final class QRCheckinViewModel: ObservableObject {
    @Published var qrImage: UIImage? = nil
    @Published var currentToken: String = ""
    @Published var expiresAt: String = ""
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    @Published var lastCheckinName: String? = nil  // tên người vừa check in

    private var pollingTimer: Timer?
    private let context = CIContext()
    private let filter = CIFilter.qrCodeGenerator()

    // MARK: - Bắt đầu polling
    func startPolling() {
        fetchCurrentQR()
        pollingTimer = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: true) { [weak self] _ in
            self?.fetchCurrentQR()
        }
    }

    func stopPolling() {
        pollingTimer?.invalidate()
        pollingTimer = nil
    }

    // MARK: - Lấy QR từ server
    private func fetchCurrentQR() {
        QRCheckinService.shared.getCurrentQR { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let qrData):
                    // Chỉ update UI khi token thay đổi
                    if qrData.token != self?.currentToken {
                        self?.currentToken = qrData.token
                        self?.expiresAt = qrData.expiresAt
                        self?.qrImage = self?.generateQRImage(from: qrData.token)
                        // Flash báo hiệu QR vừa đổi
                        self?.lastCheckinName = nil
                    }
                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                }
            }
        }
    }

    // MARK: - Tạo QR thủ công
    func refreshQR() {
        isLoading = true
        QRCheckinService.shared.generateQR { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                switch result {
                case .success(let qrData):
                    self?.currentToken = qrData.token
                    self?.expiresAt = qrData.expiresAt
                    self?.qrImage = self?.generateQRImage(from: qrData.token)
                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                }
            }
        }
    }

    // MARK: - Generate QR Image từ token
    private func generateQRImage(from string: String) -> UIImage? {
        let data = Data(string.utf8)
        filter.setValue(data, forKey: "inputMessage")
        filter.setValue("M", forKey: "inputCorrectionLevel")

        guard let outputImage = filter.outputImage else { return nil }

        // Scale lên to rõ nét
        let scale = CGAffineTransform(scaleX: 10, y: 10)
        let scaledImage = outputImage.transformed(by: scale)

        guard let cgImage = context.createCGImage(scaledImage, from: scaledImage.extent) else {
            return nil
        }

        return UIImage(cgImage: cgImage)
    }

    // MARK: - Format thời gian hết hạn
    var expiresAtFormatted: String {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        if let date = formatter.date(from: expiresAt) {
            let display = DateFormatter()
            display.dateFormat = "HH:mm:ss"
            return "Hết hạn lúc \(display.string(from: date))"
        }
        return ""
    }
}
