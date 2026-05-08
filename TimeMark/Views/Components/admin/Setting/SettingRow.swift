import SwiftUI

struct SettingRow: View {
    let icon: String
    let iconColor: Color
    let iconBgColor: Color
    let title: String
    var isDestructive: Bool = false
    
    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(iconBgColor)
                    .frame(width: 40, height: 40)
                
                Image(systemName: icon)
                    .foregroundColor(iconColor)
                    .font(.system(size: 18))
            }
            
            Text(title)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(isDestructive ? .red : .primary)
            
            Spacer()
            
            if !isDestructive {
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.gray.opacity(0.5))
            }
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 16)
        .background(Color.white)
    }
}
