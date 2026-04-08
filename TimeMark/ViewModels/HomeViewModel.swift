import SwiftUI
import LocalAuthentication

class HomeViewModel: ObservableObject {
    
    @Published var isCheckedIn: Bool = false
    @Published var isCheckedOut: Bool = false
    @Published var checkInTime: Date? = nil
    @Published var checkOutTime: Date? = nil
    @Published var isLoading: Bool = false
    @Published var toastMessage: String = ""
    @Published var showToast: Bool = false
    @Published var toastSuccess: Bool = true
    
    let locationService = LocationService.shared
    private let attendanceService = AttendanceService.shared
    
    static let shared = HomeViewModel()
    
    // MARK: - Mở Camera Check-in
    func startCheckIn() {
        guard locationService.isWithinRange else {
            showMessage("Bạn đang ngoài phạm vi văn phòng", success: false)
            return
        }
        showMessage("Mở camera để chụp ảnh check-in", success: true)
    }
    
    // Gọi sau khi chụp ảnh thành công
    func saveCheckInWithImage(imageBase64: String) {
        guard let location = locationService.userLocation else {
            showMessage("Không lấy được vị trí GPS", success: false)
            return
        }
        
        isLoading = true
        
        attendanceService.checkIn(location: location, faceImageBase64: imageBase64) { [weak self] success, message in
            DispatchQueue.main.async {
                self?.isLoading = false
                self?.showMessage(message, success: success)
                if success {
                    self?.isCheckedIn = true
                    self?.checkInTime = Date()
                }
            }
        }
    }
    
    func startCheckOut() {
        guard locationService.isWithinRange else {
            showMessage("Bạn đang ngoài phạm vi văn phòng", success: false)
            return
        }
        
        isLoading = true
        attendanceService.checkOut { [weak self] success, message in
            DispatchQueue.main.async {
                self?.isLoading = false
                self?.showMessage(message, success: success)
                if success {
                    self?.isCheckedOut = true
                    self?.checkOutTime = Date()
                }
            }
        }
    }
    
    func showMessage(_ message: String, success: Bool) {
        toastMessage = message
        toastSuccess = success
        showToast = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            self.showToast = false
        }
    }
    
    // Computed
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
        return [.green, Color(red: 0.0, green: 0.7, blue: 0.4)]
    }
    
    var totalHoursText: String {
        guard let inTime = checkInTime else { return "0h 00m" }
        let diff = Int((checkOutTime ?? Date()).timeIntervalSince(inTime))
        return "\(diff / 3600)h \(String(format: "%02d", (diff % 3600) / 60))m"
    }
}
