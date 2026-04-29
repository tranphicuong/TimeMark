import SwiftUI


// MARK: - Add Employee View
struct AddEmployeeView: View {
    @Environment(\.dismiss) var dismiss

    @State private var fullName = ""
    @State private var email = ""
    @State private var password = ""
    @State private var department = ""
    @State private var position = ""
    @State private var idDept = ""
    @State private var idPost = ""
    // Validate state
    @State private var showError = false
    @State private var errorMessage = ""
    @State private var showConfirm = false

    // Fetch data
    @StateObject private var vm = RegisterMemberViewModel()
    //load khi có lỗi
    
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
                            text: $email,
                            isEmail: true
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
                        if !vm.departments.isEmpty && !vm.positions.isEmpty {
                            DropdownField(
                                label: "PHÒNG BAN",
                                selection: $department,
                                options: vm.departments.map { $0.name }
                            )

                            DropdownField(
                                label: "CHỨC VỤ",
                                selection: $position,
                                options: vm.positions.map { $0.name }
                            )
                        }
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
        .onAppear {
            vm.loadFormData()
        }
        .onChange(of: vm.departments) { _, newValue in
            if let first = newValue.first {
                if department.isEmpty {
                    department = first.name
                    idDept = first.id
                }
            }
        }

        .onChange(of: vm.positions) { _, newValue in
            if let first = newValue.first {
                if position.isEmpty {
                    position = first.name
                    idPost = first.id
                }
            }
        }
        .onChange(of: department) { _, newValue in
            if let selected = vm.departments.first(where: { $0.name == newValue }) {
                idDept = selected.id
                print("Department ID:", idDept)
            }
        }

        .onChange(of: position) { _, newValue in
            if let selected = vm.positions.first(where: { $0.name == newValue }) {
                idPost = selected.id
                print("Position ID:", idPost)
            }
        }
        
        // VALIDATION ALERT
        .alert("Lỗi", isPresented: $showError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(errorMessage)
        }

        // CONFIRM ALERT
        .alert("Xác nhận", isPresented: $showConfirm) {
            Button("Huỷ", role: .cancel) {}

            Button("Xác nhận") {
                createEmployee()

            }
        } message: {
            Text("Bạn có chắc muốn tạo tài khoản này?")
        }

        // FULL SCREEN STATE
        .overlay {
            overlayView
        }
    }
    func createEmployee() {
        let managerPositionId = "VqfJNhhuL0j4dv7SF7Rf"

        // Nếu là trưởng phòng thì check leader trước
        if idPost == managerPositionId {
            DepartmentService.shared.getDepartmentUsers(
                departmentId: idDept
            ) { result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let deptData):
                        if deptData.leader != nil {
                            errorMessage = "Phòng ban này đã có trưởng phòng"
                            showError = true
                        } else {
                            createUserRequest()
                        }

                    case .failure(let error):
                        errorMessage = error.localizedDescription
                        showError = true
                    }
                }
            }
        } else {
            // Vị trí khác tạo bình thường
            createUserRequest()
        }
    }
    
    func createUserRequest() {
        UserService.shared.createUser(
            email: email,
            password: password,
            name: fullName,
            idPosition: idPost,
            idDepartment: idDept
        ) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let user):
                    print("✅ Created:", user.id_member)
                    dismiss()

                case .failure(let error):
                    errorMessage = error.localizedDescription
                    showError = true
                }
            }
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
    @ViewBuilder
    var overlayView: some View {
        if vm.isLoading {
            ZStack {
                Color.black.opacity(0.15)
                    .ignoresSafeArea()

                VStack(spacing: 16) {
                    ProgressView()
                        .scaleEffect(1.4)

                    Text("Đang tải dữ liệu...")
                        .font(.headline)
                }
                .padding(30)
                .background(Color.white)
                .cornerRadius(16)
            }
        } else if let error = vm.errorMessage {
            ZStack {
                Color.white.ignoresSafeArea()

                VStack(spacing: 20) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.orange)

                    Text("Lỗi tải dữ liệu")
                        .font(.title3)
                        .bold()

                    Text(error)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)

                    HStack(spacing: 12) {
                        Button("Quay về") {
                            dismiss()
                        }
                        .buttonStyle(PrimaryOutlineButton())

                        Button("Tải lại") {
                            vm.errorMessage = nil
                            vm.loadFormData()
                        }
                        .buttonStyle(.borderedProminent)
                    }
                }
                .padding()
            }
        }
    }
}

