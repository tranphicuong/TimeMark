//
//  PayrollExportView.swift
//  TimeMark
//
//  Created by Rebel on 5/8/26.
//

// Views/PayrollExportView.swift

import SwiftUI

struct PayrollExportView: View {
    @StateObject private var vm = PayrollViewModel()
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(uiColor: .systemGroupedBackground).ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        
                        // ─ Header Card ──────────────────────
                        headerCard
                        
                        // ─ Chọn tháng/năm ──────────────────
                        pickerCard
                        
                        // ─ Ghi chú nội dung file ───────────
                        infoCard
                        
                        // ─ Nút xuất ────────────────────────
                        exportButton
                        
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 16)
                    .padding(.bottom, 40)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { dismiss() }) {
                        HStack(spacing: 4) {
                            Image(systemName: "chevron.left")
                                .fontWeight(.semibold)
                            Text("Quay lại")
                        }
                        .foregroundColor(.blue)
                    }
                }
                ToolbarItem(placement: .principal) {
                    Text("Xuất báo cáo")
                        .font(.headline)
                }
            }
            // Ẩn TabBar khi vào màn này
            .toolbar(.hidden, for: .tabBar)
            .alert("Lỗi", isPresented: $vm.showError) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(vm.errorMessage ?? "Đã xảy ra lỗi")
            }
            .sheet(isPresented: $vm.showShareSheet) {
                if let url = vm.exportedURL {
                    ShareSheet(url: url)
                }
            }
        }
    }
    
    // ─────────────────────────────────────────
    // MARK: Sub Views
    // ─────────────────────────────────────────
    
    private var headerCard: some View {
        HStack(spacing: 16) {
            ZStack {
                RoundedRectangle(cornerRadius: 14)
                    .fill(
                        LinearGradient(
                            colors: [Color(hex: "2E5090"), Color(hex: "4472C4")],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 56, height: 56)
                Image(systemName: "doc.badge.arrow.up.fill")
                    .font(.system(size: 24))
                    .foregroundColor(.white)
            }
            VStack(alignment: .leading, spacing: 4) {
                Text("Báo cáo chấm công")
                    .font(.system(size: 18, weight: .bold))
                Text("Xuất file Excel gửi kế toán tính lương")
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
            }
            Spacer()
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
    }
    
    private var pickerCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            Label("Chọn kỳ báo cáo", systemImage: "calendar")
                .font(.system(size: 15, weight: .semibold))
            
            HStack(spacing: 12) {
                // Tháng
                VStack(alignment: .leading, spacing: 6) {
                    Text("Tháng")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Menu {
                        ForEach(vm.months, id: \.0) { m in
                            Button(m.1) { vm.selectedMonth = m.0 }
                        }
                    } label: {
                        HStack {
                            Text(vm.monthName)
                                .font(.system(size: 15, weight: .medium))
                                .foregroundColor(.primary)
                            Spacer()
                            Image(systemName: "chevron.up.chevron.down")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .padding(.horizontal, 14)
                        .padding(.vertical, 12)
                        .background(Color(uiColor: .systemGray6))
                        .cornerRadius(10)
                    }
                }
                
                // Năm
                VStack(alignment: .leading, spacing: 6) {
                    Text("Năm")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Menu {
                        ForEach(vm.years, id: \.self) { y in
                            Button(String(y)) { vm.selectedYear = y }
                        }
                    } label: {
                        HStack {
                            Text(String(vm.selectedYear))
                                .font(.system(size: 15, weight: .medium))
                                .foregroundColor(.primary)
                            Spacer()
                            Image(systemName: "chevron.up.chevron.down")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .padding(.horizontal, 14)
                        .padding(.vertical, 12)
                        .background(Color(uiColor: .systemGray6))
                        .cornerRadius(10)
                    }
                }
            }
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
    }
    
    private var infoCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("File sẽ bao gồm", systemImage: "list.bullet.clipboard")
                .font(.system(size: 15, weight: .semibold))
            
            VStack(spacing: 10) {
                PayrollInfoRow(icon: "tablecells.fill",        color: .blue,   text: "Sheet tổng hợp toàn công ty")
                PayrollInfoRow(icon: "person.text.rectangle",  color: .indigo, text: "Sheet chi tiết từng nhân sự")
                PayrollInfoRow(icon: "checkmark.seal.fill",    color: .green,  text: "Ngày công & phép năm có lương")
                PayrollInfoRow(icon: "xmark.seal.fill",        color: .orange, text: "Phép không lương & ngày vắng")
                PayrollInfoRow(icon: "timer",                  color: .purple, text: "Giờ tăng ca (sau hành chính + 1h)")
                PayrollInfoRow(icon: "clock.badge.exclamationmark", color: .red, text: "Số phút đi trễ")
            }
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
    }
    
    private var exportButton: some View {
        Button(action: vm.exportPayroll) {
            HStack(spacing: 10) {
                if vm.isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(0.9)
                } else {
                    Image(systemName: "arrow.down.doc.fill")
                        .font(.system(size: 16, weight: .semibold))
                }
                Text(vm.exportButtonTitle)
                    .font(.system(size: 16, weight: .semibold))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                Group {
                    if vm.isLoading {
                        Color.gray
                    } else {
                        LinearGradient(
                            colors: [Color(hex: "2E5090"), Color(hex: "4472C4")],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    }
                }
            )
            .foregroundColor(.white)
            .cornerRadius(14)
            .shadow(
                color: Color(hex: "2E5090").opacity(vm.isLoading ? 0 : 0.3),
                radius: 8, x: 0, y: 4
            )
        }
        .disabled(vm.isLoading)
        .animation(.easeInOut(duration: 0.2), value: vm.isLoading)
    }
}

// ─────────────────────────────────────────────
// MARK: Supporting Views
// ─────────────────────────────────────────────

struct PayrollInfoRow: View {
    let icon: String
    let color: Color
    let text: String
    
    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .foregroundColor(color)
                .frame(width: 22)
            Text(text)
                .font(.system(size: 14))
                .foregroundColor(.secondary)
            Spacer()
        }
    }
}

struct ShareSheet: UIViewControllerRepresentable {
    let url: URL
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: [url], applicationActivities: nil)
    }
    func updateUIViewController(_ vc: UIActivityViewController, context: Context) {}
}

// ─────────────────────────────────────────────
// MARK: Color Hex Extension (nếu chưa có)
// ─────────────────────────────────────────────

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let r = Double((int >> 16) & 0xFF) / 255
        let g = Double((int >>  8) & 0xFF) / 255
        let b = Double( int        & 0xFF) / 255
        self.init(red: r, green: g, blue: b)
    }
}

#Preview {
    PayrollExportView()
}
