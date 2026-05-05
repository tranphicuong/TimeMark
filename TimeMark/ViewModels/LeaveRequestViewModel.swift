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
    
    // MARK: - Số ngày nghỉ tính theo ngày

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
    
    // MARK: - Fetch số ngày phép
    func fetchLeaveBalance() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        let db = Firestore.firestore()
        
        db.collection("leave_balance")
            .whereField("id_user", isEqualTo: db.document("users/\(uid)"))
            .limit(to: 1)
            .getDocuments { [weak self] snapshot, error in
                guard let self = self,
                      let balanceDoc = snapshot?.documents.first else { return }
                
                balanceDoc.reference.collection("item")
                    .limit(to: 1)
                    .getDocuments { [weak self] itemSnapshot, _ in
                        guard let self = self,
                              let itemDoc = itemSnapshot?.documents.first else { return }
                        
                        self.balanceItemRef = itemDoc.reference
                        
                        let data = itemDoc.data()
                        DispatchQueue.main.async {
                            self.totalLeaveDays     = data["total_days"] as? Int ?? 12
                            self.usedLeaveDays      = data["used_days"] as? Int ?? 0
                            self.remainingLeaveDays = data["remaining_days"] as? Int ?? 12
                        }
                    }
            }
    }
    
    // MARK: - Submit
    func submitLeaveRequest() {
        guard let leaveType = selectedLeaveType else {
            showErrorAlert("Vui lòng chọn loại nghỉ phép")
            return
        }
        
        guard !reason.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            showErrorAlert("Vui lòng nhập lý do")
            return
        }
        
        guard endDate >= startDate else {
            showErrorAlert("Ngày kết thúc phải sau hoặc bằng ngày bắt đầu")
            return
        }
        
        guard startDate >= Calendar.current.startOfDay(for: Date()) else {
            showErrorAlert("Không được chọn ngày trong quá khứ")
            return
        }
        
        
        if leaveType == .annual {
            guard daysOff <= remainingLeaveDays else {
                showErrorAlert("Bạn chỉ còn \(remainingLeaveDays) ngày phép năm. Không đủ để nghỉ \(daysOff) ngày.")
                return
            }
        }
        
        guard let uid = Auth.auth().currentUser?.uid else {
            showErrorAlert("Không xác định được tài khoản. Vui lòng đăng nhập lại.")
            return
        }
        
        isLoading = true
        
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
                    self.showErrorAlert("Gửi đơn thất bại: \(error.localizedDescription)")
                }
                return
            }
            
           
            if leaveType == .annual {
        
                self.deductLeaveDays(days: self.daysOff) { success in
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
    
    // MARK: - Trừ đúng số ngày truyền vào
    private func deductLeaveDays(days: Int, completion: @escaping (Bool) -> Void) {
        guard let itemRef = balanceItemRef else {
         
            fetchLeaveBalance()
            completion(false)
            return
        }
        
        guard days > 0 else {
            completion(true)
            return
        }
        
       
        let db = Firestore.firestore()
        db.runTransaction({ transaction, errorPointer in
            let itemDoc: DocumentSnapshot
            do {
                itemDoc = try transaction.getDocument(itemRef)
            } catch let fetchError as NSError {
                errorPointer?.pointee = fetchError
                return nil
            }
            
            let currentRemaining = itemDoc.data()?["remaining_days"] as? Int ?? 0
            let currentUsed      = itemDoc.data()?["used_days"] as? Int ?? 0
            
            
            guard currentRemaining >= days else {
                let error = NSError(
                    domain: "LeaveRequest",
                    code: 400,
                    userInfo: [NSLocalizedDescriptionKey: "Không đủ ngày phép"]
                )
                errorPointer?.pointee = error
                return nil
            }
            
            transaction.updateData([
                "used_days":      currentUsed + days,
                "remaining_days": currentRemaining - days
            ], forDocument: itemRef)
            
            return nil
        }) { [weak self] _, error in
            if let error = error {
                print("Transaction deductLeaveDays error: \(error.localizedDescription)")
                completion(false)
            } else {
              
                DispatchQueue.main.async {
                    self?.usedLeaveDays      += days
                    self?.remainingLeaveDays -= days
                }
                completion(true)
            }
        }
    }
    
    private func completeSubmit(success: Bool) {
        isLoading = false
        if success {
            showSuccess = true
            resetForm()
        } else {
            showErrorAlert("Đơn đã gửi nhưng cập nhật số ngày phép thất bại. Vui lòng liên hệ HR.")
        }
    }
    
    private func resetForm() {
        reason    = ""
        startDate = Date()
        endDate   = Date()
        fetchLeaveBalance() 
    }
    
    private func showErrorAlert(_ message: String) {
        errorMessage = message
        showError    = true
    }
    
    // MARK: - Helper lấy Reference cho leave_type
    private func getLeaveTypeReference(for type: LeaveType) -> DocumentReference {
        let db = Firestore.firestore()
        switch type {
        case .annual: return db.document("leave_type/kt3dCcKaA46mMbfnSZAb")
        case .unpaid:  return db.document("leave_type/no_salary")
        }
    }
}
