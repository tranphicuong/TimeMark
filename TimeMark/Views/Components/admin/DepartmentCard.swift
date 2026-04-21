import SwiftUI

struct DepartmentCard: View {
    let dept: DepartmentData

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Spacer()

                Image(systemName: "pencil")
                    .foregroundColor(.gray)
            }

            HStack {
                Image(systemName: "person.circle.fill")
                    .resizable()
                    .frame(width: 32, height: 32)
                    .foregroundColor(.gray)

                VStack(alignment: .leading, spacing: 4) {
                    Text("TRƯỞNG PHÒNG")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(.gray)

                    Text(dept.leader?.name ?? "Chưa có")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(
                            dept.leader == nil ? .gray : .primary
                        )
                }
            }
            .padding(10)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.gray.opacity(0.05))
            .cornerRadius(12)

            HStack {
                Text("\(dept.total) nhân sự")
                    .font(.system(size: 13))
                    .foregroundColor(.gray)

                Spacer()

                Text("Chi tiết")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(.blue)
            }
        }
        .padding(20)
        .background(Color.white)
        .cornerRadius(20)
        .shadow(
            color: Color.black.opacity(0.05),
            radius: 10,
            x: 0,
            y: 5
        )
    }
}
