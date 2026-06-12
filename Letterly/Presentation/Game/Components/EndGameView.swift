import SwiftUI

enum EndGameResult {
    case won(guessesUsed: Int, currentStreak: Int, bestStreak: Int)
    case lost(target: String, currentStreak: Int, bestStreak: Int)
}

struct EndGameView: View {
    let result: EndGameResult
    let onNewGame: () -> Void
    let onBack: () -> Void

    var body: some View {
        ZStack {
            Color.black.opacity(0.4)
                .ignoresSafeArea()

            VStack(spacing: 0) {
                VStack(spacing: 8) {
                    Text(title)
                        .font(.title2.weight(.bold))
                        .multilineTextAlignment(.center)

                    if let subtitle = subtitle {
                        Text(subtitle)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                }
                .padding(.bottom, 20)

                Divider()

                VStack(spacing: 12) {
                    ForEach(stats, id: \.label) { stat in
                        statRow(stat.label, value: stat.value)
                    }
                }
                .padding(.vertical, 16)

                Divider()

                VStack(spacing: 0) {
                    Button(action: onNewGame) {
                        Text("New Game")
                            .frame(maxWidth: .infinity)
                            .font(.body.weight(.semibold))
                            .foregroundColor(.accentColor)
                            .padding(.vertical, 14)
                    }

                    Divider()

                    Button(action: onBack) {
                        Text("Back")
                            .frame(maxWidth: .infinity)
                            .font(.body)
                            .foregroundColor(.primary)
                            .padding(.vertical, 14)
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)
            .background(.regularMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .padding(.horizontal, 40)
            .shadow(color: .black.opacity(0.3), radius: 20)
        }
    }

    private var title: String {
        switch result {
        case .won: return "You won! 🎉"
        case .lost: return "You lost! 😢"
        }
    }

    private var subtitle: String? {
        switch result {
        case .won(let guesses, _, _):
            return "Solved in \(guesses) \(guesses == 1 ? "guess" : "guesses")"
        case .lost(let target, _, _):
            return "The word was \(target.uppercased())"
        }
    }

    private struct StatRow {
        let label: String
        let value: String
    }

    private var stats: [StatRow] {
        switch result {
        case .won(_, let current, let best):
            return [
                StatRow(label: "Current Streak", value: "\(current)"),
                StatRow(label: "Best Streak",    value: "\(best)")
            ]
        case .lost(_, let current, let best):
            return [
                StatRow(label: "Current Streak", value: "\(current)"),
                StatRow(label: "Best Streak",    value: "\(best)")
            ]
        }
    }

    private func statRow(_ label: String, value: String) -> some View {
        HStack {
            Text(label)
                .font(.subheadline)
                .foregroundColor(.primary)
            Spacer()
            Text(value)
                .font(.subheadline.weight(.semibold))
                .foregroundColor(.accentColor)
        }
    }
}
