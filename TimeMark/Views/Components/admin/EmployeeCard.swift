import SwiftUI

import SwiftUI

struct EmployeeCard: View {
    let employee: Employee
    
    // 👇 binding để control global
    @Binding var openedID: String?
    
    var onEdit: () -> Void
    var onLock: () -> Void
    var onDelete: () -> Void
    
    @State private var offset: CGFloat = 0
    
    private let buttonWidth: CGFloat = 70
    private let totalWidth: CGFloat = 210
    
    var body: some View {
        ZStack(alignment: .trailing) {
            
            // Action buttons
            HStack(spacing: 0) {
                ActionButton(icon: "pencil", label: "Sửa", color: .blue) {
                    reset()
                    onEdit()
                }
                .frame(width: buttonWidth)
                
                ActionButton(icon: "lock.fill", label: "Khóa", color: .orange) {
                    reset()
                    onLock()
                }
                .frame(width: buttonWidth)
                
                ActionButton(icon: "trash.fill", label: "Xóa", color: .red) {
                    reset()
                    onDelete()
                }
                .frame(width: buttonWidth)
            }
            .cornerRadius(12)

            
            // Main card
            HStack {
                Image(systemName: employee.imageName)
                    .resizable()
                    .frame(width: 50, height: 50)
                
                VStack(alignment: .leading) {
                    Text(employee.name).bold()
                    Text("\(employee.role) • \(employee.employeeID)")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                Text(employee.status.rawValue)
                    .font(.caption2.bold())
                    .padding(6)
                    .background(employee.status.color.opacity(0.2))
                    .cornerRadius(10)
            }
            .padding()
            .background(Color.white)
            .cornerRadius(12)
            .offset(x: offset)
            .gesture(
                DragGesture()
                    .onChanged { value in
                        let trans = value.translation.width
                        
                        if trans < 0 {
                            // 👇 set thằng đang mở
                            if openedID != employee.id {
                                openedID = employee.id
                            }
                            
                            // 👇 fix crash animation
                            offset = max(trans, -totalWidth)
                        }
                    }
                    .onEnded { value in
                        let shouldOpen = value.translation.width < -100
                        
                        withAnimation(.interactiveSpring()) {
                            if shouldOpen {
                                offset = -totalWidth
                                openedID = employee.id
                            } else {
                                reset()
                            }
                        }
                    }
            )
        }
        .onChange(of: openedID) { oldValue, newValue in
            if newValue != employee.id {
                withAnimation {
                    offset = 0
                }
            }
        }
    }
    
    private func reset() {
        withAnimation {
            offset = 0
            if openedID == employee.id {
                openedID = nil
            }
        }
    }
}
struct ActionButton: View {
    let icon: String
    let label: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 20))
                Text(label)
                    .font(.system(size: 10, weight: .bold))
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(color)
        }
    }
}
