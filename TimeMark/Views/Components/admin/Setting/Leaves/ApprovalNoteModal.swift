//
//  ApprovalNoteModal.swift
//  TimeMark
//
//  Created by Doanh on 4/29/26.
//

import SwiftUI

struct ApprovalNoteModal: View {
    @Binding var noteText: String
    let status: ApprovalStatus
    let onConfirm: () -> Void

    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text(status == .approved
                     ? "Nhập lý do xác nhận"
                     : "Nhập lý do từ chối")
                    .font(.headline)

                TextEditor(text: $noteText)
                    .frame(height: 150)
                    .padding(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.gray.opacity(0.3))
                    )

                Button {
                    onConfirm()
                    dismiss()
                } label: {
                    Text("Xác nhận")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }

                Spacer()
            }
            .padding()
            .navigationTitle("Xác nhận")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
