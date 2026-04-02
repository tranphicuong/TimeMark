import SwiftUI

struct LeaveRequestView: View {
    
    @State private var startDate = Date()
    @State private var endDate = Date()
    @State private var reason = ""
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                
                // MARK: Date Section
                VStack(spacing: 15) {
                    
                    HStack(spacing: 15) {
                        
                        dateCard(
                            title: "Ngày bắt đầu",
                            date: startDate
                        )
                        
                        dateCard(
                            title: "Ngày kết thúc",
                            date: endDate
                        )
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(16)
                .padding(.horizontal)
                
                // MARK: Reason
                VStack(alignment: .leading, spacing: 10) {
                    Text("LÝ DO NGHỈ")
                        .font(.caption)
                        .foregroundColor(.gray)
                    
                    TextField("Nhập lý do...", text: $reason, axis: .vertical)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                }
                .padding(.horizontal)
                
                // MARK: Submit Button
                Button {
                    print("Gửi đơn")
                } label: {
                    Text("Gửi yêu cầu")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(14)
                }
                .padding(.horizontal)
                
                Spacer()
            }
            .padding(.top, 20)
        }
    }
}
