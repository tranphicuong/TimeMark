import SwiftUI
struct InputField: View {
    let label: String
    let placeholder: String
    @Binding var text: String
    var isEmail: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(label)
                .font(.system(size: 10, weight: .bold))
                .foregroundColor(.blue)

            TextField(placeholder, text: $text)
                .textInputAutocapitalization(isEmail ? .never : .words)
                .autocorrectionDisabled(isEmail)
                .keyboardType(isEmail ? .emailAddress : .default)
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
        }
    }
}

