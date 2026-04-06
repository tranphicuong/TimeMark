import SwiftUI

struct LoginView: View {
    
    @StateObject private var authVM = AuthViewModel.shared
    
    @State private var email = ""
    @State private var password = ""
    @State private var showPassword = false
    @State private var goToForgot = false

    var body: some View {
        NavigationStack {
            // ZStack ngoài cùng để quản lý các lớp đè lên nhau
            ZStack {
               
                Color(.systemGray6).ignoresSafeArea()

              
                VStack(spacing: 30) {
                    
                    // Hiển thị lỗi (nếu có)
                    if authVM.showError {
                        HStack(spacing: 8) {
                            Image(systemName: "exclamationmark.circle.fill")
                                .foregroundColor(.red)
                            Text(authVM.errorMessage)
                                .foregroundColor(.red)
                                .font(.subheadline)
                                .multilineTextAlignment(.center)
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.red.opacity(0.15))
                        .cornerRadius(12)
                        .padding(.horizontal)
                    }

                    Spacer()

                    // Logo
                    VStack(spacing: 12) {
                        Image(systemName: "clock.arrow.circlepath")
                            .font(.system(size: 72))
                            .foregroundColor(.white)
                            .padding(24)
                            .background(Color.blue)
                            .clipShape(RoundedRectangle(cornerRadius: 24))

                        Text("TimeMark")
                            .font(.largeTitle)
                            .bold()
                            .foregroundColor(.blue)

                        Text("Theo dõi thời gian, nâng cao hiệu suất")
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                    }

                    // Form nhập liệu
                    VStack(spacing: 16) {
                        // Email
                        VStack(alignment: .leading, spacing: 6) {
                            Text("EMAIL").font(.caption).foregroundColor(.gray)
                            HStack {
                                Image(systemName: "envelope").foregroundColor(.gray)
                                TextField("email", text: $email)
                                    .keyboardType(.emailAddress)
                                    .autocapitalization(.none)
                                    .autocorrectionDisabled()
                            }
                            .padding()
                            .background(Color(.systemGray5))
                            .cornerRadius(12)
                        }

                        // Mật khẩu
                        VStack(alignment: .leading, spacing: 6) {
                            Text("MẬT KHẨU").font(.caption).foregroundColor(.gray)
                            HStack {
                                Image(systemName: "lock").foregroundColor(.gray)
                                if showPassword {
                                    TextField("password", text: $password)
                                } else {
                                    SecureField("password", text: $password)
                                }
                                Button(action: { showPassword.toggle() }) {
                                    Image(systemName: showPassword ? "eye" : "eye.slash")
                                        .foregroundColor(.gray)
                                }
                            }
                            .padding()
                            .background(Color(.systemGray5))
                            .cornerRadius(12)
                        }

                        // Nút Đăng nhập
                        Button(action: {
                            // Tự động ẩn bàn phím khi bấm nút
                            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                            
                            authVM.showError = false
                            authVM.login(email: email, password: password)
                        }) {
                            Text("Đăng nhập")
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.blue) // Luôn xanh rực rỡ
                                .cornerRadius(25)
                        }
                    }
                    .padding(.horizontal)

                    Button("Quên mật khẩu?") {
                        goToForgot = true
                    }
                    .foregroundColor(.blue)
                    .font(.footnote)

                    Spacer()
                }

          
                if authVM.isLoading {
                    ZStack {
                        // Lớp phủ màu đen mờ bao toàn bộ màn hình
                        Color.black.opacity(0.4)
                            .ignoresSafeArea()
                        
                        // Hộp Loading chính giữa
                        VStack(spacing: 15) {
                            ProgressView()
                                .tint(.white)
                                .scaleEffect(1.5)
                            
                            Text("Đang đăng nhập...")
                                .foregroundColor(.white)
                                .font(.subheadline)
                                .bold()
                        }
                        .padding(30)
                        .background(Color.black.opacity(0.7))
                        .cornerRadius(15)
                    }
                    .transition(.opacity) // Hiệu ứng mờ dần khi ẩn/hiện
                    .zIndex(1) // Đảm bảo lớp này luôn nằm trên cùng của ZStack
                }
            }
          
            .animation(.easeInOut, value: authVM.isLoading)
            .navigationDestination(isPresented: $goToForgot) {
                ForgotPasswordView()
            }
        }
    }
}
