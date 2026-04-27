enum GameEvent {
    case invalidWord
    case duplicateWord
    case gameWon
    case gameLost(target: String)
    case hintReceived(hints: [String])
    case hintFailed
}
