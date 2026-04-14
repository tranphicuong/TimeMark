import SwiftUI

// MARK: - Shift Settings View
struct ShiftSettingsView: View {
    
    // ✅ DÙNG Date (không dùng String nữa)
    @State private var startDate = Date()
    @State private var endDate = Date()
    @State private var lateLimit = "15"
    
    @State private var showConfirm = false
    @State private var showError = false
    @State private var errorMessage = ""
    
    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    
                    // HEADER
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Cấu hình hệ thống")
                            .font(.system(size: 24, weight: .bold))
                        
                        Text("Thiết lập khung thời gian và quy định chấm công cho nhân viên.")
                            .font(.system(size: 14))
                            .foregroundColor(.gray)
                    }
                    .padding(.top, 20)
                    
                    // WORKING TIME
                    VStack(alignment: .leading, spacing: 16) {
                        HStack(spacing: 12) {
                            ZStack {
                                Circle()
                                    .fill(Color.blue.opacity(0.1))
                                    .frame(width: 32, height: 32)
                                
                                Image(systemName: "clock.fill")
                                    .foregroundColor(.blue)
                            }
                            
                            Text("Thời gian làm việc")
                                .font(.system(size: 16, weight: .bold))
                        }
                        
                        HStack(spacing: 12) {
                            CustomTimePickerField(
                                label: "GIỜ BẮT ĐẦU",
                                time: $startDate
                            )
                            
                            CustomTimePickerField(
                                label: "GIỜ KẾT THÚC",
                                time: $endDate
                            )
                        }
                    }
                    .padding(20)
                    .background(Color.white)
                    .cornerRadius(20)
                    
                    // LATE RULE
                    VStack(alignment: .leading, spacing: 16) {
                        HStack(spacing: 12) {
                            ZStack {
                                Circle()
                                    .fill(Color.orange.opacity(0.1))
                                    .frame(width: 32, height: 32)
                                
                                Image(systemName: "bell.fill")
                                    .foregroundColor(.orange)
                            }
                            
                            Text("Quy tắc đi trễ")
                                .font(.system(size: 16, weight: .bold))
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
                            
                            Text("Nhân viên check-in sau thời gian này sẽ bị đánh dấu là Đi trễ.")
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
                    
                    // SAVE BUTTON
                    Button(action: {
                        validate()
                    }) {
                        HStack {
                            Image(systemName: "tray.and.arrow.down")
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
        }
        .navigationBarTitle("Cài đặt ca làm việc", displayMode: .inline)
        
        // ❌ ERROR ALERT
        .alert("Lỗi", isPresented: $showError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(errorMessage)
        }
        
        // ✅ CONFIRM ALERT
        .alert("Xác nhận", isPresented: $showConfirm) {
            Button("Huỷ", role: .cancel) {}
            
            Button("Xác nhận") {
                print("Start:", formatTime(startDate))
                print("End:", formatTime(endDate))
                print("Late:", lateLimit)
            }
        } message: {
            Text("Bạn có chắc muốn lưu cài đặt này?")
        }
    }
    
    // MARK: - VALIDATE
    func validate() {
        if lateLimit.isEmpty {
            errorMessage = "Vui lòng nhập số phút cho phép trễ"
            showError = true
            return
        }
        
        if startDate >= endDate {
            errorMessage = "Giờ kết thúc phải lớn hơn giờ bắt đầu"
            showError = true
            return
        }
        
        showConfirm = true
    }
    
    // FORMAT TIME
    func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "hh:mm a"
        return formatter.string(from: date)
    }
}

/////////////////////////////////////////////////////

// MARK: - Time Picker Field
struct CustomTimePickerField: View {
    let label: String
    @Binding var time: Date
    
    @State private var showPicker = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            
            Text(label)
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(.gray)
            
            Button {
                withAnimation {
                    showPicker.toggle()
                }
            } label: {
                HStack {
                    Text(formatTime(time))
                        .foregroundColor(.black)
                    
                    Spacer()
                    
                    Image(systemName: "clock")
                        .foregroundColor(.blue)
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(12)
            }
            
            if showPicker {
                DatePicker(
                    "",
                    selection: $time,
                    displayedComponents: .hourAndMinute
                )
                .datePickerStyle(.wheel)
                .labelsHidden()
            }
        }
    }
    
    func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "hh:mm a"
        return formatter.string(from: date)
    }
}
