import SwiftUI

struct HowToPlayView: View {
    var body: some View {
        List {
            Section {
                Text("Guess the hidden word. After each guess, the tiles change colour to show how close you were.")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }

            Section("Tile Colours") {
                TileExampleRow(
                    letter: "A",
                    state: .correct,
                    title: "Correct Position",
                    description: "The letter is in the word and in the correct spot."
                )
                TileExampleRow(
                    letter: "P",
                    state: .present,
                    title: "Wrong Position",
                    description: "The letter is in the word but in the wrong spot."
                )
                TileExampleRow(
                    letter: "X",
                    state: .absent,
                    title: "Not in the Word",
                    description: "This letter is not in the word at all."
                )
            }
        }
        .navigationTitle("How To Play")
        .navigationBarTitleDisplayMode(.large)
    }
}

private struct TileExampleRow: View {
    let letter: Character
    let state: LetterState
    let title: String
    let description: String

    var body: some View {
        HStack(spacing: 16) {
            LetterTileView(tile: LetterTile(letter: letter, state: state))
                .frame(width: 52, height: 52)
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                Text(description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(.vertical, 4)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(String(letter).uppercased()): \(title). \(description)")
    }
}
