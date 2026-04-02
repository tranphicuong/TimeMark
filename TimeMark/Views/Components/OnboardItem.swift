import SwiftUI

struct OnboardItem: View {
    var title: String
    var desc: String
    var image: String
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: image)
                .font(.system(size: 80))
                .foregroundColor(.blue)
            
            Text(title)
                .font(.title)
                .bold()
            
            Text(desc)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
    }
}
func profileRow(icon: String, title: String, value: String) -> some View {
    HStack(spacing: 12) {
        Image(systemName: icon)
            .foregroundColor(.blue)
            .frame(width: 25)
        
        VStack(alignment: .leading, spacing: 2) {
            Text(title)
                .font(.caption)
                .foregroundColor(.gray)
            
            Text(value)
                .font(.body)
                .fontWeight(.medium)
        }
        
        Spacer()
    }
}
struct PrimaryOutlineButton: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding()
            .background(Color.white)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.gray.opacity(0.3))
            )
            .cornerRadius(12)
            .scaleEffect(configuration.isPressed ? 0.97 : 1)
    }
}

struct DangerButton: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding()
            .foregroundColor(.red)
            .background(Color.red.opacity(0.1))
            .cornerRadius(12)
            .scaleEffect(configuration.isPressed ? 0.97 : 1)
    }
}
func dateCard(title: String, date: Date) -> some View {
    VStack(alignment: .leading, spacing: 8) {
        Text(title)
            .font(.caption)
            .foregroundColor(.gray)
        
        HStack {
            Image(systemName: "calendar")
                .foregroundColor(.blue)
            
            Text(formatDate(date))
                .fontWeight(.medium)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color.white)
        .cornerRadius(12)
    }
}
func formatDate(_ date: Date) -> String {
    let formatter = DateFormatter()
    formatter.dateFormat = "dd/MM/yyyy"
    return formatter.string(from: date)
}
