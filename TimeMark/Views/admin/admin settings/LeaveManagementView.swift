import SwiftUI
struct EmployeeColor: Identifiable {
    let id = UUID()
    let name: String
    let code: String
    let department: String
    let leaveDays: Int
    let remainingDays: String
    let avatarColor: Color
}
struct LeaveManagementView: View {
    @State private var defaultDays = "12"
    @State private var searchText = ""
    
    let employees = [
        EmployeeColor(name: "Nguyễn Văn Lam", code: "HR-001", department: "P. Nhân sự", leaveDays: 12, remainingDays: "04 ngày", avatarColor: .blue),
        EmployeeColor(name: "Trần Minh Phương", code: "IT-042", department: "P. Kỹ thuật", leaveDays: 14, remainingDays: "08 ngày", avatarColor: .orange),
        EmployeeColor(name: "Lê Thị Dung", code: "MK-015", department: "P. Marketing", leaveDays: 12, remainingDays: "02 ngày", avatarColor: .indigo),
        EmployeeColor(name: "Phạm Hoàng Anh", code: "SL-088", department: "P. Kinh doanh", leaveDays: 15, remainingDays: "12 ngày", avatarColor: .gray)
    ]
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Default Settings Card
                VStack(alignment: .leading, spacing: 16) {
                    Text("Thiết lập mặc định")
                        .font(.system(size: 18, weight: .bold))
                    Text("Áp dụng số ngày phép tiêu chuẩn cho toàn bộ nhân viên trong hệ thống.")
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Số ngày phép / năm")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.gray)
                        TextField("", text: $defaultDays)
                            .font(.system(size: 16, weight: .bold))
                            .padding()
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(10)
                    }
                    
                    Button(action: {}) {
                        Text("Áp dụng cho tất cả")
                            .fontWeight(.bold)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(25)
                    }
                }
                .padding(20)
                .background(Color.white)
                .cornerRadius(20)
                
                // Info Box
                HStack(alignment: .top, spacing: 12) {
                    Image(systemName: "info.circle.fill")
                        .foregroundColor(.white)
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Lưu ý quan trọng")
                            .font(.system(size: 16, weight: .bold))
                        Text("Việc thay đổi mặc định sẽ không ghi đè lên các thiết lập riêng lẻ đã được chỉnh sửa thủ công phía dưới.")
                            .font(.system(size: 13))
                    }
                    .foregroundColor(.white)
                }
                .padding(20)
                .background(Color.blue.opacity(0.9))
                .cornerRadius(20)
                
                // Employee List Section
                VStack(alignment: .leading, spacing: 16) {
                    Text("Danh sách nhân viên")
                        .font(.system(size: 20, weight: .bold))
                    
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.gray)
                        TextField("Tìm tên nhân viên...", text: $searchText)
                    }
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(25)
                    
                    // Unsaved Changes Bar
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("THAY ĐỔI CHƯA LƯU")
                                .font(.system(size: 10, weight: .bold))
                                .foregroundColor(.gray)
                            Text("3 nhân viên đã được chỉnh sửa")
                                .font(.system(size: 13, weight: .medium))
                        }
                        Spacer()
                        Button("Hủy") {}.foregroundColor(.gray).font(.system(size: 14, weight: .bold))
                        Button(action: {}) {
                            Text("Lưu tất cả")
                                .font(.system(size: 14, weight: .bold))
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .clipShape(Capsule())
                        }
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(16)
                    .shadow(color: Color.black.opacity(0.05), radius: 5)
                    
                    VStack(spacing: 0) {
                        ForEach(employees) { emp in
                            EmployeeRow(employee: emp)
                            if emp.id != employees.last?.id {
                                Divider()
                            }
                        }
                    }
                }
            }
            .padding(20)
        }
        .background(Color(uiColor: .systemGroupedBackground))
        .navigationBarTitle("Chỉnh sửa ngày phép năm", displayMode: .inline)
    }
}
