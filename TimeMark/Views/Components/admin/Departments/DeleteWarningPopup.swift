//
//  DeleteWarningPopup.swift
//  TimeMark
//
//  Created by Doanh on 4/22/26.
//

import SwiftUI

struct DeleteWarningPopup: View {
    let message: String
    let action: () -> Void

    var body: some View {
        VStack(spacing: 20) {
            Capsule()
                .frame(width: 40, height: 5)
                .foregroundColor(.gray.opacity(0.4))
                .padding(.top, 8)

            Image(systemName: "exclamationmark.triangle.fill")
                .font(.largeTitle)
                .foregroundColor(.orange)

            Text("Không thể xóa!")
                .font(.headline)

            Text(message)
                .multilineTextAlignment(.center)
                .foregroundColor(.gray)

            Button {
                action()
            } label: {
                Text("Đã hiểu")
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(.blue)
                    .foregroundColor(.white)
                    .cornerRadius(16)
            }

            Spacer()
        }
        .padding()
        .presentationDetents([.height(260)])
        .presentationCornerRadius(30)
    }
}
