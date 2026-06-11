import SwiftUI

enum LetterState: String, Codable {
    case empty
    case correct
    case present
    case absent

    var backgroundColor: Color {
        switch self {
        case .empty:   return Color(.systemBackground)
        case .correct: return Color(hex: 0x6AAA64)
        case .present: return Color(hex: 0xC9B458)
        case .absent:  return Color(hex: 0x787C7E)
        }
    }

    var textColor: Color {
        switch self {
        case .empty: return Color(.label)
        default:     return .white
        }
    }

    var keyboardBackgroundColor: Color {
        switch self {
        case .empty:   return Color(.systemGray4)
        case .correct: return Color(hex: 0x6AAA64)
        case .present: return Color(hex: 0xC9B458)
        case .absent:  return Color(hex: 0x787C7E)
        }
    }
}

extension Color {
    init(hex: UInt32) {
        let r = Double((hex >> 16) & 0xFF) / 255
        let g = Double((hex >> 8) & 0xFF) / 255
        let b = Double(hex & 0xFF) / 255
        self.init(red: r, green: g, blue: b)
    }
}
