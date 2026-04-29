//
//  UserService.swift
//  TimeMark
//
//  Created by Doanh on 4/28/26.
//

import Foundation

struct CreateUserResponse: Decodable {
    let message: String
    let data: CreateUserData
}

struct CreateUserData: Decodable {
    let uid: String
    let id_member: String
    let email: String
    let name: String
}

final class UserService {
    static let shared = UserService()

    private init() {}

    private var noDataError: NSError {
        NSError(
            domain: "UserService",
            code: -1,
            userInfo: [
                NSLocalizedDescriptionKey: "Không nhận được dữ liệu từ server"
            ]
        )
    }
    //tạo tài khoản cho nhân sự
    func createUser(
        email: String,
        password: String,
        name: String,
        idPosition: String,
        idDepartment: String,
        completion: @escaping (Result<CreateUserData, Error>) -> Void
    ) {
        let body: [String: Any] = [
            "email": email,
            "password": password,
            "name": name,
            "id_position": idPosition,
            "id_department": idDepartment
        ]

        APIService.shared.request(
            endpoint: "/api/employee/create",
            method: "POST",
            body: body
        ) { data, error in

            if let error = error {
                completion(.failure(error))
                return
            }

            guard let data = data else {
                completion(.failure(self.noDataError))
                return
            }

            do {
                let decoded = try JSONDecoder().decode(
                    CreateUserResponse.self,
                    from: data
                )

                completion(.success(decoded.data))

            } catch {
                completion(.failure(error))
            }
        }
    }
    //lấy tất cả những nhân sự đã xóa
    func getAllDeletedUsers(
        completion: @escaping (Data?, Error?) -> Void
    ) {
        APIService.shared.request(
            endpoint: "/api/employee/playoff",
            method: "GET"
        ) { data, error in
            completion(data, error)
        }
    }
    //lock và unlock tài khoản
    func toggleUserStatus(
        uid: String,
        isActive: Bool,
        completion: @escaping (Result<Bool, Error>) -> Void
    ) {
        let endpoint = "/api/employee/status/\(uid)"

        APIService.shared.request(
            endpoint: endpoint,
            method: "PATCH",
            body: ["isActive": isActive]
        ) { data, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            completion(.success(isActive))
        }
    }
    //xóa nhân sự
    func deleteUser(
        uid: String,
        completion: @escaping (Result<Bool, Error>) -> Void
    ) {
        let endpoint = "/api/employee/\(uid)"

        APIService.shared.request(
            endpoint: endpoint,
            method: "DELETE"
        ) { data, error in
            DispatchQueue.main.async {
                if let error = error {
                    completion(.failure(error))
                    return
                }

                guard data != nil else {
                    completion(.failure(self.noDataError))
                    return
                }

                completion(.success(true))
            }
        }
    }
    //edit employeee
    func editUser(
        uid: String,
        idPosition: String,
        idDepartment: String,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        let body: [String: Any] = [
            "id_position": idPosition,
            "id_department": idDepartment
        ]

        APIService.shared.request(
            endpoint: "/api/employee/edit/\(uid)",
            method: "PATCH",
            body: body
        ) { data, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            completion(.success(()))
        }
    }
}

