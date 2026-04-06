import SwiftUI

struct ProfileAdminView: View {
    
    var body: some View {
        ScrollView {
            VStack(spacing: 32) {  // Tăng spacing để thoáng hơn
                
                // MARK: - Avatar Section
                VStack(spacing: 16) {
                    ZStack {
                        Circle()
                            .stroke(Color.blue.opacity(0.2), lineWidth: 8)
                            .frame(width: 160, height: 160)
                        
                        Image(systemName: "person.circle")

                            .resizable()
                            .scaledToFill()
                            .frame(width: 148, height: 148)
                            .clipShape(Circle())
                            .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
                        
                        // Verified badge
                        VStack {
                            Spacer()
                            HStack {
                                Spacer()
                                Image(systemName: "checkmark.seal.fill")
                                    .font(.system(size: 28))
                                    .foregroundColor(.blue)
                                    .background(
                                        Circle()
                                            .fill(Color.white)
                                            .frame(width: 34, height: 34)
                                    )
                                    .shadow(radius: 2)
                            }
                        }
                        .frame(width: 160, height: 160)
                    }
                    
                    // Name + Role
                    VStack(spacing: 6) {
                        Text("Trần Phi Cường")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Text("NHÂN VIÊN THIẾT KẾ CAO CẤP")
                            .font(.subheadline)
                            .foregroundColor(.blue)
                            .fontWeight(.medium)
                    }
                }
                .padding(.top, 20)
                
                // MARK: - Info Card
                VStack(alignment: .leading, spacing: 18) {
                    profileRow(icon: "building.2.fill",
                              title: "PHÒNG BAN",
                              value: "Phát triển Sản phẩm (R&D)")
                    
                    Divider()
                    
                    profileRow(icon: "envelope.fill",
                              title: "EMAIL",
                              value: "tu.nguyen@timemark.vn")
                    
                    // Có thể thêm nhiều row khác sau này (SĐT, Ngày vào làm, v.v.)
                }
                .padding(20)
                .background(Color(.systemGray6))
                .cornerRadius(24)           // Bo tròn lớn hơn, hiện đại hơn
                .padding(.horizontal, 20)
                
                // MARK: - Action Buttons
                VStack(spacing: 14) {
                    // Đổi mật khẩu
                    Button {
                        print("Đổi mật khẩu")
                    } label: {
                        HStack {
                            Image(systemName: "arrow.clockwise")
                            Text("Đổi mật khẩu")
                                .fontWeight(.semibold)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color.white)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Color.gray.opacity(0.25), lineWidth: 1)
                        )
                        .cornerRadius(16)
                    }
                    
                    // Đăng xuất
                    Button(role: .destructive) {
                        print("Đăng xuất")
                    } label: {
                        HStack {
                            Image(systemName: "arrow.right.square")
                            Text("Đăng xuất")
                                .fontWeight(.semibold)
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
        .navigationBarTitleDisplayMode(.inline)
    }
    
    // MARK: - Reusable Row
    private func profileRow(icon: String, title: String, value: String) -> some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(.blue)
                .frame(width: 28)
            
            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .fontWeight(.medium)
                
                Text(value)
                    .font(.body)
                    .fontWeight(.medium)
            }
            
            Spacer()
        }
    }
}
