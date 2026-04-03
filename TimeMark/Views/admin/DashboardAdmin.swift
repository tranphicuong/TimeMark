import SwiftUI


struct DashboardView: View {
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Image(systemName: "square.grid.2x2.fill")
                    .foregroundColor(.blue)
                Text("TimeMark")
                    .font(.title3.bold())
                    .foregroundColor(.blue)
                Spacer()
                Image(systemName: "person.crop.circle.fill")
                    .resizable()
                    .frame(width: 40, height: 40)
                    .foregroundColor(.orange.opacity(0.8))
            }
            .padding(.horizontal)
            .padding(.top, 10)
            
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 25) {
                    // Welcome
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Xin chào, Admin!")
                            .font(.system(size: 26, weight: .bold))
                        Text("Thứ Hai, 24 Tháng 5, 2024")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding(.horizontal)
                    .padding(.top, 20)
                    
                    // Stats Grid
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 15) {
                        StatCard(title: "TỔNG NHÂN VIÊN", value: "124", subValue: "+2%", icon: "person.2.fill", color: .blue, isDark: true)
                        StatCard(title: "CÓ MẶT HÔM NAY", value: "112", subValue: "90%", icon: "checkmark.circle.fill", color: .green, isDark: false)
                        StatCard(title: "VẮNG MẶT", value: "8", subValue: "", icon: "person.fill.badge.minus", color: .red, isDark: false)
                        StatCard(title: "ĐI TRỄ", value: "4", subValue: "", icon: "clock.fill", color: .orange, isDark: false)
                    }
                    .padding(.horizontal)
                    
                    // Check-in List Section
                    VStack(alignment: .leading, spacing: 15) {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Đang có mặt")
                                    .font(.headline)
                                Text("Danh sách nhân viên đã check-in thành công")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            Spacer()
                            Button("Xem tất cả") { }
                                .font(.caption.bold())
                                .foregroundColor(.blue)
                        }
                        .padding(.horizontal)
                        
                        VStack(spacing: 12) {
                            CheckInRow(name: "Nguyễn Thu Hà", department: "Phòng Marketing", time: "08:15 AM", status: "CHECK-IN", image: "person.circle.fill")
                            CheckInRow(name: "Trần Minh Quân", department: "Phòng Kỹ thuật", time: "07:55 AM", status: "CHECK-IN", image: "person.circle.fill")
                            CheckInRow(name: "Lê Thị Mai", department: "Phòng Nhân sự", time: "08:22 AM", status: "CHECK-IN", image: "person.circle.fill")
                            CheckInRow(name: "Phạm Hoàng Nam", department: "Phòng Kinh doanh", time: "08:45 AM", status: "ĐI TRỄ", image: "person.circle.fill", isLate: true)
                        }
                        .padding(.horizontal)
                    }
                }
                .padding(.bottom, 20)
            }
        }
    }
}






