

import Foundation
@MainActor
class PositionViewModel: ObservableObject {
    @Published var positions: [Position] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var showDeleteError = false

    func fetchPositions() {
        isLoading = true
        errorMessage = nil

        PositionService.shared.getAllPositions { result in
            DispatchQueue.main.async {
                self.isLoading = false
                switch result {
                case .success(let data): self.positions = data
                case .failure(let error): self.errorMessage = error.localizedDescription
                }
            }
        }
    }

    // Thêm completion để AddPositionView biết khi nào xong
    func createPosition(name: String, description: String, completion: (() -> Void)? = nil) {
        isLoading = true

        PositionService.shared.createPosition(name: name, description: description) { result in
            DispatchQueue.main.async {
                self.isLoading = false
                switch result {
                case .success:
                    self.fetchPositions()
                    completion?()
                case .failure(let error):
                    self.errorMessage = error.localizedDescription
                }
            }
        }
    }

    func deletePosition(id: String, onError: ((String) -> Void)? = nil) {
        isLoading = true

        PositionService.shared.deletePosition(id: id) { result in
            DispatchQueue.main.async {
                self.isLoading = false
                switch result {
                case .success:
                    self.positions.removeAll { $0.id == id }
                case .failure(let error):
                    onError?(error.localizedDescription)
                }
            }
        }
    }
}
