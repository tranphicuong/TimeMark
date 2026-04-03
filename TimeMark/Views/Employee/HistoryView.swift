//
//  HistoryView.swift
//  TimeMark
//
//  Created by cuong on 26/3/26.
//

import SwiftUI

struct HistoryView: View {

    @State private var selectedMonth = "THÁNG 10, 2023"

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {

                    // FILTER
                    HStack {
                        HStack {
                            Text(selectedMonth)
                                .font(.subheadline)
                                .fontWeight(.medium)
                            Spacer()
                            Image(systemName: "calendar")
                                .foregroundColor(.blue)
                        }
                        .padding()
                        .background(Color(.systemGray5))
                        .cornerRadius(12)

                        Image(systemName: "slider.horizontal.3")
                            .padding()
                            .background(Color(.systemGray5))
                            .cornerRadius(12)
                    }
                    .padding(.horizontal)

                    // TỔNG GIỜ LÀM
                    VStack(alignment: .leading, spacing: 10) {
                        HStack {
                            Text("TỔNG GIỜ LÀM VIỆC")
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.8))
                            Spacer()
                            Image(systemName: "timer")
                                .foregroundColor(.white.opacity(0.8))
                        }
                        Text("168.5 giờ")
                            .font(.largeTitle)
                            .bold()
                            .foregroundColor(.white)
                    }
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(20)
                    .padding(.horizontal)

                    // STATS GRID
                    LazyVGrid(columns: [GridItem(), GridItem()], spacing: 12) {
                        statCard(color: .green,  title: "ĐI LÀM",   value: "22", sub: "Ngày công")
                        statCard(color: .orange, title: "TRỄ/SỚM",  value: "03", sub: "Lần vi phạm")
                        statCard(color: .red,    title: "VẮNG MẶT", value: "01", sub: "Ngày nghỉ")
                        statCard(color: .blue,   title: "TĂNG CA",  value: "12", sub: "Giờ cộng thêm")
                    }
                    .padding(.horizontal)

                    // CHI TIẾT
                    Text("Chi tiết từng ngày")
                        .font(.headline)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal)

                    VStack(spacing: 12) {
                        historyItem(day: "THỨ HAI",  date: "23 Tháng 10", status: "Đúng giờ",  statusColor: .green,  checkIn: "08:00", checkOut: "17:00", total: "8.0h")
                        historyItem(day: "THỨ BA",   date: "24 Tháng 10", status: "Trễ (15p)", statusColor: .orange, checkIn: "08:15", checkOut: "17:05", total: "7.8h")
                        historyItem(day: "THỨ TƯ",   date: "25 Tháng 10", status: "Vắng",      statusColor: .red,    checkIn: "--:--", checkOut: "--:--", total: "0.0h")
                        historyItem(day: "THỨ NĂM",  date: "26 Tháng 10", status: "Đúng giờ",  statusColor: .green,  checkIn: "07:55", checkOut: "18:00", total: "9.0h")
                    }
                    .padding(.horizontal)

                    Spacer(minLength: 30)
                }
                .padding(.top, 8)
            }
            .background(Color(.systemGray6).ignoresSafeArea())
            .navigationTitle("Lịch sử chấm công")
            .navigationBarTitleDisplayMode(.large)
        }
    }

    // MARK: - Stat Card
    @ViewBuilder
    func statCard(color: Color, title: String, value: String, sub: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 6) {
                Circle()
                    .fill(color)
                    .frame(width: 8, height: 8)
                Text(title)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            Text(value)
                .font(.title)
                .bold()
            Text(sub)
                .font(.caption)
                .foregroundColor(.gray)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white)
        .cornerRadius(16)
    }

    // MARK: - History Item
    @ViewBuilder
    func historyItem(day: String, date: String, status: String, statusColor: Color, checkIn: String, checkOut: String, total: String) -> some View {
        VStack(alignment: .leading, spacing: 10) {

            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(day)
                        .font(.caption)
                        .foregroundColor(.gray)
                    Text(date)
                        .font(.headline)
                }
                Spacer()
                Text(status)
                    .font(.caption)
                    .fontWeight(.medium)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(statusColor.opacity(0.15))
                    .foregroundColor(statusColor)
                    .cornerRadius(10)
            }

            Divider()

            HStack {
                VStack(spacing: 2) {
                    Text("VÀO")
                        .font(.caption)
                        .foregroundColor(.gray)
                    Text(checkIn)
                        .fontWeight(.semibold)
                }
                Spacer()
                VStack(spacing: 2) {
                    Text("RA")
                        .font(.caption)
                        .foregroundColor(.gray)
                    Text(checkOut)
                        .fontWeight(.semibold)
                }
                Spacer()
                VStack(spacing: 2) {
                    Text("TỔNG")
                        .font(.caption)
                        .foregroundColor(.gray)
                    Text(total)
                        .fontWeight(.semibold)
                        .foregroundColor(.blue)
                }
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(20)
    }
}
