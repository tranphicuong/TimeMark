import SwiftUI

// MARK: - Model cho loại nghỉ phép
enum LeaveType: String, CaseIterable, Identifiable {
    case annual = "Nghỉ phép năm"
    case unpaid = "Nghỉ không lương"
    case sick = "Nghỉ ốm"
    
    var id: String { rawValue }
    var subtitle: String {
        switch self {
        case .annual: return "Trừ vào quỹ phép năm"
        case .unpaid: return "Dành cho việc cá nhân"
        case .sick:   return "Cần kèm theo giấy xác nhận"
        }
    }
    var icon: String {
        switch self {
        case .annual: return "calendar"
        case .unpaid: return "scissors"
        case .sick:   return "cross.case.fill"
        }
    }
}

struct LeaveRequestView: View {
    
    @State private var selectedLeaveType: LeaveType? = .annual
    @State private var startDate = Date()
    @State private var endDate = Date()
    @State private var reason = ""
    
    // Tính toán giả (có thể thay bằng logic thật sau)
    private var daysOff: Int {
        Calendar.current.dateComponents([.day], from: startDate, to: endDate).day ?? 0 + 1
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    
                    // MARK: - LOẠI NGHỈ
                    VStack(alignment: .leading, spacing: 12) {
                        Text("LOẠI NGHỈ")
                            .font(.headline)
                            .foregroundColor(.primary)
                            .padding(.horizontal)
                        
                        VStack(spacing: 8) {
                            ForEach(LeaveType.allCases) { type in
                                LeaveTypeRow(
                                    type: type,
                                    isSelected: selectedLeaveType == type
                                ) {
                                    selectedLeaveType = type
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                    
                    // MARK: - THỜI GIAN NGHỈ
                    VStack(alignment: .leading, spacing: 12) {
                        Text("THỜI GIAN NGHỈ")
                            .font(.headline)
                            .foregroundColor(.primary)
                            .padding(.horizontal)
                        
                        HStack(spacing: 16) {
                            DateCard(title: "Ngày bắt đầu", date: startDate, onChange: { startDate = $0 })
                            DateCard(title: "Ngày kết thúc", date: endDate, onChange: { endDate = $0 })
                        }
                        .padding(.horizontal)
                    }
                    
                    // MARK: - LÝ DO NGHỈ
                    VStack(alignment: .leading, spacing: 10) {
                        Text("LÝ DO NGHỈ")
                            .font(.headline)
                            .foregroundColor(.primary)
                            .padding(.horizontal)
                        
                        TextField("Nhập lý do chi tiết tại đây...", text: $reason, axis: .vertical)
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(16)
                            .padding(.horizontal)
                    }
                    
                    // MARK: - TÓM TẮT
                    VStack(spacing: 8) {
                        HStack {
                            Image(systemName: "info.circle.fill")
                                .foregroundColor(.blue)
                            Text("Số ngày nghỉ dự kiến:")
                                .font(.subheadline)
                            Spacer()
                            Text("\(daysOff) ngày")
                                .font(.headline)
                                .foregroundColor(.blue)
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(16)
                        .padding(.horizontal)
                        
                        Text("Phép năm còn lại sau khi nghỉ: 10 ngày")
                            .font(.footnote)
                            .foregroundColor(.secondary)
                            .padding(.horizontal)
                    }
                    
                    // MARK: - NÚT GỬI
                    Button {
                        print("Gửi đơn nghỉ phép - Loại: \(selectedLeaveType?.rawValue ?? "Chưa chọn")")
                        // TODO: Call API hoặc xử lý submit
                    } label: {
                        Text("Gửi yêu cầu")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(selectedLeaveType == nil ? Color.gray : Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(16)
                    }
                    .padding(.horizontal)
                    .disabled(selectedLeaveType == nil)
                    
                    Spacer(minLength: 40)
                }
                .padding(.top, 20)
            }
            .navigationTitle("Gửi đơn nghỉ phép")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

// MARK: - Row cho Loại nghỉ phép (có radio)
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
                    .frame(width: 32)
                
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
                    .font(.title2)
                    .foregroundColor(isSelected ? .blue : .gray)
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(16)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Date Card
struct DateCard: View {
    let title: String
    @State var date: Date
    let onChange: (Date) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
            
            HStack {
                Image(systemName: "calendar")
                    .foregroundColor(.blue)
                Text(date.formatted(date: .abbreviated, time: .omitted))
                    .font(.body)
                    .fontWeight(.semibold)
                Spacer()
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(16)
        }
        .onTapGesture {
            // TODO: Mở DatePicker sheet hoặc inline nếu muốn
            // Ví dụ đơn giản: hiện tại chỉ demo, mày có thể thay bằng DatePicker
        }
    }
}

#Preview {
    LeaveRequestView()
}
