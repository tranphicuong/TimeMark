import SwiftUI

struct DepartmentDetailView: View {
    let department: DepartmentData
    
    var onDeleteSuccess: (() -> Void)?
    @Environment(\.dismiss) var dismiss
    
    @State private var openedCardID: String?
    @State private var showDeleteConfirm = false
    @State private var showDeleteWarning = false
    
    //loading delete
    @State private var isDeleting = false
    @State private var errorMessage: String?
    private func deleteDepartment() {
        isDeleting = true
        showDeleteConfirm = false

        DepartmentService.shared.deleteDepartment(
            id: department.department_id
        ) { result in
            DispatchQueue.main.async {
                isDeleting = false

                switch result {
                case .success:
                    onDeleteSuccess?()
                    dismiss()

                case .failure(let error):
                    errorMessage = error.localizedDescription
                    showDeleteWarning = true
                }
            }
        }
    }
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                
                // MARK: Header
                HStack {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "chevron.left")
                            .font(.title3)
                            .foregroundColor(.black)
                    }
                    
                    Spacer()
                    //tên phòng ban
                    Text(department.department_name)
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    Spacer()
                    
                    
                }
                .padding()
                .background(.white)
                
                // MARK: Content
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        
                        // thêm nhân sự
                        Button {
                            print("Thêm nhân sự")
                        } label: {
                            HStack {
                                Image(systemName: "plus")
                                Text("Thêm nhân sự mới")
                            }
                            .foregroundColor(.blue)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(
                                        style: StrokeStyle(
                                            lineWidth: 1,
                                            dash: [5]
                                        )
                                    )
                                    .foregroundColor(.blue.opacity(0.4))
                            )
                        }
                        
                        // trưởng phòng
                        if let leader = department.leader {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("TRƯỞNG PHÒNG")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                                
                                EmployeeCard(
                                    employee: Employee(
                                        id: leader.uid,
                                        email: leader.email,
                                        name: leader.name,
                                        id_member: "TM-0001",
                                        position: "Trưởng phòng",
                                        department: department.department_name,
                                        status: .active,
                                        imageName: leader.avatarURL ?? "person.circle.fill"
                                    ),
                                    openedID: $openedCardID,
                                    onEdit: {
                                        print("Sửa trưởng phòng")
                                    },
                                    onLock: {
                                        print("Khóa trưởng phòng")
                                    },
                                    onDelete: {
                                        print("Xóa trưởng phòng")
                                    }
                                )
                            }
                        }
                        
                        // thành viên
                        VStack(alignment: .leading, spacing: 12) {
                            Text("THÀNH VIÊN (\(department.users.count))")
                                .font(.caption)
                                .foregroundColor(.gray)
                            
                            if department.users.isEmpty {
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(.white)
                                    .frame(height: 100)
                                    .overlay(
                                        Text("Chưa có nhân viên nào")
                                            .italic()
                                            .foregroundColor(.gray)
                                    )
                            } else {
                                ForEach(department.users) { user in
                                    EmployeeCard(
                                        employee: user.toEmployee,
                                        openedID: $openedCardID,
                                        onEdit: {
                                            print("Sửa \(user.name)")
                                        },
                                        onLock: {
                                            print("Khóa \(user.name)")
                                        },
                                        onDelete: {
                                            print("Xóa \(user.name)")
                                        }
                                    )
                                }
                            }
                        }
                        
                        // xóa phòng ban
                        Button {
                            showDeleteConfirm = true
                        }label: {
                            HStack {
                                Image(systemName: "trash")
                                Text("Xóa phòng ban")
                            }
                            .foregroundColor(.red)
                            .frame(maxWidth: .infinity)
                            .frame(height: 55)
                            .background(Color.red.opacity(0.08))
                            .cornerRadius(16)
                        }
                        .padding(.top, 30)
                    }
                    .padding()
                }
                .background(Color(.systemGray6))
            }
        }
        .navigationBarBackButtonHidden(true)
        .sheet(isPresented: $showDeleteConfirm) {
            DeleteConfirmPopup(
                title: "Xác nhận xóa",
                message: "Bạn có chắc muốn xóa phòng ban này?"
            ) {
                showDeleteConfirm = false
                deleteDepartment()
            } cancelAction: {
                showDeleteConfirm = false
            }
        }
        .sheet(isPresented: $showDeleteWarning) {
            DeleteWarningPopup(
                message: errorMessage ?? "Phòng ban vẫn còn nhân sự"
            ) {
                showDeleteWarning = false
            }
        }
    }
    
}

