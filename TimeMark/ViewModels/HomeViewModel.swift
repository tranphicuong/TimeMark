import SwiftUI
import FirebaseFirestore
import FirebaseAuth

class HomeViewModel: ObservableObject {
    
    // MARK: - Published
    @Published var isCheckedIn: Bool = false
    @Published var isCheckedOut: Bool = false
    @Published var checkInTime: Date? = nil
    @Published var checkOutTime: Date? = nil
    @Published var isLoading: Bool = false
    @Published var toastMessage: String = ""
    @Published var showToast: Bool = false
    @Published var toastSuccess: Bool = true
    @Published var showCamera: Bool = false
    @Published var cameraMode: CameraMode = .checkIn
    
    enum CameraMode {
        case checkIn
        case checkOut
    }
    
    // MARK: - Services
    let locationService = LocationService.shared
    private let attendanceService = AttendanceService.shared
    private let cloudinaryService = CloudinaryService.shared
    
    static let shared = HomeViewModel()
    
    // MARK: - Init
    init() {
        loadTodayAttendance()
    }
    
    // MARK: - Load từ Firestore (Quan trọng nhất)
    func loadTodayAttendance() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        let today = todayString()
        let userRef = Firestore.firestore().document("users/\(uid)")
        
        Firestore.firestore().collection("attendance")
            .whereField("id_user", isEqualTo: userRef)
            .whereField("date", isEqualTo: today)
            .getDocuments { [weak self] snapshot, error in
                guard let self = self else { return }
                
                DispatchQueue.main.async {
                    if let error = error {
                        print("Lỗi load attendance: \(error.localizedDescription)")
                        return
                    }
                    
                    guard let doc = snapshot?.documents.first else {
                        // Không có record hôm nay
                        self.resetDailyState()
                        return
                    }
                    
                    let data = doc.data()
                    
                    if let checkIn = data["check_in"] as? Timestamp {
                        self.isCheckedIn = true
                        self.checkInTime = checkIn.dateValue()
                    } else {
                        self.isCheckedIn = false
                    }
                    
                    if let checkOut = data["check_out"] as? Timestamp {
                        self.isCheckedOut = true
                        self.checkOutTime = checkOut.dateValue()
                    } else {
                        self.isCheckedOut = false
                    }
                    
                    // Đồng bộ lại vào UserDefaults
                    self.saveDailyState()
                }
            }
    }
    
    // MARK: - Lưu cache vào UserDefaults
    private func saveDailyState() {
        let today = todayString()
        UserDefaults.standard.set(today, forKey: "savedCheckInDate")
        UserDefaults.standard.set(isCheckedIn, forKey: "isCheckedIn")
        UserDefaults.standard.set(isCheckedOut, forKey: "isCheckedOut")
        
        if let time = checkInTime {
            UserDefaults.standard.set(time.timeIntervalSince1970, forKey: "checkInTime")
        }
        if let time = checkOutTime {
            UserDefaults.standard.set(time.timeIntervalSince1970, forKey: "checkOutTime")
        }
    }
    
    private func resetDailyState() {
        isCheckedIn = false
        isCheckedOut = false
        checkInTime = nil
        checkOutTime = nil
        UserDefaults.standard.removeObject(forKey: "savedCheckInDate")
    }
    
    private func todayString() -> String {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        return f.string(from: Date())
    }
    
    // MARK: - Handle Check-in / Check-out Tap
    func handleCheckInTap() {
        guard locationService.isAuthorized else {
            locationService.requestLocationPermission()
            return
        }
        guard locationService.isWithinRange else {
            showMessage("Bạn đang ngoài phạm vi văn phòng\n\(locationService.distanceText)", success: false)
            return
        }
        
        cameraMode = .checkIn
        showCamera = true
    }
    
    func handleCheckOutTap() {
        guard locationService.isAuthorized else {
            locationService.requestLocationPermission()
            return
        }
        guard locationService.isWithinRange else {
            showMessage("Bạn đang ngoài phạm vi văn phòng\n\(locationService.distanceText)", success: false)
            return
        }
        
        cameraMode = .checkOut
        showCamera = true
    }
    
    // MARK: - Nhận ảnh từ Camera
    func onImageCaptured(_ image: UIImage) {
        guard let location = locationService.userLocation else {
            showMessage("Không lấy được vị trí GPS", success: false)
            return
        }
        
        isLoading = true
      
        cloudinaryService.uploadAttendanceImage(image: image) { [weak self] success, imageURL in
            guard let self = self else { return }
            
            if !success || imageURL == nil {
                self.isLoading = false
                self.showMessage("Upload ảnh thất bại!", success: false)
                return
            }
            
            if self.cameraMode == .checkIn {
                self.attendanceService.checkIn(location: location, imgCheckinURL: imageURL) { success, message in
                    DispatchQueue.main.async {
                        self.isLoading = false
                        self.showMessage(message, success: success)
                        if success {
                            self.loadTodayAttendance()  // Load lại từ Firestore
                        }
                    }
                }
            } else {
                self.attendanceService.checkOut(imgCheckoutURL: imageURL) { success, message in
                    DispatchQueue.main.async {
                        self.isLoading = false
                        self.showMessage(message, success: success)
                        if success {
                            self.loadTodayAttendance()  // Load lại từ Firestore
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - Toast
    func showMessage(_ message: String, success: Bool) {
        toastMessage = message
        toastSuccess = success
        withAnimation { showToast = true }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            withAnimation { self.showToast = false }
        }
    }
    
    // MARK: - Computed Properties
    var statusText: String {
        if isCheckedOut { return "Đã về" }
        if isCheckedIn  { return "Đang làm việc" }
        return "Chưa check-in"
    }
    
    var statusColor: Color {
        if isCheckedOut { return .gray }
        if isCheckedIn  { return .green }
        return .red
    }
    
    var buttonTitle: String {
        if isCheckedOut { return "Đã hoàn thành" }
        if isCheckedIn  { return "CHECK-OUT" }
        return "CHECK-IN"
    }
    
    var buttonIcon: String {
        if isCheckedOut { return "checkmark.seal.fill" }
        if isCheckedIn  { return "arrow.left.square.fill" }
        return "camera.fill"
    }
    
    var checkInGradient: [Color] {
        if isCheckedOut { return [.gray, .gray.opacity(0.7)] }
        if isCheckedIn  { return [.red, .orange] }
        if !locationService.isWithinRange { return [Color.gray.opacity(0.5), Color.gray.opacity(0.3)] }
        return [Color.green, Color(red: 0.0, green: 0.7, blue: 0.4)]
    }
    
    var totalHoursText: String {
        guard let inTime = checkInTime else { return "0h 00m" }
        let diff = Int((checkOutTime ?? Date()).timeIntervalSince(inTime))
        return "\(diff / 3600)h \(String(format: "%02d", (diff % 3600) / 60))m"
    }
}
