import SwiftUI


struct DropdownField: View {
    let label: String
    @Binding var selection: String
    let options: [String]
    
    @State private var isExpanded = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(label)
                .font(.system(size: 10, weight: .bold))
                .foregroundColor(.blue)
            
            VStack(spacing: 0) {
                
                Button(action: {
                    withAnimation {
                        isExpanded.toggle()
                    }
                }) {
                    HStack {
                        Text(selection)
                        Spacer()
                        Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                }
                
                if isExpanded {
                    VStack(spacing: 0) {
                        ForEach(options, id: \.self) { item in
                            Button {
                                selection = item
                                withAnimation {
                                    isExpanded = false
                                }
                            } label: {
                                HStack {
                                    Text(item)
                                    Spacer()
                                    
                                    if selection == item {
                                        Image(systemName: "checkmark")
                                            .foregroundColor(.blue)
                                    }
                                }
                                .padding()
                            }
                            
                            Divider()
                        }
                    }
                    .background(Color.white)
                    .cornerRadius(12)
                    .shadow(radius: 4)
                }
            }
        }
    }
}
