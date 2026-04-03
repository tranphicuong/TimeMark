import SwiftUI
struct FilterButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 13, weight: isSelected ? .bold : .medium))
                .foregroundColor(isSelected ? .blue : .secondary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                .background(isSelected ? Color.white : Color.clear)
                .cornerRadius(10)
                .shadow(color: isSelected ? Color.black.opacity(0.05) : Color.clear, radius: 4)
        }
    }
}
