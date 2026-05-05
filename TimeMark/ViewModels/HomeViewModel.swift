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
    @Published var remainingLeaveDays: Int = 0
    
    enum CameraMode {
        case checkIn
        case checkOut
    }
    
    // MARK: - Services
    let locationService = LocationService.shared
    private let attendanceService = AttendanceService.shared
    private let cloudinaryService = CloudinaryService.shared
    private let notificationService = NotificationService.shared
    private let db = Firestore.firestore()
    
    private var attendanceListener: ListenerRegistration?
    private var leaveBalanceListener: ListenerRegistration?
    
    
    private var listeningUID: String?
    
    static let shared = HomeViewModel()
    
    // MARK: - Init
    init() {
        setupListenersForCurrentUser()
    }
    
    // MARK: - Setup listeners
    func setupListenersForCurrentUser() {
        guard let uid = Auth.auth().currentUser?.uid else {
            
            stopAllListeners()
            resetDailyState()
            remainingLeaveDays = 0
            return
        }
        
    
        guard listeningUID != uid else { return }
        
        stopAllListeners()
        listeningUID = uid
        
        startRealtimeAttendanceListener(uid: uid)
        startLeaveBalanceListener(uid: uid)
    }
    
    private func stopAllListeners() {
        attendanceListener?.remove()
        attendanceListener = nil
        leaveBalanceListener?.remove()
        leaveBalanceListener = nil
        listeningUID = nil
    }
    
    // MARK: - Realtime Attendance Listener (scoped theo UID)
    private func startRealtimeAttendanceListener(uid: String) {
        let today = todayString()
        
        let userRef = db.document("users/\(uid)")
        
        attendanceListener = db.collection("attendance")
            .whereField("id_user", isEqualTo: userRef)
            .whereField("date", isEqualTo: today)
            .addSnapshotListener { [weak self] snapshot, error in
                guard let self = self else { return }
                
               
                guard Auth.auth().currentUser?.uid == uid else {
                   
                    return
                }
                
                if let error = error {
                    print("Realtime attendance error: \(error.localizedDescription)")
                    return
                }
                
                DispatchQueue.main.async {
                    guard let doc = snapshot?.documents.first else {
                        self.resetDailyState()
                        return
                    }
                    
                    let data = doc.data()
                    
                    if let checkIn = data["check_in"] as? Timestamp {
                        self.isCheckedIn = true
                        self.checkInTime = checkIn.dateValue()
                    } else {
                        self.isCheckedIn = false
                        self.checkInTime = nil
                    }
                    
                    if let checkOut = data["check_out"] as? Timestamp {
                        self.isCheckedOut = true
                        self.checkOutTime = checkOut.dateValue()
                    } else {
                        self.isCheckedOut = false
                        self.checkOutTime = nil
                    }
                }
            }
    }
    
    // MARK: - Cleanup
    deinit {
        stopAllListeners()
    }
    
    private func todayString() -> String {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        return f.string(from: Date())
    }
    
    private func resetDailyState() {
        isCheckedIn = false
        isCheckedOut = false
        checkInTime = nil
        checkOutTime = nil
    }
    
    // MARK: - Handle Tap
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
            guard success, let url = imageURL else {
                DispatchQueue.main.async {
                    self.isLoading = false
                    self.showMessage("Upload ảnh thất bại!", success: false)
                }
                return
            }
            
            if self.cameraMode == .checkIn {
                self.attendanceService.checkIn(location: location, imgCheckinURL: url) { success, message in
                    DispatchQueue.main.async {
                        self.isLoading = false
                        self.showMessage(message, success: success)
                        if success {
                            self.notificationService.notifyCheckIn()
                        }
                    }
                }
            } else {
                self.attendanceService.checkOut(imgCheckoutURL: url) { success, message in
                    DispatchQueue.main.async {
                        self.isLoading = false
                        self.showMessage(message, success: success)
                        if success {
                            self.notificationService.notifyCheckOut()
                        }
                    }
                }
            }
        }
    }
    //MARK: ham reset sau khi logout
    func resetAllData() {
        stopAllListeners()
        
        isCheckedIn = false
        isCheckedOut = false
        checkInTime = nil
        checkOutTime = nil
        remainingLeaveDays = 0
        
        listeningUID = nil
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
    
    // MARK: - Leave Balance Listener
    func startLeaveBalanceListener(uid: String) {
        leaveBalanceListener?.remove()

        db.collection("leave_balance")
            .whereField("id_user", isEqualTo: db.document("users/\(uid)"))
            .limit(to: 1)
            .addSnapshotListener { [weak self] snapshot, error in
                guard let self = self,
                      let balanceDoc = snapshot?.documents.first else { return }

                balanceDoc.reference.collection("item")
                    .getDocuments { snapshot, _ in
                        guard let itemDoc = snapshot?.documents.first else { return }

                        let data = itemDoc.data()
                        DispatchQueue.main.async {
                            self.remainingLeaveDays = data["remaining_days"] as? Int ?? 0
                        }
                    }
            }
    }
}
