import SwiftUI

struct BoardView: View {
    let board: [[LetterTile]]

    var body: some View {
        VStack(spacing: 6) {
            ForEach(board.indices, id: \.self) { row in
                HStack(spacing: 6) {
                    ForEach(board[row].indices, id: \.self) { col in
                        LetterTileView(tile: board[row][col])
                    }
                }
            }
        }
        .padding(.horizontal, 24)
    }
}
