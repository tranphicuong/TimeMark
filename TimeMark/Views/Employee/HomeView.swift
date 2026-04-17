


import SwiftUI

struct HomeView: View {

    @StateObject private var vm = HomeViewModel.shared
    @AppStorage("userName") var userName = "Nhân viên"

    @State private var currentTime = Date()
    @AppStorage("avatarURL") var avatarURL: String = ""
    @State private var remainingLeaveDays = 12

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

                // Toast
                if vm.showToast {
                    toastView
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                        .padding(.bottom, 20)
                }
            }
            .onReceive(timer) { _ in currentTime = Date() }
            // Sheet camera
            .sheet(isPresented: $vm.showCamera) {
                CameraView { image in
                    if let image = image {
                        vm.onImageCaptured(image)
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
                    Image(systemName: vm.locationService.isWithinRange
                          ? "location.fill" : "location.slash.fill")
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

                // Icon / Loading
                if vm.isLoading {
                    ProgressView()
                        .tint(.white)
                        .scaleEffect(1.5)
                        .frame(height: 50)
                } else {
                    Image(systemName: checkInIcon)
                        .font(.system(size: 50))
                        .foregroundColor(.white.opacity(0.9))
                }

                // Label
                Text(vm.isCheckedOut ? "Đã hoàn thành hôm nay" :
                     vm.isCheckedIn  ? "Nhấn để CHECK-OUT" :
                     vm.locationService.isWithinRange ? "Nhấn để CHECK-IN" : "Ngoài phạm vi văn phòng")
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(vm.isLoading ? .white.opacity(0.5) : .white)
                    .multilineTextAlignment(.center)

                // Gợi ý nhỏ
                if !vm.isCheckedOut && !vm.isLoading {
                    Text(vm.locationService.isWithinRange
                         ? (vm.isCheckedIn ? "Nhấn để check-out" : "Nhấn bất kỳ đâu để mở camera")
                         : "Di chuyển đến văn phòng để chấm công")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.75))
                        .multilineTextAlignment(.center)
                }
            }
            .padding(.vertical, 28)
            .padding(.horizontal, 16)
        }
        .frame(height: 250)
        // Toàn bộ card nhấn được
        .contentShape(Rectangle())
        .onTapGesture {
            handleCardTap()
        }
        .scaleEffect(vm.isLoading ? 1.0 : 1.0)
        .animation(.spring(response: 0.2), value: vm.isLoading)
    }

    // MARK: - Xử lý tap
    private func handleCardTap() {
        guard !vm.isLoading && !vm.isCheckedOut else { return }

        if !vm.isCheckedIn {
            vm.handleCheckInTap()
        } else {
            vm.handleCheckOutTap()
        }
    }

    // MARK: - Icon theo trạng thái
    var checkInIcon: String {
        if vm.isCheckedOut { return "checkmark.seal.fill" }
        if vm.isCheckedIn  { return "arrow.left.circle.fill" }
        if !vm.locationService.isWithinRange { return "location.slash.fill" }
        return "camera.fill"
    }

    // MARK: - Header
    var headerView: some View {
        HStack {
            HStack(spacing: 12) {
                ZStack {
                    AvatarView(
                        size: 46,
                        avatarURL: avatarURL
                    )
                }
                .onAppear {
                    UserService.shared.listenUser { url in
                        if let url = url {
                            avatarURL = url
                        }
                    }
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

    // MARK: - Ca làm
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

    // MARK: - Giờ vào / ra
    var timeInfoCards: some View {
        HStack(spacing: 12) {
            timeCard(icon: "arrow.right.square.fill", iconColor: Color.purple.opacity(0.15), iconFg: .purple,
                     title: "Giờ vào", value: vm.checkInTime != nil ? formattedTime(vm.checkInTime!) : "-:-")
            timeCard(icon: "arrow.left.square.fill", iconColor: Color.orange.opacity(0.15), iconFg: .orange,
                     title: "Giờ ra", value: vm.checkOutTime != nil ? formattedTime(vm.checkOutTime!) : "-:-")
        }
    }

    @ViewBuilder
    func timeCard(icon: String, iconColor: Color, iconFg: Color, title: String, value: String) -> some View {
        HStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 10).fill(iconColor).frame(width: 40, height: 40)
                Image(systemName: icon).foregroundColor(iconFg)
            }
            VStack(alignment: .leading, spacing: 2) {
                Text(title).font(.caption).foregroundColor(.gray)
                Text(value).font(.subheadline).fontWeight(.semibold)
            }
            Spacer()
        }
        .padding(14)
        .background(Color.white)
        .cornerRadius(14)
        .frame(maxWidth: .infinity)
    }

    // MARK: - Tổng giờ
    var totalHoursCard: some View {
        HStack(spacing: 14) {
            ZStack {
                Circle().fill(Color.blue).frame(width: 42, height: 42)
                Image(systemName: "clock.fill").foregroundColor(.white)
            }
            VStack(alignment: .leading, spacing: 2) {
                Text("Tổng giờ làm").font(.caption).foregroundColor(.white.opacity(0.8))
                Text(vm.totalHoursText).font(.title3).fontWeight(.bold).foregroundColor(.white)
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
                    RoundedRectangle(cornerRadius: 10).fill(Color.blue.opacity(0.1)).frame(width: 40, height: 40)
                    Image(systemName: "calendar.badge.clock").foregroundColor(.blue)
                }
                VStack(alignment: .leading, spacing: 2) {
                    Text("Phép năm còn lại").font(.caption).foregroundColor(.gray)
                    Text("\(remainingLeaveDays) ngày").font(.subheadline).fontWeight(.bold)
                }
            }
            Spacer()
            NavigationLink(destination: LeaveRequestView()) {
                HStack(spacing: 6) {
                    Image(systemName: "doc.text.fill").font(.caption)
                    Text("Gửi yêu cầu").font(.caption).fontWeight(.semibold)
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
                .multilineTextAlignment(.leading)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 14)
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.12), radius: 12, x: 0, y: 4)
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
