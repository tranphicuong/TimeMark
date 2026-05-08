import SwiftUI

struct AdminSettingsView: View {
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    // Header Area
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Cài đặt")
                            .font(.system(size: 32, weight: .bold))
                        Text("Quản lý cấu hình hệ thống và tài khoản của bạn")
                            .font(.system(size: 16))
                            .foregroundColor(.gray)
                    }
                    .padding(.top, 20)
                    
                    // System Section
                    SectionHeader(title: "Hệ thống")
                    VStack(spacing: 0) {
                        NavigationLink(destination: ShiftSettingsView()) {
                            SettingRow(icon: "clock.fill", iconColor: .blue, iconBgColor: Color.blue.opacity(0.1), title: "Cài đặt ca làm việc")
                        }
                        Divider().padding(.leading, 70)
                        NavigationLink(destination: OrganizationManagementView()){
                            SettingRow(icon: "building.2.fill", iconColor: .indigo, iconBgColor: Color.indigo.opacity(0.1), title: "Quản lý phòng ban & Chức vụ")
                        }
                        Divider().padding(.leading, 70)
                        NavigationLink(destination: LeaveManagementView()){
                            SettingRow(icon: "calendar", iconColor: .orange, iconBgColor: Color.orange.opacity(0.1), title: "Chỉnh sửa ngày phép năm")
                        }
                        Divider().padding(.leading, 70)
                                                
                        // ← NÚT MỚI: Xuất báo cáo chấm công
                        NavigationLink(destination: PayrollExportView()) {
                            SettingRow(
                                icon: "doc.badge.arrow.up.fill",
                                iconColor: .green,
                                iconBgColor: Color.green.opacity(0.1),
                                title: "Xuất file chấm công tháng"
                            )
                        }
                    }
                    .background(Color.white)
                    .cornerRadius(16)
                    
                    // Personal Section
                    SectionHeader(title: "Cá nhân")
                    VStack(spacing: 0) {
                        NavigationLink(destination: ProfileAdminView()){
                            SettingRow(icon: "person.fill", iconColor: .gray, iconBgColor: Color.gray.opacity(0.1), title: "Hồ sơ cá nhân")
                        }
                        
                        Divider().padding(.leading, 70)
                       
                    }
                    .background(Color.white)
                    .cornerRadius(16)

                }
                .padding(.horizontal, 20)
                .padding(.bottom, 100) // Để không bị che bởi TabBar
            }
            .background(Color(uiColor: .systemGroupedBackground))
            .navigationBarHidden(true)
        }
    }
}
