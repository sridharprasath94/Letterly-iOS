struct CheckDuplicateGuessUseCase {
    func execute(guess: String, guesses: [String]) -> Bool {
        guesses.contains { $0.lowercased() == guess.lowercased() }
    }
}
