import SwiftUI

struct LeaveRequestView: View {
    @StateObject private var vm = LeaveRequestViewModel()
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
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
                }
                .padding(.top, 20)
            }
            .navigationTitle("Gửi đơn nghỉ phép")
            .navigationBarTitleDisplayMode(.inline)
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
        }
    }
}
