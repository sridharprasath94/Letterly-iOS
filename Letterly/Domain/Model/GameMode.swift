enum GameMode: String, CaseIterable, Identifiable {
    case classic
    case advanced
    case expert

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .classic:  return "Classic"
        case .advanced: return "Advanced"
        case .expert:   return "Expert"
        }
    }

    var wordLength: Int {
        switch self {
        case .classic:  return 5
        case .advanced: return 6
        case .expert:   return 7
        }
    }

    var maxGuesses: Int {
        switch self {
        case .classic:  return 6
        case .advanced: return 7
        case .expert:   return 8
        }
    }

    var maxHints: Int {
        switch self {
        case .classic:  return 1
        case .advanced: return 2
        case .expert:   return 3
        }
    }
}
