struct EvaluateGuessUseCase {
    func execute(guess: String, target: String) -> GuessResult {
        let guessChars = Array(guess.lowercased())
        var targetChars = Array(target.lowercased())
        var result = Array(repeating: LetterState.absent, count: guessChars.count)
        var processedGuess = guessChars

        // Pass 1: correct positions
        for i in guessChars.indices {
            if processedGuess[i] == targetChars[i] {
                result[i] = .correct
                targetChars[i] = "*"
                processedGuess[i] = "#"
            }
        }

        // Pass 2: present but wrong position
        for i in processedGuess.indices {
            if result[i] == .correct { continue }
            if let index = targetChars.firstIndex(of: processedGuess[i]) {
                result[i] = .present
                targetChars[index] = "*"
            }
        }

        return GuessResult(guess: guess, states: result)
    }
}
