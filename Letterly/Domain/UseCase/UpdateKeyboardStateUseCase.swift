struct UpdateKeyboardStateUseCase {
    func execute(
        keyboard: [Character: LetterState],
        guess: String,
        states: [LetterState]
    ) -> [Character: LetterState] {
        var updated = keyboard
        for (index, state) in states.enumerated() {
            let letter = Character(guess[guess.index(guess.startIndex, offsetBy: index)].uppercased())
            let existing = updated[letter]
            let newState: LetterState
            switch existing {
            case .correct:
                newState = .correct
            case .present:
                newState = (state == .absent) ? .present : state
            default:
                newState = state
            }
            updated[letter] = newState
        }
        return updated
    }
}
