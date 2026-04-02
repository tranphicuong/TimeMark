
import SwiftUI

struct ProfileView: View {
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                
                // MARK: Avatar lớn
                ZStack {
                    Circle()
                        .stroke(Color.blue, lineWidth: 5)
                        .frame(width: 150, height: 150)
                    
                    Image("avatar")
                        .resizable()
                        .scaledToFill()
                        .frame(width: 140, height: 140)
                        .clipShape(Circle())
                    
                    // icon tick
                    VStack {
                        Spacer()
                        HStack {
                            Spacer()
                            Image(systemName: "checkmark.seal.fill")
                                .foregroundColor(.blue)
                                .background(Color.white)
                                .clipShape(Circle())
                        }
                    }
                    .frame(width: 150, height: 150)
                }
                .padding(.top, 20)
                
                // MARK: Name + Role
                Text("Nguyễn Minh Tú")
                    .font(.title)
                    .fontWeight(.bold)
                
                Text("NHÂN VIÊN THIẾT KẾ CAO CẤP")
                    .font(.subheadline)
                    .foregroundColor(.blue)
                
                // MARK: Card Info
                VStack(spacing: 15) {
                    
                    profileRow(icon: "building.2.fill",
                            title: "PHÒNG BAN",
                            value: "Phát triển Sản phẩm (R&D)")
                    
                    profileRow(icon: "envelope.fill",
                            title: "EMAIL",
                            value: "tu.nguyen@timemark.vn")
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(20)
                .padding(.horizontal)
                
                // MARK: Change Password
                Button {
                    print("Đổi mật khẩu")
                } label: {
                    HStack {
                        Image(systemName: "arrow.clockwise")
                        Text("Đổi mật khẩu")
                            .fontWeight(.medium)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.white)
                    .overlay(
                        RoundedRectangle(cornerRadius: 15)
                            .stroke(Color.gray.opacity(0.3))
                    )
                    .cornerRadius(15)
                }
                .padding(.horizontal)
                
                // MARK: Logout
                Button {
                    print("Đăng xuất")
                } label: {
                    HStack {
                        Image(systemName: "arrow.right.square")
                        Text("Đăng xuất")
                            .fontWeight(.bold)
                    }
                    .foregroundColor(.red)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.red.opacity(0.1))
                    .cornerRadius(15)
                }
                .padding(.horizontal)
                
                Spacer()
            }
        }
    }
}
