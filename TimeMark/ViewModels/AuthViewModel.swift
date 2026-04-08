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
    
    private let db = Firestore.firestore()
    
    // MARK: - Singleton
    static let shared = AuthViewModel()

    // MARK: - Init
    init() {
        startSplashScreenDelay()
    }
    //MARK: Giữ màn hình 5s
    private func startSplashScreenDelay() {
        // Giữ màn hình logo trong đúng 3 giây
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
                self.isLoggedIn = true
                // Lưu thông tin đăng nhập
                UserDefaults.standard.set(true, forKey: "isLoggedIn")
                UserDefaults.standard.set(self.userRole, forKey: "userRole")
                UserDefaults.standard.set(self.userName, forKey: "userName")

                self.isCheckingAuth = false
            }
        }
    }

    // MARK: - Tạo user mới (dành cho Admin)
    func addUser(email: String,
                 password: String,
                 name: String,
                 phone: String = "",
                 departmentId: String = "",
                 positionId: String = "",
                 completion: @escaping (Bool, String) -> Void) {
        
        isLoading = true
        
        Auth.auth().createUser(withEmail: email, password: password) { [weak self] result, error in
            guard let self = self else { return }
            
            if let error = error {
                DispatchQueue.main.async {
                    self.isLoading = false
                    completion(false, self.parseFirebaseError(error))
                }
                return
            }
            
            guard let uid = result?.user.uid else {
                DispatchQueue.main.async {
                    self.isLoading = false
                    completion(false, "Không lấy được UID")
                }
                return
            }
            
            let roleRef = self.db.document("roles/user")
            
            let userData: [String: Any] = [
                "email": email,
                "name": name,
                "phone": phone,
                "id_department": departmentId,
                "id_position": positionId,
                "id_role": roleRef
            ]
            
            self.db.collection("user").document(uid).setData(userData) { error in
                DispatchQueue.main.async {
                    self.isLoading = false
                    if let error = error {
                        completion(false, "Tạo thông tin user thất bại: \(error.localizedDescription)")
                    } else {
                        completion(true, "Tạo tài khoản thành công!")
                    }
                }
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
