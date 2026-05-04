import SwiftUI
import FirebaseAuth

struct ChangePasswordView: View {
    
    @ObservedObject var authVM = AuthViewModel.shared
    @Environment(\.dismiss) var dismiss
    
    @State private var oldPassword = ""
    @State private var newPassword = ""
    @State private var confirmPassword = ""
    
    @State private var showOldPassword = false
    @State private var showNewPassword = false
    @State private var showConfirmPassword = false
    
    @State private var showError = false
    @State private var errorMessage = ""
    @State private var showSuccess = false
    @State private var isLoading = false
    
    var body: some View {
        ZStack {
            Color(.systemGray6).ignoresSafeArea()
            
            VStack(spacing: 24) {
                Text("Đổi mật khẩu")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.top, 20)
                
                VStack(spacing: 16) {
                    
                    // Mật khẩu cũ
                    passwordField(title: "Mật khẩu cũ", text: $oldPassword, isVisible: $showOldPassword)
                    
                    // Mật khẩu mới
                    passwordField(title: "Mật khẩu mới", text: $newPassword, isVisible: $showNewPassword)
                    
                    // Xác nhận mật khẩu mới
                    passwordField(title: "Xác nhận mật khẩu mới", text: $confirmPassword, isVisible: $showConfirmPassword)
                }
                .padding(.horizontal)
                
                Button {
                    changePassword()
                } label: {
                    ZStack {
                        Text("Xác nhận đổi mật khẩu")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(16)
                            .opacity(isLoading ? 0.7 : 1)
                        
                        if isLoading {
                            ProgressView().tint(.white)
                        }
                    }
                }
                .padding(.horizontal)
                .disabled(isLoading)
            }
        }
        .alert("Lỗi", isPresented: $showError) {
            Button("OK") {}
        } message: {
            Text(errorMessage)
        }
        .alert("Thành công", isPresented: $showSuccess) {
            Button("OK") { dismiss() }
        } message: {
            Text("Mật khẩu đã được đổi thành công!")
        }
        .navigationBarTitleDisplayMode(.inline)
    }
    
    // MARK: - Component mật khẩu có eye icon
    private func passwordField(title: String, text: Binding<String>, isVisible: Binding<Bool>) -> some View {
        HStack {
            if isVisible.wrappedValue {
                TextField(title, text: text)
            } else {
                SecureField(title, text: text)
            }
            
            Button {
                isVisible.wrappedValue.toggle()
            } label: {
                Image(systemName: isVisible.wrappedValue ? "eye.slash.fill" : "eye.fill")
                    .foregroundColor(.gray)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
    }
    
    private func changePassword() {
        if oldPassword.isEmpty || newPassword.isEmpty || confirmPassword.isEmpty {
            errorMessage = "Vui lòng nhập đầy đủ thông tin"
            showError = true
            return
        }
        
        if newPassword != confirmPassword {
            errorMessage = "Mật khẩu mới không khớp"
            showError = true
            return
        }
        
        if newPassword.count < 6 {
            errorMessage = "Mật khẩu mới phải có ít nhất 6 ký tự"
            showError = true
            return
        }
        
        isLoading = true
        
        let credential = EmailAuthProvider.credential(withEmail: authVM.userEmail, password: oldPassword)
        
        Auth.auth().currentUser?.reauthenticate(with: credential) { _, error in
            if let error = error {
                DispatchQueue.main.async {
                    self.isLoading = false
                    self.errorMessage = "Mật khẩu cũ không đúng"
                    self.showError = true
                }
                return
            }
            
            Auth.auth().currentUser?.updatePassword(to: self.newPassword) { error in
                DispatchQueue.main.async {
                    self.isLoading = false
                    if let error = error {
                        self.errorMessage = error.localizedDescription
                        self.showError = true
                    } else {
                        self.showSuccess = true
                    }
                }
            }
        }
    }
}
