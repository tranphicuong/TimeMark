import SwiftUI

struct LeaveRequestView: View {
<<<<<<< HEAD
    @StateObject private var vm = LeaveRequestViewModel()
    
=======

    // MARK: - State
    @State private var leaveTypes: [LeaveTypeModel] = []
    @State private var selectedLeaveType: LeaveTypeModel?

    @State private var startDate = Date()
    @State private var endDate = Date()
    @State private var reason = ""

    // MARK: - Computed
    private var daysOff: Int {
        let days = Calendar.current.dateComponents(
            [.day],
            from: startDate,
            to: endDate
        ).day ?? 0

        return max(days + 1, 1)
    }

>>>>>>> tnd
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
<<<<<<< HEAD
                    LeaveTypeSection(selectedType: $vm.selectedLeaveType)
                    DateSection(startDate: $vm.startDate,
                               endDate: $vm.endDate,
                               vm: vm)
                    ReasonSection(reason: $vm.reason)
                    SummarySection(vm: vm)
                    
                    Button {
                        vm.submitLeaveRequest()
                    } label: {
                        ZStack {
                            Text("Gửi yêu cầu nghỉ phép")
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 18)
                                .background(vm.canSubmit && !vm.isLoading ? Color.blue : Color.gray)
                                .cornerRadius(16)
                            
                            if vm.isLoading {
                                ProgressView().tint(.white)
                            }
                        }
                    }
                    .padding(.horizontal)
                    .disabled(!vm.canSubmit || vm.isLoading)
=======

                    // MARK: - LEAVE TYPE
                    VStack(alignment: .leading, spacing: 12) {
                        Text("LOẠI NGHỈ")
                            .font(.headline)
                            .padding(.horizontal)

                        VStack(spacing: 8) {
                            ForEach(leaveTypes) { type in
                                LeaveTypeRow(
                                    type: type,
                                    isSelected: selectedLeaveType?.id == type.id
                                ) {
                                    selectedLeaveType = type
                                }
                            }
                        }
                        .padding(.horizontal)
                    }

                    // MARK: - DATE
                    VStack(alignment: .leading, spacing: 12) {
                        Text("THỜI GIAN NGHỈ")
                            .font(.headline)
                            .padding(.horizontal)

                        HStack(spacing: 16) {
                            DateCard(
                                title: "Ngày bắt đầu",
                                date: $startDate
                            )

                            DateCard(
                                title: "Ngày kết thúc",
                                date: $endDate
                            )
                        }
                        .padding(.horizontal)
                    }

                    // MARK: - REASON
                    VStack(alignment: .leading, spacing: 10) {
                        Text("LÝ DO NGHỈ")
                            .font(.headline)
                            .padding(.horizontal)

                        TextField(
                            "Nhập lý do chi tiết tại đây...",
                            text: $reason,
                            axis: .vertical
                        )
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(16)
                        .padding(.horizontal)
                    }

                    // MARK: - SUMMARY
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

                    // MARK: - SUBMIT
                    Button {
                        submitLeaveRequest()
                    } label: {
                        Text("Gửi yêu cầu")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(
                                selectedLeaveType == nil
                                ? Color.gray
                                : Color.blue
                            )
                            .foregroundColor(.white)
                            .cornerRadius(16)
                    }
                    .padding(.horizontal)
                    .disabled(selectedLeaveType == nil)

                    Spacer(minLength: 40)
>>>>>>> tnd
                }
                .padding(.top, 20)
            }
            .navigationTitle("Gửi đơn nghỉ phép")
            .navigationBarTitleDisplayMode(.inline)
<<<<<<< HEAD
            .alert("Lỗi", isPresented: $vm.showError) {
                Button("OK") {}
            } message: {
                Text(vm.errorMessage)
            }
            .alert("Thành công", isPresented: $vm.showSuccess) {
                Button("OK") {}
            } message: {
                Text("Đơn nghỉ phép đã được gửi thành công!")
            }
=======
        }
//        .onAppear {
//            fetchLeaveTypes()
//        }
    }

    // MARK: - Functions
//    private func fetchLeaveTypes() {
//        LeaveTypeService.shared.fetchLeaveTypes { types in
//            leaveTypes = types
//            selectedLeaveType = types.first
//        }
//    }
 
    private func submitLeaveRequest() {
        print("Loại nghỉ:", selectedLeaveType?.name ?? "")
        print("Từ:", startDate)
        print("Đến:", endDate)
        print("Lý do:", reason)
    }
}

// MARK: - Leave Type Row
struct LeaveTypeRow: View {
    let type: LeaveTypeModel
    let isSelected: Bool
    let onSelect: () -> Void

    var body: some View {
        Button(action: onSelect) {
            HStack(spacing: 16) {
                Image(systemName: "briefcase.fill")
                    .font(.title2)
                    .foregroundColor(isSelected ? .blue : .gray)
                    .frame(width: 32)

                VStack(alignment: .leading, spacing: 4) {
                    Text(type.name)
                        .font(.body)
                        .fontWeight(.medium)

                    Text(type.description ?? "")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Spacer()

                Image(systemName:
                    isSelected
                    ? "checkmark.circle.fill"
                    : "circle"
                )
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
    @Binding var date: Date

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)

            DatePicker(
                "",
                selection: $date,
                displayedComponents: .date
            )
            .labelsHidden()
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(16)
>>>>>>> tnd
        }
    }
}
