import FirebaseFirestore
import FirebaseAuth

class UserService {
    
    static let shared = UserService()
    private let db = Firestore.firestore()
    
    // MARK: - Update avatar
    func updateAvatar(url: String) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        db.collection("users").document(uid).updateData([
            "avatarURL": url
        ]) { error in
            if let error = error {
                print(" Update avatar lỗi:", error.localizedDescription)
            } else {
                print("Avatar updated Firebase")
            }
        }
    }
    
    // MARK: - Get user
    func fetchUser(completion: @escaping (String?) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        db.collection("users").document(uid).getDocument { snapshot, error in
            if let data = snapshot?.data(),
               let avatarURL = data["avatarURL"] as? String {
                completion(avatarURL)
            } else {
                completion(nil)
            }
        }
    }
    //MARK: lang nghe anh tu firebase
    func listenUser(completion: @escaping (String?) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        db.collection("users").document(uid)
        .addSnapshotListener { snapshot, error in
            if let data = snapshot?.data(),
               let avatarURL = data["avatarURL"] as? String {
                completion(avatarURL)
            }
        }
    }
}
