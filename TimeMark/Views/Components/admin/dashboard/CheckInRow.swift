// CheckInRow.swift
import SwiftUI

struct CheckInRow: View {
    let record: AttendanceRecord
    let isExpanded: Bool
    let onTap: () -> Void

    var statusColor: Color {
        switch record.status {
        case "late": return .orange
        case "normal": return .green
        default: return .blue
        }
    }

    var statusLabel: String {
        switch record.status {
        case "late": return "ĐI TRỄ"
        case "normal": return "ĐÚNG GIỜ"
        default: return record.status?.uppercased() ?? "--"
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            // Row chính
            HStack(spacing: 12) {
                ZStack(alignment: .bottomTrailing) {
                    if let url = record.user.avatarURL, let imgURL = URL(string: url) {
                        AsyncImage(url: imgURL) { img in
                            img.resizable().scaledToFill()
                        } placeholder: {
                            Image(systemName: "person.circle.fill")
                                .resizable()
                                .foregroundColor(.gray.opacity(0.5))
                        }
                        .frame(width: 45, height: 45)
                        .clipShape(Circle())
                    } else {
                        Image(systemName: "person.circle.fill")
                            .resizable()
                            .frame(width: 45, height: 45)
                            .foregroundColor(.gray.opacity(0.5))
                    }

                    Circle()
                        .fill(statusColor)
                        .frame(width: 12, height: 12)
                        .overlay(Circle().stroke(Color.white, lineWidth: 2))
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text(record.user.name)
                        .font(.system(size: 15, weight: .semibold))
                    Text(record.user.department ?? "--")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 2) {
                    Text(DashboardViewModel.formatTimestamp(record.check_in))
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(statusColor)
                    Text(statusLabel)
                        .font(.system(size: 9, weight: .bold))
                        .foregroundColor(.secondary)
                }

                Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding()
            .contentShape(Rectangle())
            .onTapGesture { onTap() }

            // Chi tiết expand
            if isExpanded {
                VStack(alignment: .leading, spacing: 10) {
                    Divider()

                    Group {
                        DetailRow(icon: "briefcase.fill", label: "Chức vụ", value: record.user.position ?? "--")
                        DetailRow(icon: "building.2.fill", label: "Phòng ban", value: record.user.department ?? "--")
                        DetailRow(icon: "envelope.fill", label: "Email", value: record.user.email ?? "--")
                        DetailRow(icon: "clock.fill", label: "Check-in", value: DashboardViewModel.formatTimestamp(record.check_in))
                        DetailRow(icon: "clock.badge.checkmark.fill", label: "Check-out", value: DashboardViewModel.formatTimestamp(record.check_out))

                        if let late = record.late_minutes, late > 0 {
                            DetailRow(icon: "exclamationmark.triangle.fill", label: "Trễ", value: "\(late) phút", valueColor: .orange)
                        }
                        if let ot = record.overtime_minutes, ot > 0 {
                            DetailRow(icon: "star.fill", label: "Tăng ca", value: "\(ot) phút", valueColor: .blue)
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 12)
            }
        }
        .background(Color(.systemGray6).opacity(0.5))
        .cornerRadius(15)
        .animation(.easeInOut(duration: 0.2), value: isExpanded)
    }
}

struct DetailRow: View {
    let icon: String
    let label: String
    let value: String
    var valueColor: Color = .primary

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .foregroundColor(.blue)
                .frame(width: 20)
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .font(.caption.bold())
                .foregroundColor(valueColor)
        }
    }
}
