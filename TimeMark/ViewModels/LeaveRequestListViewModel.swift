import SwiftUI
import FirebaseFirestore
import FirebaseAuth

class LeaveRequestListViewModel: ObservableObject {
    
    @Published var leaveRequests: [LeaveRequest] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let db = Firestore.firestore()
    private var listener: ListenerRegistration?
    
    init() {
        fetchLeaveRequests()
        startRejectedListener()
    }
    
    func fetchLeaveRequests() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        isLoading = true
        
        db.collection("leave_request")
            .whereField("id_user", isEqualTo: db.document("users/\(uid)"))
            .order(by: "created_at", descending: true)
            .getDocuments { [weak self] snapshot, error in
                guard let self = self else { return }
                self.isLoading = false
                
                if let error = error {
                    self.errorMessage = error.localizedDescription
                    return
                }
                
                self.leaveRequests = snapshot?.documents.compactMap {
                    try? $0.data(as: LeaveRequest.self)
                } ?? []
            }
    }
    
    // MARK: - Realtime: Khi có đơn bị từ chối → Hoàn trả ngày phép ngay
    private func startRejectedListener() {
            guard let uid = Auth.auth().currentUser?.uid else { return }
            
            listener = db.collection("leave_request")
                .whereField("id_user", isEqualTo: db.document("users/\(uid)"))
                .whereField("status", isEqualTo: "rejected")
                .addSnapshotListener { [weak self] snapshot, error in
                    guard let self = self, let documents = snapshot?.documents else { return }
                    
                    for doc in documents {
                        let data = doc.data()
                        guard let days = data["days"] as? Int,
                              let restored = data["days_restored"] as? Bool,
                              restored == false else {
                            continue
                        }
                        
                        self.restoreLeaveDays(days: days, requestRef: doc.reference)
                    }
                }
        }
        
        private func restoreLeaveDays(days: Int, requestRef: DocumentReference) {
            guard let uid = Auth.auth().currentUser?.uid else { return }
            
            db.collection("leave_balance")
                .whereField("id_user", isEqualTo: db.document("users/\(uid)"))
                .limit(to: 1)
                .getDocuments { snapshot, _ in
                    guard let balanceDoc = snapshot?.documents.first else { return }
                    
                    balanceDoc.reference.collection("item")
                        .limit(to: 1)
                        .getDocuments { itemSnapshot, _ in
                            guard let itemDoc = itemSnapshot?.documents.first else { return }
                            
                            let batch = self.db.batch()
                            
                            batch.updateData([
                                "used_days": FieldValue.increment(Int64(-days)),
                                "remaining_days": FieldValue.increment(Int64(days))
                            ], forDocument: itemDoc.reference)
                            
                            batch.updateData([
                                "days_restored": true
                            ], forDocument: requestRef)
                            
                            batch.commit { error in
                                if error == nil {
                                   
                                    self.fetchLeaveRequests()
                                }
                            }
                        }
                }
        }
        
        func refresh() {
            fetchLeaveRequests()
        }
        
        deinit {
            listener?.remove()
        }
}
