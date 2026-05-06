import SwiftUI
import FirebaseAuth
import FirebaseFirestore

class AuthViewModel: ObservableObject {
    
    // MARK: - Published Properties
    @Published var isLoggedIn = false
    @Published var userRole = ""
    @Published var userName = ""
    @Published var userEmail = ""
    @Published var isLoading = false
    @Published var errorMessage = ""
    @Published var showError = false
    @Published var resetEmailSent = false
    @Published var isCheckingAuth = true
    @Published var userPosition: String = ""
    @Published var userDepartment: String = ""
    @Published var isAccountLocked = false
    @Published var showLockedAlert = false
    @Published var avatarURL: String = ""
       
    private let db = Firestore.firestore()
    
    // MARK: - Singleton
    static let shared = AuthViewModel()

    // MARK: - Init
    init() {
        startSplashScreenDelay()
    }
    //MARK: Giữ màn hình 5s
    private func startSplashScreenDelay() {
        // Giữ màn hình logo
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
            self.resetStateOnFirstLaunch()
        }
    }

    // MARK: - Reset trạng thái khi mới cài app hoặc reinstall
    private func resetStateOnFirstLaunch() {
        let hasLaunchedBefore = UserDefaults.standard.bool(forKey: "hasLaunchedBefore")
        
        if !hasLaunchedBefore {
            try? Auth.auth().signOut()
            resetUserData()
            
            // Đánh dấu đã chạy lần đầu
            UserDefaults.standard.set(true, forKey: "hasLaunchedBefore")
            DispatchQueue.main.async {
                        self.isCheckingAuth = false
                    }
        } else {
            checkCurrentUser()
        }
    }

    // MARK: - Kiểm tra user hiện tại
    func checkCurrentUser() {
        if let user = Auth.auth().currentUser {
            fetchUserInfo(uid: user.uid)
        } else {
            resetUserData()
            DispatchQueue.main.async{
                self.isCheckingAuth = false
            }
        }
    }

    // MARK: - Đăng nhập
    func login(email: String, password: String) {
        guard !email.isEmpty, !password.isEmpty else {
            setError("Vui lòng nhập đầy đủ email và mật khẩu")
            return
        }

        isLoading = true
        showError = false
        isAccountLocked = false

        Auth.auth().signIn(withEmail: email, password: password) { [weak self] result, error in
            guard let self = self else { return }

            DispatchQueue.main.async {
                self.isLoading = false

                if let error = error {
                    self.setError(self.parseFirebaseError(error))
                    return
                }

                if let uid = result?.user.uid {
                    self.fetchUserInfo(uid: uid)
                    
//                    HomeViewModel.shared.setupListenersForCurrentUser()
                }
            }
        }
    }

    // MARK: - Lấy thông tin user từ Firestore
    func fetchUserInfo(uid: String) {
    
        
        db.collection("users").document(uid).getDocument { [weak self] snapshot, error in
            guard let self = self else { return }

            DispatchQueue.main.async {
                if let error = error {
                    self.isLoggedIn = true
                    self.setError("Lỗi Firestore: \(error.localizedDescription)")
                    self.isCheckingAuth = false
                    return
                }

                guard let data = snapshot?.data(), !data.isEmpty else {
                    self.isLoggedIn = true
                    self.setError("Tài khoản Auth tồn tại nhưng chưa có thông tin trong Firestore.")
                    self.isCheckingAuth = false
                    return
                }
                
                //kiểm tra xem tài khoản có bị khóa hay không
                let isActive = data["isActive"] as? Bool ?? true
                               if !isActive {
                                   try? Auth.auth().signOut()
                                   self.isAccountLocked = true
                                   self.showLockedAlert = true
                                   self.isLoggedIn = false
                                   self.isCheckingAuth = false
                                   self.isLoading = false
                                   self.setError("Tài khoản của bạn đã bị khoá. Vui lòng liên hệ quản trị viên.")
                                   return
                               }

          

                self.userName  = data["name"] as? String ?? ""
                self.userEmail = data["email"] as? String ?? ""
                
                // Xử lý id_role (Reference hoặc String)
                if let roleRef = data["id_role"] as? DocumentReference {
                    self.userRole = roleRef.path.contains("admin") ? "admin" : "user"
                } else if let roleStr = data["id_role"] as? String {
                    self.userRole = roleStr.contains("admin") ? "admin" : "user"
                } else {
                    self.userRole = "user"
                }
                if let positionRef = data["id_position"] as? DocumentReference {
                                positionRef.getDocument { posSnap, _ in
                                    if let posData = posSnap?.data() {
                                        self.userPosition = posData["name"] as? String ?? "Nhân viên"
                                    }
                                }
                            } else {
                                self.userPosition = "Nhân viên"
                            }
                            
                            
                            if let departmentRef = data["id_department"] as? DocumentReference {
                                departmentRef.getDocument { depSnap, _ in
                                    if let depData = depSnap?.data() {
                                        self.userDepartment = depData["name"] as? String ?? "Chưa có phòng ban"
                                    }
                                }
                            } else {
                                self.userDepartment = "Chưa có phòng ban"
                            }
                self.isLoggedIn = true
                // Lưu thông tin đăng nhập
                UserDefaults.standard.set(true, forKey: "isLoggedIn")
                UserDefaults.standard.set(self.userRole, forKey: "userRole")
                UserDefaults.standard.set(self.userName, forKey: "userName")

                self.isCheckingAuth = false
            }
        }
    }


    // MARK: - Quên mật khẩu
    func sendPasswordReset(email: String, completion: @escaping (Bool, String) -> Void) {
        guard !email.isEmpty else {
            completion(false, "Vui lòng nhập địa chỉ email")
            return
        }

        guard isValidEmail(email) else {
            completion(false, "Email không đúng định dạng")
            return
        }

        isLoading = true

        Auth.auth().sendPasswordReset(withEmail: email) { [weak self] error in
            guard let self = self else { return }

            DispatchQueue.main.async {
                self.isLoading = false
                if let error = error {
                    completion(false, self.parseFirebaseError(error))
                } else {
                    completion(true, "Link đặt lại mật khẩu đã được gửi về email của bạn")
                    self.resetEmailSent = true
                }
            }
        }
    }

    // MARK: - Đăng xuất
    func logout() {
        do {
//            HomeViewModel.shared.resetAllData()
            try Auth.auth().signOut()
            resetUserData()
        } catch {
            setError("Đăng xuất thất bại: \(error.localizedDescription)")
        }
    }

    // MARK: - Reset cho màn Login
    func resetForLoginScreen() {
        isLoggedIn = false
        showError = false
        errorMessage = ""
    }

    private func resetUserData() {
        isLoggedIn = false
        userRole = ""
        userName = ""
        userEmail = ""
        UserDefaults.standard.set(false, forKey: "isLoggedIn")
        UserDefaults.standard.set("", forKey: "userRole")
        UserDefaults.standard.set("", forKey: "userName")
    }
    //lang nghe tu firebase
    func listenUser() {
        guard let uid = Auth.auth().currentUser?.uid else { return }

        UserService.shared.listenUser(uid: uid) { [weak self] url in
            DispatchQueue.main.async {
                self?.avatarURL = url ?? ""
            }
        }
    }

    // MARK: - Helpers
    private func setError(_ message: String) {
        errorMessage = message
        showError = true
    }

    func isValidEmail(_ email: String) -> Bool {
        let regex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        return NSPredicate(format: "SELF MATCHES %@", regex).evaluate(with: email)
    }

    private func parseFirebaseError(_ error: Error) -> String {
        let code = (error as NSError).code
        switch code {
        case 17004, 17009: return "Email hoặc mật khẩu không chính xác"
        case 17008: return "Email không đúng định dạng"
        case 17011: return "Tài khoản không tồn tại"
        case 17010: return "Tài khoản bị khoá tạm thời"
        case 17020: return "Không có kết nối mạng"
        case 17026: return "Mật khẩu phải có ít nhất 6 ký tự"
        default:    return "Đã có lỗi xảy ra. Vui lòng thử lại"
        }
    }
}
