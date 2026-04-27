import SwiftUI

struct KeyboardView: View {
    let keyboard: [Character: LetterState]
    let onLetter: (Character) -> Void
    let onDelete: () -> Void

    private let rows: [[Character]] = [
        ["Q","W","E","R","T","Y","U","I","O","P"],
        ["A","S","D","F","G","H","J","K","L"],
        ["Z","X","C","V","B","N","M"]
    ]

    var body: some View {
        VStack(spacing: 8) {
            ForEach(rows.indices, id: \.self) { rowIndex in
                HStack(spacing: 6) {
                    if rowIndex == 2 {
                        Spacer(minLength: 0)
                    }
                    ForEach(rows[rowIndex], id: \.self) { letter in
                        KeyButton(
                            label: String(letter),
                            state: keyboard[letter] ?? .empty
                        ) {
                            onLetter(letter)
                        }
                    }
                    if rowIndex == 2 {
                        Spacer(minLength: 0)
                        DeleteButton(onDelete: onDelete)
                    }
                }
            }
        }
        .padding(.horizontal, 8)
        .padding(.bottom, 24)
    }
}

private struct KeyButton: View {
    let label: String
    let state: LetterState
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(label)
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(state == .empty ? Color(.label) : .white)
                .frame(maxWidth: .infinity)
                .frame(height: 58)
                .background(
                    RoundedRectangle(cornerRadius: 6)
                        .fill(state.keyboardBackgroundColor)
                )
        }
    }
}

private struct DeleteButton: View {
    let onDelete: () -> Void

    var body: some View {
        Button(action: onDelete) {
            Image(systemName: "delete.left")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(Color(.label))
                .frame(width: 44, height: 58)
                .background(
                    RoundedRectangle(cornerRadius: 6)
                        .fill(Color(.systemGray4))
                )
        }
    }
}
