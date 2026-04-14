import Foundation

class APIService {
    static let shared = APIService()
    private let baseURL = "http://172.20.10.2:3000"

    private init() {}

    func request(
        endpoint: String,
        method: String = "GET",
        body: [String: Any]? = nil,
        completion: @escaping (Data?, Error?) -> Void
    ) {
        guard let url = URL(string: baseURL + endpoint) else { return }

        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        if let body = body {
            request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        }

        URLSession.shared.dataTask(with: request) { data, _, error in
            completion(data, error)
        }.resume()
    }
}
