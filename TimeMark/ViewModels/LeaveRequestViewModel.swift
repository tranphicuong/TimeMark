import SwiftUI
import FirebaseFirestore
import FirebaseAuth

class LeaveRequestViewModel: ObservableObject {
    
    @Published var selectedLeaveType: LeaveType? = .annual
    @Published var startDate = Date()
    @Published var endDate = Date()
    @Published var reason = ""
    
    @Published var isLoading = false
    @Published var showSuccess = false
    @Published var showError = false
    @Published var errorMessage = ""
    
    // Leave Balance
    @Published var remainingLeaveDays: Int = 0
    @Published var totalLeaveDays: Int = 0
    @Published var usedLeaveDays: Int = 0
    
    private var balanceItemRef: DocumentReference?
    
    var daysOff: Int {
        let calendar = Calendar.current
        guard endDate >= startDate else { return 0 }
        let components = calendar.dateComponents([.day], from: startDate, to: endDate)
        return (components.day ?? 0) + 1
    }
    
    var canSubmit: Bool {
        selectedLeaveType != nil &&
        !reason.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        endDate >= startDate &&
        daysOff > 0 &&
        (selectedLeaveType != .annual || daysOff <= remainingLeaveDays)
    }
    
    init() {
        fetchLeaveBalance()
    }
    
    func fetchLeaveBalance() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        let db = Firestore.firestore()
        
        db.collection("leave_balance")
            .whereField("id_user", isEqualTo: db.document("users/\(uid)"))
            .limit(to: 1)
            .getDocuments { [weak self] snapshot, error in
                guard let self = self,
                      let balanceDoc = snapshot?.documents.first else {
                    
                    return
                }
                
                balanceDoc.reference.collection("item")
                    .limit(to: 1)
                    .getDocuments { itemSnapshot, _ in
                        guard let itemDoc = itemSnapshot?.documents.first else {
                           
                            return
                        }
                        
                        self.balanceItemRef = itemDoc.reference
                        
                        let data = itemDoc.data()
                        self.totalLeaveDays = data["total_days"] as? Int ?? 12
                        self.usedLeaveDays = data["used_days"] as? Int ?? 0
                        self.remainingLeaveDays = data["remaining_days"] as? Int ?? 12
                    }
            }
    }
    
    func submitLeaveRequest() {
        guard let leaveType = selectedLeaveType else {
            errorMessage = "Vui lòng chọn loại nghỉ phép"
            showError = true
            return
        }
        
        guard !reason.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            errorMessage = "Vui lòng nhập lý do"
            showError = true
            return
        }
        
        guard endDate >= startDate else {
            errorMessage = "Ngày kết thúc phải sau hoặc bằng ngày bắt đầu"
            showError = true
            return
        }
        
        guard startDate >= Calendar.current.startOfDay(for: Date()) else {
            errorMessage = "Không được chọn ngày trong quá khứ"
            showError = true
            return
        }
        
        guard leaveType != .annual || daysOff <= remainingLeaveDays else {
            errorMessage = "Bạn chỉ còn \(remainingLeaveDays) ngày phép năm. Không đủ để nghỉ \(daysOff) ngày."
            showError = true
            return
        }
        
        isLoading = true
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        let db = Firestore.firestore()
        
        let leaveTypeRef = getLeaveTypeReference(for: leaveType)
        
        let data: [String: Any] = [
            "id_user": db.document("users/\(uid)"),
            "id_leave_type": leaveTypeRef,
            "from_date": Timestamp(date: startDate),
            "to_date": Timestamp(date: endDate),
            "reason": reason,
            "status": "pending",
            "created_at": Timestamp(),
            "days": daysOff,
            "days_restored": false
        ]
        
        db.collection("leave_request").addDocument(data: data) { [weak self] error in
            guard let self = self else { return }
            
            if let error = error {
                DispatchQueue.main.async {
                    self.isLoading = false
                    self.errorMessage = "Gửi đơn thất bại: \(error.localizedDescription)"
                    self.showError = true
                }
                return
            }
            
            if leaveType == .annual {
                self.deductLeaveDays { success in
                    DispatchQueue.main.async {
                        self.completeSubmit(success: success)
                    }
                }
            } else {
                DispatchQueue.main.async {
                    self.completeSubmit(success: true)
                }
            }
        }
    }
    
    private func deductLeaveDays(completion: @escaping (Bool) -> Void) {
        guard let itemRef = balanceItemRef else {
            completion(false)
            return
        }
        
        itemRef.updateData([
            "used_days": FieldValue.increment(Int64(daysOff)),
            "remaining_days": FieldValue.increment(Int64(-daysOff))
        ]) { error in
            completion(error == nil)
        }
    }
    
    private func completeSubmit(success: Bool) {
        isLoading = false
        if success {
            showSuccess = true
            resetForm()
        } else {
            errorMessage = "Đơn đã gửi nhưng cập nhật số ngày phép thất bại."
            showError = true
        }
    }
    
    private func resetForm() {
        reason = ""
        startDate = Date()
        endDate = Date()
        fetchLeaveBalance() // Refresh số ngày
    }
    // MARK: - Helper lấy Reference cho leave_type
    private func getLeaveTypeReference(for type: LeaveType) -> DocumentReference {
        let db = Firestore.firestore()
        
        switch type {
        case .annual:
            return db.document("leave_type/kt3dCcKaA46mMbfnSZAb")
        case .unpaid:
            return db.document("leave_type/no_salary")
        }
       
    }
}
