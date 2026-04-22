import SwiftUI

struct AddDepartmentView: View {
    var onSuccess: (() -> Void)?
    @Environment(\.dismiss) var dismiss

    @State private var name = ""
    @State private var description = ""
    @State private var selectedIcon = "building.2.fill"
    @State private var selectedColor = "gray"
    @State private var isLoading = false

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {

                    // tên phòng ban
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Tên phòng ban")
                            .font(.headline)

                        TextField("Nhập tên phòng ban", text: $name)
                            .padding()
                            .background(Color.gray.opacity(0.08))
                            .cornerRadius(12)
                    }

                    // mô tả
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Mô tả")
                            .font(.headline)

                        TextField("Nhập mô tả phòng ban", text: $description, axis: .vertical)
                            .lineLimit(3...5)
                            .padding()
                            .background(Color.gray.opacity(0.08))
                            .cornerRadius(12)
                    }

                    // chọn icon
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Chọn icon")
                            .font(.headline)

                        LazyVGrid(
                            columns: Array(repeating: GridItem(.flexible()), count: 4),
                            spacing: 12
                        ) {
                            ForEach(DepartmentAssets.icons, id: \.self) { icon in
                                Button {
                                    selectedIcon = icon
                                } label: {
                                    Image(systemName: icon)
                                        .font(.system(size: 24))
                                        .foregroundColor(
                                            selectedIcon == icon
                                            ? colorFromString(selectedColor)
                                            : .gray
                                        )
                                        .frame(maxWidth: .infinity)
                                        .frame(height: 60)
                                        .background(
                                            selectedIcon == icon
                                            ? colorFromString(selectedColor).opacity(0.15)
                                            : Color.gray.opacity(0.08)
                                        )
                                        .cornerRadius(12)
                                }
                            }
                        }
                    }

                    // chọn màu
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Màu icon")
                            .font(.headline)

                        HStack(spacing: 16) {
                            ForEach(DepartmentAssets.colors, id: \.self) { color in
                                Button {
                                    selectedColor = color
                                } label: {
                                    Circle()
                                        .fill(colorFromString(color))
                                        .frame(width: 36, height: 36)
                                        .overlay(
                                            Circle()
                                                .stroke(
                                                    selectedColor == color
                                                    ? Color.black
                                                    : Color.clear,
                                                    lineWidth: 2
                                                )
                                        )
                                }
                            }
                        }
                    }

                    // preview
                    VStack(spacing: 12) {
                        Text("Xem trước")
                            .font(.headline)

                        Image(systemName: selectedIcon)
                            .font(.system(size: 40))
                            .foregroundColor(
                                colorFromString(selectedColor)
                            )

                        Text(name.isEmpty ? "Tên phòng ban" : name)
                            .font(.headline)

                        Text(
                            description.isEmpty
                            ? "Chưa có mô tả"
                            : description
                        )
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.gray.opacity(0.05))
                    .cornerRadius(16)
                }
                .padding()
            }
            .navigationTitle("Tạo phòng ban")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Hủy") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        createDepartment()
                    } label: {
                        if isLoading {
                            LoadingDotsView()
                                .frame(width: 40, height: 20)
                        } else {
                            Text("Xác nhận")
                        }
                    }
                    .disabled(name.isEmpty || isLoading)
                }
            }
        }
    }

    private func createDepartment() {
        isLoading = true

        DepartmentService.shared.createDepartment(
            name: name,
            icon: selectedIcon,
            description: description,
            iconColor: selectedColor
        ) { result in
            DispatchQueue.main.async {
                isLoading = false

                switch result {
                case .success:
                    onSuccess?()
                    dismiss()

                case .failure(let error):
                    print("❌", error.localizedDescription)
                }
            }
        }
    }
}
