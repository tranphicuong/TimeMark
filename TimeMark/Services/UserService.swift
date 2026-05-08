<<<<<<< HEAD
=======
//
//  UserService.swift
//  TimeMark
//
//  Created by Rebel on 5/5/26.
//

>>>>>>> tnd
import FirebaseFirestore
import FirebaseAuth

class UserService {
    
    static let shared = UserService()
    private let db = Firestore.firestore()
    private var listener: ListenerRegistration?

    
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
    //MARK: load avartar
    func loadAvatar(completion: @escaping (String) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else { return }

        let key = "avatarURL_\(uid)"

       
        let cached = UserDefaults.standard.string(forKey: key) ?? ""
        completion(cached)


        listenUser(uid: uid) { url in
            guard let url = url else { return }

            DispatchQueue.main.async {
                completion(url)
                UserDefaults.standard.set(url, forKey: key)
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
   
    func listenUser(uid: String, completion: @escaping (String?) -> Void) {
        listener?.remove()
        
        listener = db.collection("users").document(uid)
            .addSnapshotListener { snapshot, error in
                if let data = snapshot?.data(),
                   let avatarURL = data["avatarURL"] as? String {
                    completion(avatarURL)
                }
            }
    }
}
