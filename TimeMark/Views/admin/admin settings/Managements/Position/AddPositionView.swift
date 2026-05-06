import SwiftUI

struct AddPositionView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var positionVM = PositionViewModel()

    @State private var name = ""
    @State private var description = ""
    @State private var showError = false

    var onSuccess: (() -> Void)? = nil

    var body: some View {
        NavigationView {
            Form {
                TextField("Tên chức danh", text: $name)
                TextField("Mô tả", text: $description)
            }
            .navigationTitle("Tạo chức danh")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Hủy") { dismiss() }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    if positionVM.isLoading {
                        ProgressView()
                    } else {
                        Button("Xác nhận") {
                            guard !name.trimmingCharacters(in: .whitespaces).isEmpty else {
                                positionVM.errorMessage = "Tên chức danh không được để trống"
                                showError = true
                                return
                            }
                            positionVM.createPosition(name: name, description: description) {
                                onSuccess?()
                                dismiss()
                            }
                        }
                    }
                }
            }
            .alert("Không thể tạo chức danh", isPresented: $showError) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(positionVM.errorMessage ?? "Lỗi không xác định")
            }
            .onChange(of: positionVM.errorMessage) { msg in
                if msg != nil { showError = true }
            }
        }
    }
}
