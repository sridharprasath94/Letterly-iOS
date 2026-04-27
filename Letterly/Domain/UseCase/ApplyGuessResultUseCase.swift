struct ApplyGuessResultUseCase {
    func execute(board: [[LetterTile]], row: Int, states: [LetterState]) -> [[LetterTile]] {
        var updated = board
        for (index, state) in states.enumerated() {
            updated[row][index] = LetterTile(
                letter: updated[row][index].letter,
                state: state
            )
        }
        return updated
    }
}
