struct CheckGameStatusUseCase {
    func execute(guesses: [String], targetWord: String, maxGuesses: Int) -> GameStatus {
        if guesses.last?.lowercased() == targetWord.lowercased() {
            return .win
        }
        if guesses.count >= maxGuesses {
            return .lose
        }
        return .continueGame
    }
}
