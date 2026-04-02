
import SwiftUI

struct LoginView: View {

    @State private var email = ""
    @State private var password = ""
    @State private var showPassword = false
    @State private var showError = false
    @State private var goToForgot = false

    @AppStorage("isLoggedIn") var isLoggedIn = false
    @AppStorage("userRole") var userRole = ""

    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemGray6).ignoresSafeArea()

                VStack(spacing: 20) {

                    // ERROR BANNER
                    if showError {
                        HStack {
                            Image(systemName: "exclamationmark.circle.fill")
                                .foregroundColor(.red)
                            Text("Tài khoản hoặc mật khẩu không chính xác")
                                .foregroundColor(.red)
                                .font(.subheadline)
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.red.opacity(0.15))
                        .cornerRadius(12)
                        .padding(.horizontal)
                    }

                    Spacer()

                    // LOGO
                    VStack(spacing: 10) {
                        Image(systemName: "clock.arrow.circlepath")
                            .font(.system(size: 60))
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.blue)
                            .clipShape(RoundedRectangle(cornerRadius: 20))

                        Text("TimeMark")
                            .font(.title)
                            .bold()
                            .foregroundColor(.blue)

                        Text("Kỷ nguyên quản lý thời gian")
                            .foregroundColor(.gray)
                    }

                    // FORM
                    VStack(spacing: 15) {

                        // EMAIL
                        VStack(alignment: .leading) {
                            Text("EMAIL")
                                .font(.caption)
                                .foregroundColor(.gray)

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

                        // PASSWORD
                        VStack(alignment: .leading) {
                            Text("MẬT KHẨU")
                                .font(.caption)
                                .foregroundColor(.gray)

                            HStack {
                                Image(systemName: "lock")
                                    .foregroundColor(.gray)

                                if showPassword {
                                    TextField("••••••••", text: $password)
                                } else {
                                    SecureField("••••••••", text: $password)
                                }

                                Button(action: {
                                    showPassword.toggle()
                                }) {
                                    Image(systemName: showPassword ? "eye" : "eye.slash")
                                        .foregroundColor(.gray)
                                }
                            }
                            .padding()
                            .background(Color(.systemGray5))
                            .cornerRadius(12)
                        }

                        // LOGIN BUTTON
                        Button(action: {
                            login()
                        }) {
                            Text("Đăng nhập")
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.blue)
                                .cornerRadius(25)
                        }
                        .padding(.top)

                        // FORGOT PASSWORD
                        Button("Quên mật khẩu?") {
                            goToForgot = true
                        }
                        .foregroundColor(.blue)
                        .font(.footnote)
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(25)
                    .padding(.horizontal)

                    Spacer()
                }
            }
            // ✅ Dùng navigationDestination thay vì NavigationLink cũ
            .navigationDestination(isPresented: $goToForgot) {
                ForgotPasswordView()
            }
        }
    }

    // ✅ Login với phân quyền Admin / Nhân viên
    func login() {
        if email == "admin@gmail.com" && password == "123456" {
            showError = false
            isLoggedIn = true
            userRole = "admin"
        } else if email == "nv@gmail.com" && password == "123456" {
            showError = false
            isLoggedIn = true
            userRole = "employee"
        } else {
            showError = true
        }
    }
}
