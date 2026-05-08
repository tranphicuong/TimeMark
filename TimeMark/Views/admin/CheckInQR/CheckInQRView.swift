//
//  CheckInQRView.swift
//  TimeMark
//
//  Created by Doanh on 5/6/26.
//

import SwiftUI

struct CheckInQRView: View {
    @StateObject private var viewModel = QRCheckinViewModel()
    @State private var showRefreshConfirm = false

    var body: some View {
        VStack(spacing: 24) {

            // ── Header ──────────────────────────────────────────
            VStack(spacing: 4) {
                Text("Check In")
                    .font(.largeTitle.bold())
                Text("Nhân viên quét mã để điểm danh")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            .padding(.top, 20)

            // ── QR Code ─────────────────────────────────────────
            ZStack {
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color(.systemBackground))
                    .shadow(color: .black.opacity(0.1), radius: 12, x: 0, y: 4)
                    .frame(width: 280, height: 280)

                if viewModel.isLoading {
                    ProgressView()
                        .scaleEffect(1.5)
                } else if let qrImage = viewModel.qrImage {
                    Image(uiImage: qrImage)
                        .interpolation(.none)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 240, height: 240)
                        .transition(.opacity.animation(.easeInOut(duration: 0.3)))
                        .id(viewModel.currentToken) // SwiftUI re-render khi token đổi
                } else {
                    VStack(spacing: 8) {
                        Image(systemName: "qrcode")
                            .font(.system(size: 60))
                            .foregroundColor(.secondary)
                        Text("Chưa có QR")
                            .foregroundColor(.secondary)
                    }
                }
            }
            .frame(width: 280, height: 280)

            // ── Thời gian hết hạn ────────────────────────────────
            if !viewModel.expiresAtFormatted.isEmpty {
                Label(viewModel.expiresAtFormatted, systemImage: "clock")
                    .font(.footnote)
                    .foregroundColor(.orange)
            }

            // ── Thông báo người vừa check in ────────────────────
            if let name = viewModel.lastCheckinName {
                HStack(spacing: 8) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                    Text("\(name) đã check in")
                        .font(.subheadline.bold())
                        .foregroundColor(.green)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(Color.green.opacity(0.1))
                .cornerRadius(10)
                .transition(.scale.combined(with: .opacity))
            }

            // ── Error ────────────────────────────────────────────
            if let error = viewModel.errorMessage {
                Text(error)
                    .font(.caption)
                    .foregroundColor(.red)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }

            Spacer()

            // ── Nút refresh thủ công ─────────────────────────────
            Button {
                showRefreshConfirm = true
            } label: {
                Label("Làm mới QR", systemImage: "arrow.clockwise")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(14)
                    .padding(.horizontal, 40)
            }
            .padding(.bottom, 30)
        }
        .background(Color(.systemGroupedBackground).ignoresSafeArea())
        .onAppear { viewModel.startPolling() }
        .onDisappear { viewModel.stopPolling() }
        .confirmationDialog(
            "Làm mới QR sẽ hủy mã hiện tại",
            isPresented: $showRefreshConfirm,
            titleVisibility: .visible
        ) {
            Button("Làm mới", role: .destructive) {
                viewModel.refreshQR()
            }
            Button("Hủy", role: .cancel) {}
        }
    }
}
