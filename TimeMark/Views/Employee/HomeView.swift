//
//  HomeView.swift
//  TimeMark
//
//  Created by cuong on 26/3/26.
//

import SwiftUI

struct HomeView: View {
    
    @StateObject private var vm = HomeViewModel.shared
    @AppStorage("userName") var userName = "Nhân viên"
    
    @State private var currentTime = Date()
    @State private var remainingLeaveDays = 12
    @State private var showCheckInConfirm = false
    @State private var showCheckOutConfirm = false
    @State private var showImagePicker = false
    
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    let workStart = "08:00"
    let workEnd   = "17:00"
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                
                ScrollView {
                    VStack(spacing: 16) {
                        headerView
                        statusBadge
                        clockView
                        shiftInfoView
                        checkInCard
                        timeInfoCards
                        totalHoursCard
                        leaveInfoCard
                        Spacer(minLength: 40)
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 8)
                }
                .background(Color(.systemGray6).ignoresSafeArea())
                
                // Toast thông báo
                if vm.showToast {
                    toastView
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                        .animation(.spring(), value: vm.showToast)
                        .padding(.bottom, 20)
                }
            }
            .onReceive(timer) { _ in currentTime = Date() }
            
            // Alert Check-in
            .alert("Xác nhận check-in", isPresented: $showCheckInConfirm) {
                Button("Huỷ", role: .cancel) {}
                Button("Chụp ảnh check-in") { showImagePicker = true }
            } message: {
                Text("Bạn đang trong văn phòng.\nHãy chụp ảnh để hoàn tất check-in.")
            }
            
            // Alert Check-out
            .alert("Xác nhận check-out", isPresented: $showCheckOutConfirm) {
                Button("Huỷ", role: .cancel) {}
                Button("Xác nhận") { vm.startCheckOut() }
            } message: {
                Text("Check-out lúc \(formattedTime(Date()))?")
            }
            
            // Sheet mở Camera
            .sheet(isPresented: $showImagePicker) {
                CameraView { image in
                    if let image = image {
                        let base64 = image.jpegData(compressionQuality: 0.7)?.base64EncodedString() ?? ""
                        vm.saveCheckInWithImage(imageBase64: base64)
                    }
                }
            }
        }
    }
    
    // MARK: - Check-in Card
    var checkInCard: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .fill(
                    LinearGradient(
                        colors: vm.checkInGradient,
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
            
            VStack(spacing: 14) {
                
                // GPS badge
                HStack(spacing: 6) {
                    Image(systemName: vm.locationService.isWithinRange ? "location.fill" : "location.slash.fill")
                        .font(.caption)
                    Text(vm.locationService.distanceText)
                        .font(.caption)
                        .fontWeight(.medium)
                }
                .foregroundColor(.white)
                .padding(.horizontal, 14)
                .padding(.vertical, 6)
                .background(Color.black.opacity(0.2))
                .cornerRadius(20)
                
                // Loading hoặc icon
                if vm.isLoading {
                    ProgressView()
                        .tint(.white)
                        .scaleEffect(1.5)
                        .frame(height: 44)
                } else {
                    Image(systemName: vm.buttonIcon)
                        .font(.system(size: 44))
                        .foregroundColor(.white.opacity(0.9))
                }
                
                // NÚT CHÍNH
                Button(action: {
                    handleCheckButtonTap()
                }) {
                    Text(vm.buttonTitle)
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.white.opacity(0.25))
                        .cornerRadius(25)
                }
                .disabled(vm.isLoading)
                
                // Hướng dẫn
                if !vm.isCheckedOut {
                    Text(vm.locationService.isWithinRange
                         ? "Nhấn để chụp ảnh check-in"
                         : "Cần đến văn phòng để chấm công")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.85))
                        .multilineTextAlignment(.center)
                }
            }
            .padding(.vertical, 28)
        }
        .frame(height: 240)
    }
    
    // MARK: - Xử lý nút Check-in
    private func handleCheckButtonTap() {
        if vm.locationService.authorizationStatus == .notDetermined {
            vm.locationService.requestLocationPermission()
        }
        else if !vm.locationService.isAuthorized {
            if let url = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(url)
            }
        }
        else if !vm.isCheckedIn {
            showCheckInConfirm = true
        } else if !vm.isCheckedOut {
            showCheckOutConfirm = true
        }
    }
    
    // MARK: - Header
    var headerView: some View {
        HStack {
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(Color.blue.opacity(0.15))
                        .frame(width: 46, height: 46)
                    Image(systemName: "person.fill")
                        .foregroundColor(.blue)
                        .font(.system(size: 20))
                }
                VStack(alignment: .leading, spacing: 2) {
                    Text("XIN CHÀO,")
                        .font(.caption)
                        .foregroundColor(.gray)
                    Text(userName)
                        .font(.headline)
                        .bold()
                }
            }
            Spacer()
        }
        .padding(.top, 8)
    }
    
    // MARK: - Status Badge
    var statusBadge: some View {
        HStack(spacing: 6) {
            Circle()
                .fill(vm.statusColor)
                .frame(width: 8, height: 8)
            Text(vm.statusText)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(vm.statusColor)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 6)
        .background(vm.statusColor.opacity(0.1))
        .cornerRadius(20)
    }
    
    // MARK: - Clock
    var clockView: some View {
        VStack(spacing: 4) {
            Text(formattedClock(currentTime))
                .font(.system(size: 64, weight: .bold, design: .rounded))
                .foregroundColor(.blue)
            Text(formattedDate(currentTime))
                .font(.subheadline)
                .foregroundColor(.gray)
        }
    }
    
    // MARK: - Ca làm việc
    var shiftInfoView: some View {
        VStack(spacing: 4) {
            Text("Ca làm việc hôm nay")
                .font(.caption)
                .foregroundColor(.gray)
            Text("\(workStart) - \(workEnd)")
                .font(.subheadline)
                .fontWeight(.semibold)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 10)
        .background(Color.white)
        .cornerRadius(12)
    }
    
    // MARK: - Giờ vào / Giờ ra
    var timeInfoCards: some View {
        HStack(spacing: 12) {
            timeCard(
                icon: "arrow.right.square.fill",
                iconColor: Color.purple.opacity(0.15),
                iconFg: .purple,
                title: "Giờ vào",
                value: vm.checkInTime != nil ? formattedTime(vm.checkInTime!) : "-:-"
            )
            timeCard(
                icon: "arrow.left.square.fill",
                iconColor: Color.orange.opacity(0.15),
                iconFg: .orange,
                title: "Giờ ra",
                value: vm.checkOutTime != nil ? formattedTime(vm.checkOutTime!) : "-:-"
            )
        }
    }
    
    @ViewBuilder
    func timeCard(icon: String, iconColor: Color, iconFg: Color, title: String, value: String) -> some View {
        HStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(iconColor)
                    .frame(width: 40, height: 40)
                Image(systemName: icon)
                    .foregroundColor(iconFg)
            }
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.caption)
                    .foregroundColor(.gray)
                Text(value)
                    .font(.subheadline)
                    .fontWeight(.semibold)
            }
            Spacer()
        }
        .padding(14)
        .background(Color.white)
        .cornerRadius(14)
        .frame(maxWidth: .infinity)
    }
    
    // MARK: - Tổng giờ làm
    var totalHoursCard: some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(Color.blue)
                    .frame(width: 42, height: 42)
                Image(systemName: "clock.fill")
                    .foregroundColor(.white)
            }
            VStack(alignment: .leading, spacing: 2) {
                Text("Tổng giờ làm")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.8))
                Text(vm.totalHoursText)
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
            }
            Spacer()
        }
        .padding(16)
        .background(Color.blue)
        .cornerRadius(16)
    }
    
    // MARK: - Phép năm
    var leaveInfoCard: some View {
        HStack(spacing: 12) {
            HStack(spacing: 10) {
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.blue.opacity(0.1))
                        .frame(width: 40, height: 40)
                    Image(systemName: "calendar.badge.clock")
                        .foregroundColor(.blue)
                }
                VStack(alignment: .leading, spacing: 2) {
                    Text("Phép năm còn lại")
                        .font(.caption)
                        .foregroundColor(.gray)
                    Text("\(remainingLeaveDays) ngày")
                        .font(.subheadline)
                        .fontWeight(.bold)
                }
            }
            Spacer()
            NavigationLink(destination:LeaveRequestView()) {
                HStack(spacing: 6) {
                    Image(systemName: "doc.text.fill")
                        .font(.caption)
                    Text("Gửi yêu cầu")
                        .font(.caption)
                        .fontWeight(.semibold)
                }
                .foregroundColor(.white)
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .background(Color.blue)
                .cornerRadius(12)
            }
        }
        .padding(14)
        .background(Color.white)
        .cornerRadius(14)
    }
    
    // MARK: - Toast
    var toastView: some View {
        HStack(spacing: 10) {
            Image(systemName: vm.toastSuccess ? "checkmark.circle.fill" : "xmark.circle.fill")
                .foregroundColor(vm.toastSuccess ? .green : .red)
            Text(vm.toastMessage)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(.primary)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 14)
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 4)
        .padding(.horizontal, 20)
    }
    
    // MARK: - Formatters
    func formattedClock(_ date: Date) -> String {
        let f = DateFormatter(); f.dateFormat = "HH:mm"; return f.string(from: date)
    }
    
    func formattedDate(_ date: Date) -> String {
        let f = DateFormatter()
        f.locale = Locale(identifier: "vi_VN")
        f.dateFormat = "EEEE, dd MMMM"
        return f.string(from: date).capitalized
    }
    
    func formattedTime(_ date: Date) -> String {
        let f = DateFormatter(); f.dateFormat = "HH:mm"; return f.string(from: date)
    }
}
