struct LetterTile: Equatable {
    var letter: Character?
    var state: LetterState = .empty

    static func == (lhs: LetterTile, rhs: LetterTile) -> Bool {
        lhs.letter == rhs.letter && lhs.state == rhs.state
    }
}

extension LetterTile: Codable {
    private enum CodingKeys: String, CodingKey { case letter, state }

    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let letterStr = try container.decodeIfPresent(String.self, forKey: .letter)
        letter = letterStr.flatMap(\.first)
        state = try container.decode(LetterState.self, forKey: .state)
    }

    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(letter.map(String.init), forKey: .letter)
        try container.encode(state, forKey: .state)
    }
}

func createBoard(wordLength: Int, maxGuesses: Int) -> [[LetterTile]] {
    Array(repeating: Array(repeating: LetterTile(), count: wordLength), count: maxGuesses)
}
