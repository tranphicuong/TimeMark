import SwiftUI

struct ForgotPasswordView: View {
    
    @State private var email = ""
    @State private var showSuccess = false
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ZStack {
            Color(.systemGray6).ignoresSafeArea()
            
            VStack(alignment: .leading, spacing: 20) {
                
                // HEADER (chỉ còn title)
                Text("TimeMark")
                    .font(.headline)
                    .foregroundColor(.blue)
                    .padding(.top)
                    .padding(.horizontal)
                
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
                    }
                    .padding()
                    .background(Color(.systemGray5))
                    .cornerRadius(12)
                }
                .padding(.horizontal)
                
                // BUTTON
                Button(action: {
                    sendResetLink()
                }) {
                    HStack {
                        Text("Gửi link đặt lại mật khẩu")
                        Image(systemName: "arrow.right")
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(25)
                }
                .padding(.horizontal)
                
                // SUCCESS BOX
                if showSuccess {
                    HStack(alignment: .top, spacing: 10) {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.blue)
                        
                        VStack(alignment: .leading) {
                            Text("Thành công")
                                .bold()
                                .foregroundColor(.blue)
                            
                            Text("Link đã được gửi về email của bạn")
                                .foregroundColor(.gray)
                        }
                    }
                    .padding()
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(12)
                    .padding(.horizontal)
                }
                
                // BACK TO LOGIN
                HStack {
                    Text("Quay lại màn hình")
                        .foregroundColor(.gray)
                    
                    Button("Đăng nhập") {
                       dismiss()
                    }
                    .foregroundColor(.blue)
                }
                .frame(maxWidth: .infinity)
                
                Spacer()
                
                // TIP BOX
                HStack(alignment: .top, spacing: 10) {
                    Image(systemName: "lightbulb.fill")
                        .foregroundColor(.blue)
                    
                    VStack(alignment: .leading) {
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
        }
    }
    
    func sendResetLink() {
        if !email.isEmpty {
            showSuccess = true
        }
    }
}
