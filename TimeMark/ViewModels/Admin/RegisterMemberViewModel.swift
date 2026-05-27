import Foundation
import SwiftUI

@MainActor
class RegisterMemberViewModel: ObservableObject {
    
    @Published var positions: [Position] = []
    @Published var departments: [DepartmentListItem] = []
    
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    func loadFormData() {
        isLoading = true
        errorMessage = nil
        
        let group = DispatchGroup()
        
        group.enter()
        fetchPositions {
            group.leave()
        }
        
        group.enter()
        fetchDepartments {
            group.leave()
        }
        
        group.notify(queue: .main) {
            self.isLoading = false
        }
    }
    
    private func fetchPositions(completion: @escaping () -> Void) {
        APIService.shared.request(endpoint: "/api/position") { data, error in
            defer { completion() }
            
            if let error = error {
                print("❌ POSITION ERROR:", error)

                DispatchQueue.main.async {
                    self.errorMessage = error.localizedDescription
                }
                return
            }
            
            guard let data = data else {
                print("❌ DATA NIL")

                DispatchQueue.main.async {
                    self.errorMessage = "Không có dữ liệu position"
                }
                return
            }
            print("📦 JSON:", String(data: data, encoding: .utf8) ?? "")

            do {
                let response = try JSONDecoder().decode(
                    PositionListResponse.self,
                    from: data
                )
                
                DispatchQueue.main.async {
                    self.positions = response.data.filter {
                        $0.isDeleted != true
                    }
                }
            } catch {
                DispatchQueue.main.async {
                    print("❌ POSITION DECODE ERROR:", error)
                    self.errorMessage = error.localizedDescription
                }
            }
        }
    }
    
    private func fetchDepartments(completion: @escaping () -> Void) {
        APIService.shared.request(endpoint: "/api/department") { data, error in
            defer { completion() }
            
            if let error = error {
                DispatchQueue.main.async {
                    print("departmant: ",error)
                    self.errorMessage = error.localizedDescription
                }
                return
            }
            
            guard let data = data else {
                DispatchQueue.main.async {
                    self.errorMessage = "Không có dữ liệu department"
                    
                }
                return
            }
            print("department", String(data: data, encoding: .utf8) ?? "")
            do {
                let response = try JSONDecoder().decode(
                    DepartmentListResponse.self,
                    from: data
                )
                
                DispatchQueue.main.async {
                    self.departments = response.data.filter {
                        $0.isDeleted != true
                    }
                }
            } catch {
                DispatchQueue.main.async {
                    print("❌ DEPARTMENT DECODE ERROR:", error)
                    self.errorMessage = error.localizedDescription
                }
            }
        }
    }
}
