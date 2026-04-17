

import UIKit
import Foundation

class CloudinaryService {

    static let shared = CloudinaryService()

    // MARK: - Upload ảnh chấm công
    func uploadAttendanceImage(
        image: UIImage,
        completion: @escaping (Bool, String?) -> Void  
    ) {
        upload(image: image, preset: CloudinaryConfig.attendancePreset, completion: completion)
    }

    // MARK: - Upload ảnh avatar
    func uploadAvatarImage(
        image: UIImage,
        completion: @escaping (Bool, String?) -> Void
    ) {
        upload(image: image, preset: CloudinaryConfig.avatarPreset, completion: completion)
    }

    // MARK: - Core upload
    private func upload(
        image: UIImage,
        preset: String,
        completion: @escaping (Bool, String?) -> Void
    ) {
        guard let imageData = image.jpegData(compressionQuality: 0.7) else {
            completion(false, nil)
            return
        }

        let url = URL(string: "https://api.cloudinary.com/v1_1/\(CloudinaryConfig.cloudName)/image/upload")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"

        let boundary = UUID().uuidString
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

        var body = Data()

        // Thêm upload_preset
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"upload_preset\"\r\n\r\n".data(using: .utf8)!)
        body.append("\(preset)\r\n".data(using: .utf8)!)

        // Thêm file ảnh
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"file\"; filename=\"image.jpg\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
        body.append(imageData)
        body.append("\r\n".data(using: .utf8)!)
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)

        request.httpBody = body

        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    print(" Cloudinary error: \(error.localizedDescription)")
                    completion(false, nil)
                    return
                }

                guard let data = data,
                      let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                      let secureUrl = json["secure_url"] as? String else {
                    print(" Cloudinary parse error")
                    completion(false, nil)
                    return
                }

                print("Uploaded: \(secureUrl)")
                completion(true, secureUrl)
            }
        }.resume()
    }
}

// MARK: - Config (thay bằng thông tin thật)
struct CloudinaryConfig {
    static let cloudName          = "dpndx8uik"
    static let attendancePreset   = "timemark_attendance"
    static let avatarPreset       = "timemark_avatar"       
}
