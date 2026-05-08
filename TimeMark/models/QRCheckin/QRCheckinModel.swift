//
//  QRCheckinModel.swift
//  TimeMark
//
//  Created by Doanh on 5/6/26.
//

import Foundation

// MARK: - Response khi lấy QR hiện tại
struct QRCurrentResponse: Decodable {
    let message: String
    let data: QRData
}

struct QRData: Decodable {
    let qrId: String
    let token: String
    let expiresAt: String
}

// MARK: - Response khi nhân viên scan
struct QRScanResponse: Decodable {
    let message: String
    let data: QRScanData
}

struct QRScanData: Decodable {
    let attendanceId: String
    let userId: String
    let name: String?
    let avatarURL: String?
    let checkin_at: String
    let newToken: String
    let newExpiresAt: String
}
