//
//  AddPositionView.swift
//  TimeMark
//
//  Created by Rebel on 4/21/26.
//
import SwiftUI

struct AddPositionView: View {
    @Environment(\.dismiss) var dismiss
    
    @State private var name = ""
    @State private var description = ""
    @State private var level = ""
    
    var body: some View {
        NavigationView {
            Form {
                TextField("Tên chức danh", text: $name)
                TextField("Mô tả", text: $description)
                TextField("Level", text: $level)
            }
            .navigationTitle("Tạo chức danh")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Hủy") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Xác nhận") {
                        // 👉 CALL API HERE
                        print("Create Position:", name)
                        dismiss()
                    }
                }
            }
        }
    }
}
