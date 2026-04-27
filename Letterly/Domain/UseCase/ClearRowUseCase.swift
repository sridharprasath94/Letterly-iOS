struct ClearRowUseCase {
    func execute(board: [[LetterTile]], row: Int) -> [[LetterTile]] {
        var updated = board
        for col in updated[row].indices {
            updated[row][col] = LetterTile()
        }
        return updated
    }
}
