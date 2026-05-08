import SwiftUI
import Foundation

func colorFromString(_ color: String?) -> Color {
    switch color?.lowercased() {
    case "blue":
        return .blue
    case "red":
        return .red
    case "green":
        return .green
    case "orange":
        return .orange
    case "gray":
        return .gray
    default:
        return .gray
    }
}

