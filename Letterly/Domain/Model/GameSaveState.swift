import Foundation

struct GameSaveState: Codable {
    let mode: GameMode
    let targetWord: String
    let board: [[LetterTile]]
    let currentRow: Int
    let currentCol: Int
    let keyboard: [String: LetterState]
    let guesses: [String]
    let hintsUsed: Int
    let receivedHints: [String]
}
