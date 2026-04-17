import SwiftUI

struct HistoryView: View {
    
    @StateObject private var vm = HistoryViewModel.shared
    @State private var selectedDate = Date()
    @State private var showMonthPicker = false
    
    private var currentMonthString: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "vi_VN")
        formatter.dateFormat = "MMMM, yyyy"
        return formatter.string(from: selectedDate).uppercased()
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    
                    Button {
                        showMonthPicker = true
                    } label: {
                        HStack {
                            Text(currentMonthString)
                                .font(.headline)
                                .fontWeight(.semibold)
                            Spacer()
                            Image(systemName: "calendar")
                                .foregroundColor(.blue)
                        }
                        .padding()
                        .background(Color.white)
                        .cornerRadius(16)
                        .shadow(color: .black.opacity(0.06), radius: 8)
                    }
                    .padding(.horizontal)
                    
                    totalHoursCard
                    
                    LazyVGrid(columns: [GridItem(), GridItem()], spacing: 12) {
                        statCard(color: .green,  title: "ĐI LÀM",   value: "\(vm.workDays)", sub: "Ngày công")
                        statCard(color: .orange, title: "TRỄ",      value: "\(vm.lateCount)", sub: "Lần")
                        statCard(color: .red,    title: "VẮNG",     value: "\(vm.absentCount)", sub: "Ngày")
                      
                    }
                    .padding(.horizontal)
                    
                    Text("Chi tiết từng ngày")
                        .font(.headline)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal)
                    
                    if vm.isLoading {
                        ProgressView().padding(.top, 50)
                    } else if vm.attendanceRecords.isEmpty {
                        Text("Chưa có dữ liệu chấm công trong tháng này")
                            .foregroundColor(.gray)
                            .padding(.top, 50)
                    } else {
                        VStack(spacing: 12) {
                            ForEach(vm.attendanceRecords) { record in
                                historyItem(record: record)
                            }
                        }
                        .padding(.horizontal)
                    }
                    
                    Spacer(minLength: 30)
                }
                .padding(.top, 8)
            }
            .background(Color(.systemGray6).ignoresSafeArea())
            .navigationTitle("Lịch sử chấm công")
            .navigationBarTitleDisplayMode(.large)
            .onAppear {
                loadCurrentMonth()
            }
            .sheet(isPresented: $showMonthPicker) {
                VStack {
                    Text("Chọn tháng")
                        .font(.title2).bold()
                        .padding(.top)
                    
                    DatePicker("", selection: $selectedDate, displayedComponents: .date)
                        .datePickerStyle(.graphical)
                        .padding()
                    
                    Button("Xong") {
                        showMonthPicker = false
                        loadCurrentMonth()
                    }
                    .font(.headline)
                    .foregroundColor(.blue)
                    .padding(.bottom, 30)
                }
                .presentationDetents([.medium])
            }
        }
    }
    
    private func loadCurrentMonth() {
        let calendar = Calendar.current
        let year = calendar.component(.year, from: selectedDate)
        let month = calendar.component(.month, from: selectedDate)
        vm.loadHistory(year: year, month: month)
    }
    
  
    
    // MARK: - Components
    var totalHoursCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("TỔNG GIỜ LÀM VIỆC")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.85))
                Spacer()
                Image(systemName: "timer").foregroundColor(.white.opacity(0.85))
            }
            Text(String(format: "%.1f giờ", vm.totalHours))
                .font(.system(size: 42, weight: .bold))
                .foregroundColor(.white)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            LinearGradient(colors: [.blue, .indigo], startPoint: .topLeading, endPoint: .bottomTrailing)
        )
        .cornerRadius(20)
        .padding(.horizontal)
    }
    
    @ViewBuilder
    func statCard(color: Color, title: String, value: String, sub: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 6) {
                Circle().fill(color).frame(width: 8, height: 8)
                Text(title).font(.caption).foregroundColor(.gray)
            }
            Text(value).font(.title2).bold()
            Text(sub).font(.caption).foregroundColor(.gray)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white)
        .cornerRadius(16)
    }
    
    @ViewBuilder
    func historyItem(record: AttendanceRecord) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(record.date)
                    .font(.headline)
                Spacer()
                Text(record.status ?? "Đúng giờ")
                    .font(.caption)
                    .fontWeight(.medium)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background((record.status ?? "").lowercased().contains("trễ") ? Color.orange.opacity(0.15) : Color.green.opacity(0.15))
                    .foregroundColor((record.status ?? "").lowercased().contains("trễ") ? .orange : .green)
                    .cornerRadius(20)
            }
            
            Divider()
            
            HStack {
                VStack(spacing: 2) {
                    Text("VÀO").font(.caption).foregroundColor(.gray)
                    Text(record.checkIn?.formatted(.dateTime.hour().minute()) ?? "--:--")
                        .fontWeight(.semibold)
                }
                Spacer()
                VStack(spacing: 2) {
                    Text("RA").font(.caption).foregroundColor(.gray)
                    Text(record.checkOut?.formatted(.dateTime.hour().minute()) ?? "--:--")
                        .fontWeight(.semibold)
                }
                Spacer()
                VStack(spacing: 2) {
                    Text("TỔNG").font(.caption).foregroundColor(.gray)
                    Text(record.totalHours)
                        .fontWeight(.semibold)
                        .foregroundColor(.blue)
                }
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(20)
        .shadow(color: .black.opacity(0.06), radius: 8)
    }
}
