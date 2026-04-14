import SwiftUI

struct EmployeeListView: View {
    @State private var searchText = ""
    
    // 👇 QUAN TRỌNG: chỉ lưu 1 thằng đang mở
    @State private var openedEmployeeID: String? = nil
    
    // ❌ BỎ DATA FAKE


    // ✅ DÙNG VIEWMODEL
    @StateObject private var viewModel = EmployeeViewModel()

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
                    
                    // ✅ SỬA COUNT
                    Text("Tổng cộng \(viewModel.employees.count) nhân viên")
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
                    .cornerRadius(15)
                    
                    // Nút Filter
                    Button(action: {
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
            .padding(.horizontal)
            
            // List
            ScrollView {
                VStack(spacing: 12) {
                    
                    // ✅ SỬA FOR EACH
                    ForEach(viewModel.employees) { employee in
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
                                // ❗ TẠM: xóa UI (chưa gọi API)
                                viewModel.employees.removeAll { $0.id == employee.id }
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
                .padding(.bottom, 10)
            }
        }
        
        // ✅ GỌI API Ở ĐÂY
        .onAppear {
            viewModel.fetchEmployees()
        }
    }
}
