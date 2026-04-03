//
//  HomeView.swift
//  TimeMark
//
//  Created by cuong on 26/3/26.
//

import SwiftUI
import LocalAuthentication
import CoreLocation

struct HomeView: View {

    // MARK: - State
    @AppStorage("userName") var userName = "Trần Phi Cường"
    @State private var currentTime = Date()
    @State private var checkInTime: Date? = nil
    @State private var checkOutTime: Date? = nil
    @State private var isCheckedIn = false
    @State private var isCheckedOut = false
    @State private var showCheckInConfirm = false
    @State private var showCheckOutConfirm = false
    @State private var showFaceIDFailed = false
    @State private var isWithinRange = false
    @State private var distanceText = "Đang xác định vị trí..."
    @State private var remainingLeaveDays = 12

    @StateObject private var locationManager = LocationManager()

    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    let workStart = "08:00"
    let workEnd = "17:00"

    // MARK: - Body
    var body: some View {
        NavigationStack {
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
                    Spacer(minLength: 30)
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)
            }
            .background(Color(.systemGray6).ignoresSafeArea())
            .onReceive(timer) { _ in
                currentTime = Date()
            }
            .onReceive(locationManager.$distance) { distance in
                if let distance = distance {
                    isWithinRange = distance <= Double(locationManager.officeRadius)
                    if isWithinRange {
                        distanceText = "Trong phạm vi văn phòng (\(Int(distance))m)"
                    } else {
                        distanceText = "Ngoài phạm vi — cách \(Int(distance))m"
                    }
                } else {
                    distanceText = "Đang xác định vị trí..."
                }
            }
            .alert("Face ID thất bại", isPresented: $showFaceIDFailed) {
                Button("OK", role: .cancel) {}
            } message: {
                Text("Không thể xác minh danh tính. Vui lòng thử lại.")
            }
            .alert("Xác nhận check-in", isPresented: $showCheckInConfirm) {
                Button("Huỷ", role: .cancel) {}
                Button("Check-in") { authenticateAndCheckIn() }
            } message: {
                Text("Xác nhận check-in lúc \(formattedTime(Date())) bằng Face ID?")
            }
            .alert("Xác nhận check-out", isPresented: $showCheckOutConfirm) {
                Button("Huỷ", role: .cancel) {}
                Button("Check-out") { authenticateAndCheckOut() }
            } message: {
                Text("Xác nhận check-out lúc \(formattedTime(Date())) bằng Face ID?")
            }
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
                .fill(statusColor)
                .frame(width: 8, height: 8)
            Text(statusText)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(statusColor)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 6)
        .background(statusColor.opacity(0.1))
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

    // MARK: - Shift Info
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

    // MARK: - Check-in Card
    var checkInCard: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .fill(
                    LinearGradient(
                        colors: checkInGradient,
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )

            VStack(spacing: 14) {
                // GPS status
                HStack(spacing: 6) {
                    Image(systemName: isWithinRange ? "location.fill" : "location.slash.fill")
                        .font(.caption)
                    Text(distanceText)
                        .font(.caption)
                        .fontWeight(.medium)
                }
                .foregroundColor(.white)
                .padding(.horizontal, 14)
                .padding(.vertical, 6)
                .background(Color.black.opacity(0.2))
                .cornerRadius(20)

                // Face ID icon
                Image(systemName: isCheckedOut ? "checkmark.seal.fill" : "faceid")
                    .font(.system(size: 44))
                    .foregroundColor(.white.opacity(0.9))

                // Nút check-in / check-out
                Button(action: {
                    if !isCheckedIn && isWithinRange {
                        showCheckInConfirm = true
                    } else if isCheckedIn && !isCheckedOut && isWithinRange {
                        showCheckOutConfirm = true
                    }
                }) {
                    HStack(spacing: 8) {
                        Image(systemName: buttonIcon)
                            .font(.system(size: 16, weight: .bold))
                        Text(buttonTitle)
                            .font(.title3)
                            .fontWeight(.bold)
                    }
                    .foregroundColor(canCheckInOut ? .white : .white.opacity(0.4))
                }
                .disabled(!canCheckInOut)

                // Gợi ý
                if !isCheckedOut {
                    Text(isWithinRange ? "Xác thực Face ID để tiếp tục" : "Cần đến văn phòng để chấm công")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.75))
                }
            }
            .padding(.vertical, 28)
        }
        .frame(height: 240)
    }

    // MARK: - Giờ vào / Giờ ra
    var timeInfoCards: some View {
        HStack(spacing: 12) {
            timeCard(icon: "arrow.right.square.fill", iconColor: Color.purple.opacity(0.15), iconFg: .purple, title: "Giờ vào", value: checkInTime != nil ? formattedTime(checkInTime!) : "-:-")
            timeCard(icon: "arrow.left.square.fill", iconColor: Color.orange.opacity(0.15), iconFg: .orange, title: "Giờ ra", value: checkOutTime != nil ? formattedTime(checkOutTime!) : "-:-")
        }
    }

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
                Text(totalHoursText)
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
            NavigationLink(destination: LeaveRequestView()) {
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

    // MARK: - Face ID
    func authenticateAndCheckIn() {
        let context = LAContext()
        var error: NSError?
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics,
                                   localizedReason: "Xác nhận check-in bằng Face ID") { success, _ in
                DispatchQueue.main.async {
                    if success { doCheckIn() }
                    else { showFaceIDFailed = true }
                }
            }
        } else {
            // Simulator không có Face ID → check-in thẳng để test
            doCheckIn()
        }
    }

    func authenticateAndCheckOut() {
        let context = LAContext()
        var error: NSError?
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics,
                                   localizedReason: "Xác nhận check-out bằng Face ID") { success, _ in
                DispatchQueue.main.async {
                    if success { doCheckOut() }
                    else { showFaceIDFailed = true }
                }
            }
        } else {
            doCheckOut()
        }
    }

    func doCheckIn() { checkInTime = Date(); isCheckedIn = true }
    func doCheckOut() { checkOutTime = Date(); isCheckedOut = true }

    // MARK: - Computed
    var canCheckInOut: Bool { isWithinRange && !isCheckedOut }
    var statusText: String {
        if isCheckedOut { return "Đã về" }
        if isCheckedIn  { return "Đang làm việc" }
        return "Chưa check-in"
    }
    var statusColor: Color {
        if isCheckedOut { return .gray }
        if isCheckedIn  { return .green }
        return .red
    }
    var buttonTitle: String {
        if isCheckedOut { return "Đã hoàn thành" }
        if isCheckedIn  { return "CHECK-OUT" }
        return "CHECK-IN"
    }
    var buttonIcon: String {
        if isCheckedOut { return "checkmark.seal.fill" }
        if isCheckedIn  { return "arrow.left.square.fill" }
        return "faceid"
    }
    var checkInGradient: [Color] {
        if isCheckedOut  { return [.gray, .gray.opacity(0.7)] }
        if isCheckedIn   { return [.red, .orange] }
        if !isWithinRange { return [Color.gray.opacity(0.5), Color.gray.opacity(0.3)] }
        return [.green, Color(red: 0.0, green: 0.7, blue: 0.4)]
    }
    var totalHoursText: String {
        guard let inTime = checkInTime else { return "0h 00m" }
        let diff = Int((checkOutTime ?? Date()).timeIntervalSince(inTime))
        return "\(diff / 3600)h \(String(format: "%02d", (diff % 3600) / 60))m"
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

// MARK: - Location Manager
class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let manager = CLLocationManager()
    @Published var distance: Double? = nil

    // ← Đổi tọa độ này thành địa chỉ công ty thật
    let officeLatitude  = 10.7769
    let officeLongitude = 106.7009
    let officeRadius    = 100 // mét

    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.requestWhenInUseAuthorization()
        manager.startUpdatingLocation()
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let userLocation = locations.last else { return }
        let officeLocation = CLLocation(latitude: officeLatitude, longitude: officeLongitude)
        distance = userLocation.distance(from: officeLocation)
    }
}
