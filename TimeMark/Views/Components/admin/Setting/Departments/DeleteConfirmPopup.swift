import SwiftUI

struct DeleteConfirmPopup: View {
    let title: String
    let message: String
    let confirmAction: () -> Void
    let cancelAction: () -> Void

    var body: some View {
        VStack(spacing: 20) {
            Capsule()
                .frame(width: 40, height: 5)
                .foregroundColor(.gray.opacity(0.4))
                .padding(.top, 8)

            Image(systemName: "trash.fill")
                .font(.largeTitle)
                .foregroundColor(.red)

            Text(title)
                .font(.headline)

            Text(message)
                .multilineTextAlignment(.center)
                .foregroundColor(.gray)

            Button {
                confirmAction()
            } label: {
                Text("Xác nhận xóa")
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(.red)
                    .foregroundColor(.white)
                    .cornerRadius(16)
            }

            Button("Hủy") {
                cancelAction()
            }
            .foregroundColor(.gray)

            Spacer()
        }
        .padding()
        .presentationDetents([.height(280)])
        .presentationCornerRadius(30)
    }
}
