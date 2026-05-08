// DashboardView.swift
import SwiftUI

struct DashboardView: View {
    @StateObject private var vm = DashboardViewModel()
    @State private var expandedId: String? = nil
    @StateObject private var authVM = AuthViewModel.shared
    @State private var avatarURL: String = ""
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Image(systemName: "square.grid.2x2.fill").foregroundColor(.blue)
                Text("TimeMark").font(.title3.bold()).foregroundColor(.blue)
                Spacer()
                
                // Avatar
                if avatarURL.isEmpty {
                    Image(systemName: "person.crop.circle.fill")
                        .resizable()
                        .frame(width: 40, height: 40)
                        .foregroundColor(.orange.opacity(0.8))
                } else {
                    AsyncImage(url: URL(string: avatarURL)) { phase in
                        switch phase {
                        case .success(let img):
                            img.resizable()
                                .scaledToFill()
                                .frame(width: 40, height: 40)
                                .clipShape(Circle())
                        case .failure(_), .empty:
                            Image(systemName: "person.crop.circle.fill")
                                .resizable()
                                .frame(width: 40, height: 40)
                                .foregroundColor(.orange.opacity(0.8))
                        @unknown default:
                            EmptyView()
                        }
                    }
                }
            }
            .padding(.horizontal)
            .padding(.top, 10)

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 25) {

                    // Welcome
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Xin chào, \(authVM.userName.isEmpty ? "Admin" : authVM.userName.lastTwoWords)!")
                            .font(.system(size: 26, weight: .bold))
                        Text(Date(), style: .date)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding(.horizontal)
                    .padding(.top, 20)

                    // Stats Grid
                    if let s = vm.summary {
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 15) {
                            StatCard(title: "TỔNG NHÂN VIÊN", value: "\(s.total_active)", subValue: "", icon: "person.2.fill", color: .blue, isDark: true)
                            StatCard(title: "CÓ MẶT HÔM NAY", value: "\(s.total_present)", subValue: "\(s.total_active > 0 ? s.total_present * 100 / s.total_active : 0)%", icon: "checkmark.circle.fill", color: .green, isDark: false)
                            StatCard(title: "VẮNG MẶT", value: "\(s.total_absent)", subValue: "", icon: "person.fill.badge.minus", color: .red, isDark: false)
                            StatCard(title: "ĐI TRỄ", value: "\(s.total_late)", subValue: "", icon: "clock.fill", color: .orange, isDark: false)
                        }
                        .padding(.horizontal)
                    }

                    // Danh sách check-in
                    VStack(alignment: .leading, spacing: 15) {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Đang có mặt").font(.headline)
                                Text("Danh sách nhân viên đã check-in thành công")
                                    .font(.caption).foregroundColor(.secondary)
                            }
                            Spacer()
                        }
                        .padding(.horizontal)

                        if vm.isLoading {
                            ProgressView().frame(maxWidth: .infinity)
                        }
                        if vm.attendanceList.isEmpty {
                            VStack(spacing: 12) {
                                Image(systemName: "person.slash.fill")
                                    .font(.system(size: 40))
                                    .foregroundColor(.gray.opacity(0.5))
                                Text("Chưa có nhân viên check-in hôm nay")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.top, 20)
                            .padding(.bottom, 20)
                        }
                        else {
                            VStack(spacing: 12) {
                                ForEach(vm.attendanceList) { record in
                                    CheckInRow(
                                        record: record,
                                        isExpanded: expandedId == record.id
                                    ) {
                                        withAnimation {
                                            expandedId = expandedId == record.id ? nil : record.id
                                        }
                                    }
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                }
                .padding(.bottom, 20)
            }
        }
        .onAppear {
            vm.load()
            UserService.shared.loadAvatar { url in
                avatarURL = url
            }
        }
    }
}
