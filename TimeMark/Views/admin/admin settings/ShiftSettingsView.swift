import SwiftUI

struct ShiftSettingsView: View {
    @State private var startTime = "08:00 AM"
    @State private var endTime = "05:00 PM"
    @State private var lateLimit = "15"
    
    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Title Header
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Cấu hình hệ thống")
                            .font(.system(size: 24, weight: .bold))
                        Text("Thiết lập khung thời gian và quy định chấm công cho nhân viên.")
                            .font(.system(size: 14))
                            .foregroundColor(.gray)
                    }
                    .padding(.top, 20)
                    
                    // Working Time Card
                    VStack(alignment: .leading, spacing: 16) {
                        HStack(spacing: 12) {
                            ZStack {
                                Circle().fill(Color.blue.opacity(0.1)).frame(width: 32, height: 32)
                                Image(systemName: "clock.fill").foregroundColor(.blue).font(.system(size: 14))
                            }
                            Text("Thời gian làm việc").font(.system(size: 16, weight: .bold))
                        }
                        
                        HStack(spacing: 12) {
                            TimePickerField(label: "GIỜ BẮT ĐẦU", time: $startTime)
                            TimePickerField(label: "GIỜ KẾT THÚC", time: $endTime)
                        }
                    }
                    .padding(20)
                    .background(Color.white)
                    .cornerRadius(20)
                    
                    // Late Rule Card
                    VStack(alignment: .leading, spacing: 16) {
                        HStack(spacing: 12) {
                            ZStack {
                                Circle().fill(Color.orange.opacity(0.1)).frame(width: 32, height: 32)
                                Image(systemName: "bell.fill").foregroundColor(.orange).font(.system(size: 14))
                            }
                            Text("Quy tắc đi trễ").font(.system(size: 16, weight: .bold))
                        }
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("CHO PHÉP TRỄ TỐI ĐA (PHÚT)")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(.gray)
                            
                            HStack {
                                TextField("", text: $lateLimit)
                                    .keyboardType(.numberPad)
                                    .font(.system(size: 18, weight: .bold))
                                    .foregroundColor(.blue)
                                    .padding(.horizontal, 16)
                                    .frame(width: 80, height: 44)
                                    .background(Color.gray.opacity(0.1))
                                    .cornerRadius(8)
                                
                                Text("phút")
                                    .foregroundColor(.gray)
                            }
                        }
                        
                        HStack(alignment: .top, spacing: 12) {
                            Image(systemName: "info.circle.fill")
                                .foregroundColor(.gray)
                            Text("Nhân viên check-in sau thời gian này sẽ bị đánh dấu là **Đi trễ** trong hệ thống báo cáo.")
                                .font(.system(size: 13))
                                .foregroundColor(.gray)
                        }
                        .padding(12)
                        .background(Color.gray.opacity(0.05))
                        .cornerRadius(12)
                    }
                    .padding(20)
                    .background(Color.white)
                    .cornerRadius(20)
                    
                    // Save Button
                    Button(action: {}) {
                        HStack {
                            Image(systemName: "tray.and.arrow.down") // Hoặc icon ổ đĩa
                            Text("Lưu cài đặt")
                                .fontWeight(.bold)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(25)
                    }
                    .padding(.top, 20)
                }
                .padding(.horizontal, 20)
            }
            .background(Color(uiColor: .systemGroupedBackground))
            
            .padding(.top, 10)
            .padding(.bottom, 20)
            .background(Color.white)
        }
        .navigationBarTitle("Cài đặt ca làm việc", displayMode: .inline)
    }
}
struct TabItem: View {
    let icon: String
    let title: String
    let isSelected: Bool
    
    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 20))
            Text(title)
                .font(.system(size: 10))
        }
        .frame(maxWidth: .infinity)
        .foregroundColor(isSelected ? .blue : .gray)
    }
}

