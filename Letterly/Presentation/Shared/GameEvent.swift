enum GameEvent {
    case invalidWord
    case duplicateWord
    case gameWon(guessesUsed: Int, currentStreak: Int, bestStreak: Int)
    case gameLost(target: String, currentStreak: Int, bestStreak: Int)
    case hintReceived(hints: [String])
    case hintFailed
}
