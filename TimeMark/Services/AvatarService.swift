import SwiftUI

class AvatarService {
    
    static let shared = AvatarService()
    
    func upload(image: UIImage, completion: @escaping (Bool, String?) -> Void) {
        CloudinaryService.shared.uploadAvatarImage(image: image) { success, url in
            DispatchQueue.main.async {
                completion(success, url)
            }
        }
    }
}
