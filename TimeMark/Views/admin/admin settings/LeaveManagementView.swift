import SwiftUI

struct LeaveManagementView: View {
    @StateObject private var vm = LeaveManagementViewModel()
    @State private var searchText = ""
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
                        TextField("", text: $vm.defaultDays)
                            .font(.system(size: 16, weight: .bold))
                            .padding()
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(10)
                    }
                    
                    Button(action: {
                        vm.applyToAll()
                    }) {
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
                        TextField("Tìm id nhân viên...", text: $searchText)
                    }
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(25)
                    
                    
                    VStack(spacing: 0) {
                        ForEach(vm.employees) { emp in
                            EmployeeRow(employee: emp)

                            if emp.id != vm.employees.last?.id {
                                Divider()
                            }
                        }
                    }
                }
            }
            .padding(20)
        }
        .background(Color(uiColor: .systemGroupedBackground))
     
        .onAppear {
            vm.loadData()
        }
        .navigationBarTitle("Chỉnh sửa ngày phép năm", displayMode: .inline)
    }
}
