import SwiftUI
import FirebaseAuth

struct ProfileAdminView: View {
    
    @StateObject private var authVM = AuthViewModel.shared
    
    @State private var avatarURL: String = ""
    
    private var avatarStorageKey: String {
        let uid = Auth.auth().currentUser?.uid ?? "unknown"
        return "avatarURL_\(uid)"
    }
    
    // MARK: - Avatar
    @State private var showSourceDialog = false
    @State private var showCamera = false
    @State private var showLibrary = false
    
    // MARK: - Logout
    @State private var showLogoutConfirm = false
    
    // MARK: - Toast
    @State private var showToast = false
    @State private var toastMessage = ""
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 32) {
                    
                    // MARK: - Avatar
                    VStack(spacing: 16) {
                        ZStack {
                            AvatarView(size: 148, avatarURL: avatarURL)
                                .overlay(
                                    Circle()
                                        .stroke(Color.blue.opacity(0.2), lineWidth: 8)
                                        .frame(width: 160, height: 160)
                                )
                                .onTapGesture {
                                    showSourceDialog = true
                                }
                        }
                        
                        VStack(spacing: 6) {
                            Text(authVM.userName.isEmpty ? "No name" : authVM.userName)
                                .font(.title2)
                                .fontWeight(.bold)
                            
                            Text(authVM.userPosition.isEmpty ? "NHÂN VIÊN" : authVM.userPosition)
                                .font(.subheadline)
                                .foregroundColor(.blue)
                        }
                    }
                    .padding(.top, 20)
                    
                    // MARK: - Info
                    VStack(alignment: .leading, spacing: 18) {
                        profileRow(icon: "building.2.fill",
                                   title: "PHÒNG BAN",
                                   value: authVM.userDepartment.isEmpty ? "Chưa có phòng ban" : authVM.userDepartment)
                        
                        Divider()
                        
                        profileRow(icon: "envelope.fill",
                                   title: "EMAIL",
                                   value: authVM.userEmail.isEmpty ? "none" : authVM.userEmail)
                    }
                    .padding(20)
                    .background(Color(.systemGray6))
                    .cornerRadius(24)
                    .padding(.horizontal, 20)
                    
                    // MARK: - Actions
                    VStack(spacing: 14) {
                        NavigationLink {
                            ChangePasswordView()
                        } label: {
                            HStack {
                                Image(systemName: "arrow.clockwise")
                                Text("Đổi mật khẩu")
                            }
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Color.blue)
                            .cornerRadius(16)
                        }
                        
                        Button(role: .destructive) {
                            showLogoutConfirm = true
                        } label: {
                            HStack {
                                Image(systemName: "arrow.right.square")
                                Text("Đăng xuất")
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Color.red.opacity(0.08))
                            .foregroundColor(.red)
                            .cornerRadius(16)
                        }
                    }
                    .padding(.horizontal, 20)
                    
                    Spacer(minLength: 40)
                }
            }
            .navigationTitle("Hồ sơ")
            
            .confirmationDialog("Chọn ảnh đại diện", isPresented: $showSourceDialog) {
                Button("Chụp ảnh") { showCamera = true }
                Button("Chọn từ thư viện") { showLibrary = true }
                Button("Huỷ", role: .cancel) {}
            }
            
            .sheet(isPresented: $showCamera) {
                CameraView { image in
                    if let img = image { handleUpload(img) }
                }
            }
            
            .sheet(isPresented: $showLibrary) {
                ImagePicker(sourceType: .photoLibrary) { image in
                    if let img = image { handleUpload(img) }
                }
            }
            
            .confirmationDialog("Bạn có chắc muốn đăng xuất?", isPresented: $showLogoutConfirm) {
                Button("Đăng xuất", role: .destructive) {
                    authVM.logout()
              
                    UserDefaults.standard.removeObject(forKey: avatarStorageKey)
                    avatarURL = ""
                    showToastMessage(message: "Đã đăng xuất")
                }
                Button("Huỷ", role: .cancel) {}
            }
            
            .overlay(
                VStack {
                    Spacer()
                    if showToast {
                        HStack(spacing: 8) {
                            Image(systemName: "checkmark.circle.fill")
                            Text(toastMessage)
                        }
                        .padding()
                        .background(Color.black.opacity(0.85))
                        .foregroundColor(.white)
                        .cornerRadius(12)
                        .padding(.bottom, 40)
                    }
                }
            )
            .onAppear {
                UserService.shared.loadAvatar{
                    url in avatarURL = url
                }
            }
        }
    }
    
   
    // MARK: - Upload
    func handleUpload(_ image: UIImage) {
        AvatarService.shared.upload(image: image) { success, url in
            if success, let url = url, !url.isEmpty {
                avatarURL = url
                UserDefaults.standard.set(url, forKey: avatarStorageKey)
                UserService.shared.updateAvatar(url: url)
                showToastMessage(message: "Cập nhật avatar thành công")
            } else {
                showToastMessage(message: "Upload thất bại")
            }
        }
    }
    
    func showToastMessage(message: String) {
        toastMessage = message
        withAnimation { showToast = true }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            withAnimation { showToast = false }
        }
    }
    
    private func profileRow(icon: String, title: String, value: String) -> some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .foregroundColor(.blue)
                .frame(width: 28)
            
            VStack(alignment: .leading) {
                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Text(value)
                    .font(.body)
            }
            Spacer()
        }
    }
}
