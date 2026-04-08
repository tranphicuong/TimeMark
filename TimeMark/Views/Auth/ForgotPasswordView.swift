

import SwiftUI


struct ForgotPasswordView: View {

    @State private var email = ""
    @State private var showSuccess = false
    @State private var errorMessage = ""
    @State private var showError = false
    @Environment(\.dismiss) var dismiss

    @ObservedObject var authVM = AuthViewModel.shared

    var body: some View {
        ZStack {
            Color(.systemGray6).ignoresSafeArea()

            VStack(alignment: .leading, spacing: 20) {

                // ICON + TITLE
                VStack(alignment: .leading, spacing: 10) {
                    Image(systemName: "lock.rotation")
                        .font(.system(size: 50))
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.blue)
                        .clipShape(RoundedRectangle(cornerRadius: 20))

                    Text("Quên mật khẩu")
                        .font(.largeTitle)
                        .bold()

                    Text("Vui lòng nhập email để nhận link đặt lại mật khẩu")
                        .foregroundColor(.gray)
                }
                .padding(.horizontal)

                // EMAIL FIELD
                VStack(alignment: .leading, spacing: 8) {
                    Text("Địa chỉ Email")
                        .font(.subheadline)
                        .bold()

                    HStack {
                        Image(systemName: "envelope")
                            .foregroundColor(.gray)
                        TextField("example@timemark.com", text: $email)
                            .keyboardType(.emailAddress)
                            .autocapitalization(.none)
                            .autocorrectionDisabled()
                    }
                    .padding()
                    .background(Color(.systemGray5))
                    .cornerRadius(12)
                }
                .padding(.horizontal)

                // ERROR
                if showError {
                    HStack(spacing: 8) {
                        Image(systemName: "exclamationmark.circle.fill")
                            .foregroundColor(.red)
                        Text(errorMessage)
                            .font(.subheadline)
                            .foregroundColor(.red)
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.red.opacity(0.1))
                    .cornerRadius(12)
                    .padding(.horizontal)
                }

                // BUTTON
                Button(action: { sendReset() }) {
                    ZStack {
                        HStack {
                            Text("Gửi link đặt lại mật khẩu")
                            Image(systemName: "arrow.right")
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(25)
                        .opacity(authVM.isLoading ? 0 : 1)

                        if authVM.isLoading {
                            ProgressView().tint(.white)
                        }
                    }
                }
                .disabled(authVM.isLoading)
                .padding(.horizontal)

                // SUCCESS BOX
                if showSuccess {
                    HStack(alignment: .top, spacing: 10) {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Gửi thành công!")
                                .bold()
                                .foregroundColor(.green)
                            Text("Kiểm tra hộp thư email của bạn và làm theo hướng dẫn")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                    }
                    .padding()
                    .background(Color.green.opacity(0.1))
                    .cornerRadius(12)
                    .padding(.horizontal)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }

                // BACK TO LOGIN
                HStack {
                    Text("Quay lại màn hình")
                        .foregroundColor(.gray)
                    Button("Đăng nhập") { dismiss() }
                        .foregroundColor(.blue)
                }
                .frame(maxWidth: .infinity)

                Spacer()

                // TIP BOX
                HStack(alignment: .top, spacing: 10) {
                    Image(systemName: "lightbulb.fill")
                        .foregroundColor(.blue)
                    VStack(alignment: .leading, spacing: 4) {
                        Text("TIMEMARK TIP")
                            .font(.caption)
                            .foregroundColor(.blue)
                        Text("Mật khẩu mạnh bao gồm chữ hoa, số và ký hiệu đặc biệt.")
                            .font(.footnote)
                            .foregroundColor(.gray)
                    }
                }
                .padding()
                .background(Color.white)
                .cornerRadius(15)
                .padding()
            }
            .animation(.easeInOut(duration: 0.3), value: showSuccess)
            .animation(.easeInOut(duration: 0.3), value: showError)
        }
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Gửi reset email qua Firebase
    func sendReset() {
        showError = false
        showSuccess = false

        authVM.sendPasswordReset(email: email) { success, message in
            if success {
                showSuccess = true
            } else {
                errorMessage = message
                showError = true
            }
        }
    }
}
