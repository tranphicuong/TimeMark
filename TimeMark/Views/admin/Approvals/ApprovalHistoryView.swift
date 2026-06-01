//
//  ApprovalHistorySheet.swift
//  TimeMark
//
//  Created by Rebel on 6/2/26.
//
import SwiftUI
struct ApprovalHistorySheet: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = ApprovalListViewModel()

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header
                HStack {
                    Button(action: { dismiss() }) {
                        HStack(spacing: 6) {
                            Image(systemName: "chevron.left")
                            Text("Quay lại")
                        }
                        .foregroundColor(.blue)
                    }
                    Spacer()
                    Text("Lịch sử phê duyệt")
                        .font(.system(size: 17, weight: .bold))
                    Spacer()
                    // Cân bằng layout
                    HStack(spacing: 6) {
                        Image(systemName: "chevron.left")
                        Text("Quay lại")
                    }
                    .opacity(0)
                }
                .padding()
                .background(Color.white)
                .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)

                if viewModel.isLoadingHistory {
                    Spacer()
                    ProgressView("Đang tải...")
                    Spacer()
                } else if viewModel.histories.isEmpty {
                    Spacer()
                    VStack(spacing: 12) {
                        Image(systemName: "clock.arrow.circlepath")
                            .font(.system(size: 48))
                            .foregroundColor(.gray.opacity(0.4))
                        Text("Chưa có lịch sử phê duyệt")
                            .foregroundColor(.gray)
                    }
                    Spacer()
                } else {
                    ScrollView {
                        VStack(spacing: 12) {
                            ForEach(viewModel.histories) { history in
                                HistoryCard(history: history)
                            }
                        }
                        .padding()
                    }
                }
            }
            .background(Color(uiColor: .systemGroupedBackground))
            .navigationBarHidden(true)
        }
        .onAppear {
            viewModel.fetchHistory()
        }
    }
}

// MARK: - History Card
struct HistoryCard: View {
    let history: LeaveHistory

    private var actionColor: Color {
        history.action == "approved" ? .green : .red
    }

    private var actionIcon: String {
        history.action == "approved" ? "checkmark.circle.fill" : "xmark.circle.fill"
    }

    private var actionText: String {
        history.action == "approved" ? "Đã duyệt" : "Từ chối"
    }

    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy HH:mm"
        formatter.timeZone = TimeZone(identifier: "Asia/Ho_Chi_Minh")
        return formatter.string(from: history.created_at.date)
    }

    private func formatTimestamp(_ ts: FirestoreTimestamp) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy"
        formatter.timeZone = TimeZone(identifier: "Asia/Ho_Chi_Minh")
        return formatter.string(from: ts.date)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {

            // Top color bar
            HStack {
                Image(systemName: actionIcon)
                Text(actionText)
                    .font(.system(size: 13, weight: .bold))
                Spacer()
                Text(formattedDate)
                    .font(.system(size: 11))
                    .opacity(0.85)
            }
            .foregroundColor(.white)
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(actionColor.gradient)
            .cornerRadius(16, corners: [.topLeft, .topRight])

            // Body
            VStack(alignment: .leading, spacing: 12) {

                // Người xin + ngày
                HStack(alignment: .top, spacing: 12) {
                    ZStack {
                        Circle()
                            .fill(actionColor.opacity(0.1))
                            .frame(width: 40, height: 40)
                        Image(systemName: "person.fill")
                            .foregroundColor(actionColor)
                    }

                    VStack(alignment: .leading, spacing: 4) {
                        Text(history.user_name ?? "Không rõ")
                            .font(.system(size: 15, weight: .bold))

                        if let from = history.from_date, let to = history.to_date {
                            HStack(spacing: 4) {
                                Image(systemName: "calendar")
                                    .font(.system(size: 11))
                                Text("\(formatTimestamp(from)) → \(formatTimestamp(to))")
                                    .font(.system(size: 12, weight: .medium))
                            }
                            .foregroundColor(.blue)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.blue.opacity(0.08))
                            .cornerRadius(8)
                        }
                    }
                }

                // Divider
                if let note = history.note, !note.isEmpty {
                    Divider()

                    HStack(alignment: .top, spacing: 8) {
                        Image(systemName: "text.bubble.fill")
                            .font(.system(size: 12))
                            .foregroundColor(.gray)
                        Text(note)
                            .font(.system(size: 13))
                            .foregroundColor(.secondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
            }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading) // ← thêm vào đây
            .background(Color.white)
            .cornerRadius(16, corners: [.bottomLeft, .bottomRight])
        }
    }
    
}

// Helper: bo góc từng phía
extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat
    var corners: UIRectCorner

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}
