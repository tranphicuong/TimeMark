	//
//  AddDepartmentView.swift
//  TimeMark
//
//  Created by Rebel on 4/21/26.
//
import SwiftUI
struct AddDepartmentView: View {
    @Environment(\.dismiss) var dismiss
    
    @State private var name = ""
    @State private var description = ""
    @State private var manager = ""
    
    var body: some View {
        NavigationView {
            Form {
                TextField("Tên phòng ban", text: $name)
                TextField("Mô tả", text: $description)
                TextField("Trưởng phòng", text: $manager)
            }
            .navigationTitle("Tạo phòng ban")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Hủy") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Xác nhận") {
                        // 👉 CALL API HERE
                        print("Create Department:", name)
                        dismiss()
                    }
                }
            }
        }
    }
}
