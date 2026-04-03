import SwiftUI

struct EmployeeListView: View {
    @State private var searchText = ""
    
    // 👇 QUAN TRỌNG: chỉ lưu 1 thằng đang mở
    @State private var openedEmployeeID: String? = nil
    
    @State private var employees = [
        Employee(id: "1", name: "Nguyễn Hoàng Nam", role: "Kỹ thuật", employeeID: "TM-0911", status: .active, imageName: "person.circle.fill", checkInTime: nil),
        Employee(id: "2", name: "Trần Thanh Vân", role: "Kế toán", employeeID: "TM-0755", status: .onLeave, imageName: "person.circle.fill", checkInTime: nil),
        Employee(id: "3", name: "Phạm Minh Đức", role: "Marketing", employeeID: "TM-1022", status: .locked, imageName: "person.circle.fill", checkInTime: nil),
        Employee(id: "4", name: "Võ Thị Hồng", role: "Thiết kế", employeeID: "TM-0648", status: .active, imageName: "person.circle.fill", checkInTime: nil)
    ]
    
    var body: some View {
        VStack(spacing: 0) {
            
            // Header
            HStack {
                Button(action: {}) {
                    Image(systemName: "line.3.horizontal")
                        .font(.title2)
                }
                Spacer()
                Text("TimeMark Admin")
                    .font(.headline)
                    .foregroundColor(.blue)
                Spacer()
                Image(systemName: "person.crop.circle.fill")
                    .resizable()
                    .frame(width: 35, height: 35)
            }
            .padding()
            
            // Title + Search Section
            VStack(alignment: .leading, spacing: 15) {
                VStack(alignment: .leading, spacing: 5) {
                    Text("Quản lý nhân viên")
                        .font(.title.bold())
                    
                    Text("Tổng cộng \(employees.count) nhân viên")
                        .foregroundColor(.gray)
                }
                
                // Search Bar + Filter Button
                HStack(spacing: 12) {
                    // Ô tìm kiếm
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.gray)
                        
                        TextField("Tìm kiếm nhân viên...", text: $searchText)
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(15) // Bo góc tròn hơn một chút theo ảnh
                    
                    // Nút Filter (Căn lề phải)
                    Button(action: {
                        // Hành động khi nhấn lọc
                    }) {
                        Image(systemName: "line.3.horizontal.decrease")
                            .font(.system(size: 20, weight: .medium))
                            .foregroundColor(Color(.systemGray2))
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(15)
                    }
                }
            }
            .padding(.horizontal)            // List
            ScrollView {
                VStack(spacing: 12) {
                    ForEach(employees) { employee in
                        EmployeeCard(
                            employee: employee,
                            openedID: $openedEmployeeID,
                            onEdit: {
                                print("Edit \(employee.name)")
                            },
                            onLock: {
                                print("Lock \(employee.name)")
                            },
                            onDelete: {
                                employees.removeAll { $0.id == employee.id }
                            }
                        )
                    }
                }
                .padding()
            }
            
            HStack {
                Spacer()
                NavigationLink(destination: AddEmployeeView()) {
                    Image(systemName: "plus")
                        .font(.title.bold())
                        .foregroundColor(.white)
                        .frame(width: 55, height: 55)
                        .background(Color.blue)
                        .clipShape(Circle())
                        .shadow(radius: 4)
                }
                .padding(.trailing, 20)
                .padding(.bottom, 10) }
            
        }
    }
}
