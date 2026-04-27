struct LetterTile: Equatable {
    var letter: Character?
    var state: LetterState = .empty

    static func == (lhs: LetterTile, rhs: LetterTile) -> Bool {
        lhs.letter == rhs.letter && lhs.state == rhs.state
    }
}

extension LetterState: Equatable {}

func createBoard(wordLength: Int, maxGuesses: Int) -> [[LetterTile]] {
    Array(repeating: Array(repeating: LetterTile(), count: wordLength), count: maxGuesses)
}
