import SwiftUI

struct LeaveRequestCard: View {
    let request: LeaveRequest
    var onApprove: () -> Void
    var onReject: () -> Void

    private var statusText: String {
        switch request.status {
        case .pending:
            return "CHỜ DUYỆT"
        case .approved:
            return "ĐÃ DUYỆT"
        case .rejected:
            return "TỪ CHỐI"
        case .cancelled:
            return "ĐÃ HỦY"
        }
    }

    private var statusColor: Color {
        switch request.status {
        case .pending:
            return .blue
        case .approved:
            return .green
        case .rejected:
            return .red
        case .cancelled:
            return .gray
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(alignment: .top, spacing: 12) {

                // Avatar + Status
                ZStack(alignment: .bottom) {
                    Image(systemName: "person.crop.square.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 60, height: 60)
                        .foregroundColor(.orange.opacity(0.8))
                        .background(Color(.systemGray5))
                        .cornerRadius(12)

                    Text(statusText)
                        .font(.system(size: 8, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 4)
                        .padding(.vertical, 2)
                        .background(statusColor)
                        .cornerRadius(4)
                        .offset(y: 4)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(request.user?.name ?? "Unknown")
                        .font(.system(size: 17, weight: .bold))

                    HStack {
                        Image(systemName: "briefcase.fill")
                            .font(.caption2)

                        Text(request.leave_type?.name ?? "N/A")
                            .font(.caption)
                    }
                    .foregroundColor(.secondary)

                    HStack {
                        Image(systemName: "calendar")
                            .font(.caption2)

                        Text("\(request.from_date.formatted) - \(request.to_date.formatted)")
                            .font(.caption.bold())
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .foregroundColor(.blue)
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(6)
                    .padding(.top, 4)
                }

                Spacer()
            }

            // Reason
            Text("\"\(request.reason)\"")
                .font(.system(size: 13))
                .italic()
                .foregroundColor(.secondary)
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color(.systemGray6).opacity(0.5))
                .cornerRadius(12)

            // Action Buttons
            HStack(spacing: 12) {
                Button(action: onApprove) {
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                        Text("Duyệt")
                    }
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(Color.green)
                    .cornerRadius(25)
                }

                Button(action: onReject) {
                    HStack {
                        Image(systemName: "xmark.circle")
                        Text("Từ chối")
                    }
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.red)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 25)
                            .stroke(Color.red.opacity(0.3), lineWidth: 1)
                    )
                }
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(20)
        .shadow(
            color: Color.black.opacity(0.03),
            radius: 10,
            x: 0,
            y: 5
        )
    }
}
