import Foundation
import FirebaseFirestore

final class DepartmentFirebaseService {
    static let shared = DepartmentFirebaseService()
    private let db = Firestore.firestore()

    private init() {}

    func getAllDepartments(
        completion: @escaping (Result<[DepartmentData], Error>) -> Void
    ) {
        db.collection("department").getDocuments { snapshot, error in

            if let error = error {
                completion(.failure(error))
                return
            }

            guard let documents = snapshot?.documents else {
                let noDataError = NSError(
                    domain: "DepartmentFirebaseService",
                    code: -1,
                    userInfo: [
                        NSLocalizedDescriptionKey: "Không có dữ liệu phòng ban"
                    ]
                )
                completion(.failure(noDataError))
                return
            }

            let ids = documents.map { $0.documentID }

            var results: [DepartmentData] = []
            let group = DispatchGroup()

            for id in ids {
                group.enter()

                DepartmentService.shared.getDepartmentUsers(
                    departmentId: id
                ) { result in
                    switch result {
                    case .success(let department):
                        results.append(department)

                    case .failure(let error):
                        print("❌ Lỗi department \(id):", error.localizedDescription)
                    }

                    group.leave()
                }
            }

            group.notify(queue: .main) {
                completion(.success(results))
            }
        }
    }
}
