import SwiftUI

struct SwipeablePositionCard: View {
    let pos: Position
    let onDelete: (@escaping (String) -> Void) -> Void

    @State private var offset: CGFloat = 0
    @State private var showDeleteConfirm = false  // confirm trước khi xóa
    @State private var showDeleteError = false     // hiện lỗi nếu xóa thất bại
    @State private var errorMessage: String = ""

    var body: some View {
        ZStack {
            // Nút xóa phía sau
            HStack {
                Spacer()
                Button {
                    withAnimation { offset = 0 }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                        showDeleteConfirm = true
                    }
                } label: {
                    Image(systemName: "trash")
                        .foregroundColor(.white)
                        .frame(width: 70, height: 65)
                        .background(Color.red)
                        .cornerRadius(12)
                }
            }

            // Card chính
            HStack(alignment: .top, spacing: 12) {
                ZStack {
                    Circle()
                        .fill(Color.green.opacity(0.15))
                        .frame(width: 40, height: 40)
                    Image(systemName: "person.text.rectangle")
                        .foregroundColor(.green)
                }

                VStack(alignment: .leading, spacing: 6) {
                    Text(pos.name)
                        .font(.system(size: 16, weight: .semibold))
                    if let desc = pos.description, !desc.isEmpty {
                        Text(desc)
                            .font(.system(size: 13))
                            .foregroundColor(.gray)
                    }
                }
                Spacer()
            }
            .padding()
            .background(Color.white)
            .cornerRadius(14)
            .shadow(color: .black.opacity(0.05), radius: 4)
            .offset(x: offset)
            .gesture(
                DragGesture()
                    .onChanged { value in
                        if value.translation.width < 0 {
                            offset = value.translation.width
                        }
                    }
                    .onEnded { value in
                        withAnimation {
                            offset = value.translation.width < -80 ? -80 : 0
                        }
                    }
            )
        }
        .animation(.easeInOut, value: offset)

        // Confirm xóa
        .alert("Xóa chức danh?", isPresented: $showDeleteConfirm) {
            Button("Xóa", role: .destructive) {
                onDelete { errMsg in
                    errorMessage = errMsg
                    showDeleteError = true
                }
            }
            Button("Hủy", role: .cancel) {
                withAnimation { offset = 0 }
            }
        } message: {
            Text("Bạn có chắc muốn xóa \"\(pos.name)\" không?")
        }

        // Hiện lỗi nếu xóa thất bại
        .alert("Không thể xóa", isPresented: $showDeleteError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(errorMessage)
        }
    }
}
