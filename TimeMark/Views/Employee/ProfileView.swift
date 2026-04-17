import SwiftUI

struct ProfileView: View {
    
    @StateObject private var authVM = AuthViewModel.shared
    @AppStorage("avatarURL") var avatarURL: String = ""
    
    // MARK: - Avatar
    
    @State private var selectedImage: UIImage?
    @State private var showSourceDialog = false
    @State private var showCamera = false
    @State private var showLibrary = false
    
    // MARK: - Logout
    @State private var showLogoutConfirm = false
    
    // MARK: - Toast
    @State private var showToast = false
    @State private var toastMessage = ""
    
    var body: some View {
        ScrollView {
            VStack(spacing: 32) {
                
                // MARK: - Avatar
                VStack(spacing: 16) {
                    ZStack {
                        AvatarView(
                            size: 148,
                            avatarURL: avatarURL
                        )
                        .overlay(
                            Circle()
                                .stroke(Color.blue.opacity(0.2), lineWidth: 8)
                                .frame(width: 160, height: 160)
                        )
                        .onTapGesture {
                            showSourceDialog = true
                        }
                    }
                    .onTapGesture {
                        showSourceDialog = true
                    }
                    
                    VStack(spacing: 6) {
                        Text("Trần Phi Cường")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Text("NHÂN VIÊN THIẾT KẾ CAO CẤP")
                            .font(.subheadline)
                            .foregroundColor(.blue)
                    }
                }
                .padding(.top, 20)
                
                // MARK: - Info
                VStack(alignment: .leading, spacing: 18) {
                    profileRow(icon: "building.2.fill",
                               title: "PHÒNG BAN",
                               value: "Phát triển Sản phẩm (R&D)")
                    
                    Divider()
                    
                    profileRow(icon: "envelope.fill",
                               title: "EMAIL",
                               value: "tu.nguyen@timemark.vn")
                }
                .padding(20)
                .background(Color(.systemGray6))
                .cornerRadius(24)
                .padding(.horizontal, 20)
                
                // MARK: - Actions
                VStack(spacing: 14) {
                    
                    NavigationLink {
                       // ChangePasswordView()
                    } label: {
                        HStack {
                            Image(systemName: "arrow.clockwise")
                            Text("Đổi mật khẩu")
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color.white)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Color.gray.opacity(0.25))
                        )
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
        
        // MARK: - Chọn ảnh
        .confirmationDialog("Chọn ảnh", isPresented: $showSourceDialog) {
            Button("Thư viện") { showLibrary = true }
            Button("Chụp ảnh") { showCamera = true }
            Button("Huỷ", role: .cancel) {}
        }
        
        // MARK: - Camera (dùng file của mày)
        .sheet(isPresented: $showCamera) {
            CameraView { image in
                if let img = image {
                    handleUpload(img)
                }
            }
        }
        
//        // MARK: - Thư viện
//        .sheet(isPresented: $showLibrary) {
//            ImagePicker(sourceType: .photoLibrary) { image in
//                handleUpload(image)
//            }
//        }
        
        // MARK: - Logout confirm
        .confirmationDialog("Bạn có chắc muốn đăng xuất?",
                            isPresented: $showLogoutConfirm) {
            Button("Đăng xuất", role: .destructive) {
                authVM.logout()
                showToast(message: "Đã đăng xuất")
            }
            Button("Huỷ", role: .cancel) {}
        }
        
        // MARK: - Toast
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
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                    .padding(.bottom, 40)
                }
            }
        )
    }
    
    // MARK: - Upload
    func handleUpload(_ image: UIImage) {
        AvatarService.shared.upload(image: image) { success, url in
            if success, let url = url {
                
               
                UserService.shared.updateAvatar(url: url)
                
              
                avatarURL = url
                
                showToast(message: "Cập nhật avatar thành công")
            } else {
                showToast(message: "Upload thất bại")
            }
        }
    }
    // MARK: - Toast
    func showToast(message: String) {
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
 
