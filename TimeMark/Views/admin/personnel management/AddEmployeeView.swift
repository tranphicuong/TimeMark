import SwiftUI
// MARK: - Add Employee View
struct AddEmployeeView: View {
    @Environment(\.dismiss) var dismiss
    @State private var fullName = ""
    @State private var email = ""
    @State private var password = ""
    @State private var department = "Kỹ thuật"
    @State private var role = "Nhân viên"
    
    var body: some View {
        VStack {
            HStack {
                Button(action: { dismiss() }) {
                    Image(systemName: "arrow.left")
                        .foregroundColor(.blue)
                        .font(.title2)
                }
                Spacer()
                Text("Thêm nhân viên")
                    .font(.headline)
                Spacer()
                Spacer().frame(width: 40)
            }
            .padding()
            
            ScrollView {
                VStack(spacing: 25) {
                    VStack {
                        ZStack(alignment: .bottomTrailing) {
                            Circle()
                                .fill(Color(.systemGray5))
                                .frame(width: 120, height: 120)
                                .overlay(
                                    Image(systemName: "desktopcomputer")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 60)
                                        .foregroundColor(.gray)
                                )
                            Circle()
                                .fill(Color.blue)
                                .frame(width: 35, height: 35)
                                .overlay(
                                    Image(systemName: "camera.fill")
                                        .font(.caption)
                                        .foregroundColor(.white)
                                )
                        }
                        Text("Tải lên ảnh đại diện")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .padding(.top, 8)
                    }
                    
                    VStack(spacing: 16) {
                        InputField(label: "HỌ VÀ TÊN", placeholder: "Nguyễn Văn A", text: $fullName)
                        InputField(label: "ĐỊA CHỈ EMAIL", placeholder: "example@timemark.com", text: $email)
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("MẬT KHẨU")
                                .font(.system(size: 10, weight: .bold))
                                .foregroundColor(.blue)
                            HStack {
                                SecureField("••••••••••••", text: $password)
                                Image(systemName: "eye.slash")
                                    .foregroundColor(.gray)
                            }
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(12)
                        }
                        
                        DropdownField(label: "PHÒNG BAN", selection: $department)
                        DropdownField(label: "CHỨC VỤ", selection: $role)
                    }
                    .padding(.horizontal)
                    
                    Button(action: { dismiss() }) {
                        Text("Lưu tài khoản")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(12)
                    }
                    .padding(.horizontal)
                    .padding(.top, 20)
                }
            }
        }
        .navigationBarHidden(true)
        .toolbar(.hidden, for: .tabBar)
    }
}
