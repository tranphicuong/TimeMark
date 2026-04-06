struct Department: Identifiable {
    let id = UUID()
    let name: String
    let description: String
    let manager: String
    let employeeCount: Int
    let icon: String
    let iconColor: Color
}
