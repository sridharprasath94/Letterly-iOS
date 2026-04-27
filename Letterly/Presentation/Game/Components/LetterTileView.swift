import SwiftUI

struct LetterTileView: View {
    let tile: LetterTile

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 4)
                .fill(tile.state.backgroundColor)
            RoundedRectangle(cornerRadius: 4)
                .strokeBorder(borderColor, lineWidth: 2)
            if let letter = tile.letter {
                Text(String(letter).uppercased())
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(tile.state.textColor)
            }
        }
        .aspectRatio(1, contentMode: .fit)
    }

    private var borderColor: Color {
        switch tile.state {
        case .empty:
            return tile.letter == nil
                ? Color(hex: 0xC5C8BA)   // Android outlineVariant
                : Color(hex: 0x878787)   // Android darkened border when letter typed
        default:
            return .clear
        }
    }
}
