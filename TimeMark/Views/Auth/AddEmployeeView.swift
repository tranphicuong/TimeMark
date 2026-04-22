import SwiftUI

// MARK: - Add Employee View
struct AddEmployeeView: View {
    @Environment(\.dismiss) var dismiss
    
    @State private var fullName = ""
    @State private var email = ""
    @State private var password = ""
    @State private var department = "Kỹ thuật"
    @State private var role = "Nhân viên"
    
    // 🔥 STATE VALIDATE
    @State private var showError = false
    @State private var errorMessage = ""
    @State private var showConfirm = false
    
    var body: some View {
        VStack {
            // HEADER
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
                    
                    // AVATAR
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
                    
                    // FORM
                    VStack(spacing: 16) {
                        
                        InputField(
                            label: "HỌ VÀ TÊN",
                            placeholder: "Nguyễn Văn A",
                            text: $fullName
                        )
                        
                        InputField(
                            label: "ĐỊA CHỈ EMAIL",
                            placeholder: "example@timemark.com",
                            text: $email
                        )
                        
                        // PASSWORD
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
                        
                        // DROPDOWN
                        dropdownField(
                            label: "PHÒNG BAN",
                            selection: $department,
                            options: ["Kỹ thuật", "Nhân sự", "Kế toán", "Marketing"]
                        )
                        
                        dropdownField(
                            label: "CHỨC VỤ",
                            selection: $role,
                            options: ["Nhân viên", "Trưởng phòng", "Quản lý"]
                        )
                    }
                    .padding(.horizontal)
                    
                    // BUTTON
                    Button(action: {
                        validateForm()
                    }) {
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
        
        // ❌ ALERT LỖI
        .alert("Lỗi", isPresented: $showError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(errorMessage)
        }
        
        // ✅ CONFIRM
        .alert("Xác nhận", isPresented: $showConfirm) {
            Button("Huỷ", role: .cancel) {}
            
            Button("Xác nhận") {
                print(fullName, email, password, department, role)
                dismiss()
            }
        } message: {
            Text("Bạn có chắc muốn tạo tài khoản này?")
        }
    }
    
    // MARK: - VALIDATE
    func validateForm() {
        if fullName.trimmingCharacters(in: .whitespaces).isEmpty {
            errorMessage = "Vui lòng nhập họ và tên"
            showError = true
            return
        }
        
        if email.trimmingCharacters(in: .whitespaces).isEmpty {
            errorMessage = "Vui lòng nhập email"
            showError = true
            return
        }
        
        if !email.contains("@") {
            errorMessage = "Email không hợp lệ"
            showError = true
            return
        }
        
        if password.isEmpty {
            errorMessage = "Vui lòng nhập mật khẩu"
            showError = true
            return
        }
        
        showConfirm = true
    }
}

/////////////////////////////////////////////////////

// MARK: - Input Field
struct inputField: View {
    let label: String
    let placeholder: String
    @Binding var text: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(label)
                .font(.system(size: 10, weight: .bold))
                .foregroundColor(.blue)
            
            TextField(placeholder, text: $text)
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
        }
    }
}

/////////////////////////////////////////////////////

// MARK: - Dropdown Field
struct dropdownField: View {
    let label: String
    @Binding var selection: String
    let options: [String]
    
    @State private var isExpanded = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(label)
                .font(.system(size: 10, weight: .bold))
                .foregroundColor(.blue)
            
            VStack(spacing: 0) {
                
                Button(action: {
                    withAnimation {
                        isExpanded.toggle()
                    }
                }) {
                    HStack {
                        Text(selection)
                        Spacer()
                        Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                }
                
                if isExpanded {
                    VStack(spacing: 0) {
                        ForEach(options, id: \.self) { item in
                            Button {
                                selection = item
                                withAnimation {
                                    isExpanded = false
                                }
                            } label: {
                                HStack {
                                    Text(item)
                                    Spacer()
                                    
                                    if selection == item {
                                        Image(systemName: "checkmark")
                                            .foregroundColor(.blue)
                                    }
                                }
                                .padding()
                            }
                            
                            Divider()
                        }
                    }
                    .background(Color.white)
                    .cornerRadius(12)
                    .shadow(radius: 4)
                }
            }
        }
    }
}
