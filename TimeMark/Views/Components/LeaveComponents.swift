import SwiftUI

// MARK: - Enum
enum LeaveType: String, CaseIterable, Identifiable {
    case annual = "Nghỉ phép năm"
    case unpaid = "Nghỉ không lương"

    
    var id: String { rawValue }
    
    var subtitle: String {
        switch self {
        case .annual: return "Trừ vào số ngày phép năm"
        case .unpaid: return "Không trừ ngày phép"

        }
    }
    
    var icon: String {
        switch self {
        case .annual: return "calendar"
        case .unpaid: return "scissors"
        }
    }
}

// MARK: - Components
struct LeaveTypeSection: View {
    @Binding var selectedType: LeaveType?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("LOẠI NGHỈ PHÉP")
                .font(.headline)
                .padding(.horizontal)
            
            VStack(spacing: 10) {
                ForEach(LeaveType.allCases) { type in
                    LeaveTypeRow(type: type, isSelected: selectedType == type) {
                        selectedType = type
                    }
                }
            }
            .padding(.horizontal)
        }
    }
}

struct LeaveTypeRow: View {
    let type: LeaveType
    let isSelected: Bool
    let onSelect: () -> Void
    
    var body: some View {
        Button(action: onSelect) {
            HStack(spacing: 16) {
                Image(systemName: type.icon)
                    .font(.title2)
                    .foregroundColor(isSelected ? .blue : .gray)
                    .frame(width: 36)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(type.rawValue)
                        .font(.body)
                        .fontWeight(.medium)
                    Text(type.subtitle)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(isSelected ? .blue : .gray)
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(16)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Date Section
struct DateSection: View {
    @Binding var startDate: Date
    @Binding var endDate: Date
    @ObservedObject var vm: LeaveRequestViewModel
    
    @State private var showStartPicker = false
    @State private var showEndPicker = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("THỜI GIAN NGHỈ")
                .font(.headline)
                .padding(.horizontal)
            
            HStack(spacing: 12) {
                DateCard(title: "Từ ngày", date: startDate) { showStartPicker = true }
                DateCard(title: "Đến ngày", date: endDate) { showEndPicker = true }
            }
            .padding(.horizontal)
            
            HStack {
                Text("Số ngày nghỉ:")
                Text("\(vm.daysOff) ngày")
                    .font(.headline)
                Spacer()
                Text("Còn lại: \(vm.remainingLeaveDays) ngày")
                    .foregroundColor(vm.daysOff > vm.remainingLeaveDays ? .red : .green)
                    .fontWeight(.semibold)
            }
            .padding(.horizontal)
        }
        .sheet(isPresented: $showStartPicker) {
            DatePickerSheet(selectedDate: $startDate, title: "Ngày bắt đầu")
        }
        .sheet(isPresented: $showEndPicker) {
            DatePickerSheet(selectedDate: $endDate, title: "Ngày kết thúc", minimumDate: startDate)
        }
    }
}

struct DateCard: View {
    let title: String
    let date: Date
    let onTap: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
            
            HStack {
                Image(systemName: "calendar")
                Text(date.formatted(date: .abbreviated, time: .omitted))
                    .font(.subheadline)
                    .fontWeight(.semibold)
                Spacer()
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(16)
        }
        .onTapGesture(perform: onTap)
    }
}

// MARK: - DatePicker Sheet (ĐÃ SỬA - TỰ ĐÓNG KHI ẤN XONG)
struct DatePickerSheet: View {
    @Binding var selectedDate: Date
    let title: String
    var minimumDate: Date? = nil
    
    @Environment(\.dismiss) private var dismiss  // Quan trọng
    
    var body: some View {
        NavigationStack {
            DatePicker(
                "",
                selection: $selectedDate,
                in: (minimumDate ?? Calendar.current.startOfDay(for: Date()))...,
                displayedComponents: [.date]
            )
            .datePickerStyle(.graphical)
            .padding()
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Xong") {
                        dismiss()   // Tự động đóng sheet
                    }
                }
            }
        }
    }
}

struct ReasonSection: View {
    @Binding var reason: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("LÝ DO NGHỈ")
                .font(.headline)
                .padding(.horizontal)
            
            TextField("Nhập lý do chi tiết...", text: $reason, axis: .vertical)
                .frame(height: 100, alignment: .top)
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(16)
                .padding(.horizontal)
        }
    }
}

struct SummarySection: View {
    @ObservedObject var vm: LeaveRequestViewModel
    
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: "info.circle.fill").foregroundColor(.blue)
                Text("Số ngày nghỉ dự kiến:")
                Spacer()
                Text("\(vm.daysOff) ngày")
                    .font(.headline)
                    .foregroundColor(.blue)
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(16)
            .padding(.horizontal)
            
            HStack {
                Image(systemName: "calendar.badge.clock").foregroundColor(.green)
                Text("Phép năm còn lại:")
                Spacer()
                Text("\(vm.remainingLeaveDays) ngày")
                    .font(.headline)
                    .foregroundColor(.green)
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(16)
            .padding(.horizontal)
        }
    }
}
