import SwiftUI
import Combine

struct GameView: View {
    @StateObject var viewModel: GameViewModel
    @Environment(\.dismiss) private var dismiss

    @State private var showLeaveAlert = false
    @State private var showGameOverAlert = false
    @State private var showHintDialog = false
    @State private var hintDialogHints: [String] = []
    @State private var hintDialogRemaining: Int = 0
    @State private var toast: String? = nil
    @State private var gameOverEvent: GameEvent? = nil

    var body: some View {
        VStack(spacing: 0) {
            header
            Spacer(minLength: 16)
            BoardView(board: viewModel.board)
            Spacer(minLength: 24)
            KeyboardView(
                keyboard: viewModel.keyboard,
                onLetter: { viewModel.addLetter($0) },
                onDelete: { viewModel.removeLetter() }
            )
        }
        .navigationBarBackButtonHidden()
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    if viewModel.gameStatus == .continueGame {
                        showLeaveAlert = true
                    } else {
                        dismiss()
                    }
                } label: {
                    Image(systemName: "chevron.left")
                }
            }
        }
        .alert("Leave game?", isPresented: $showLeaveAlert) {
            Button("Leave", role: .destructive) { dismiss() }
            Button("Stay", role: .cancel) {}
        } message: {
            Text("Your current game will be lost.")
        }
        .alert(gameOverTitle, isPresented: $showGameOverAlert) {
            Button("Play Again") { viewModel.resetGame() }
            Button("Back", role: .cancel) { dismiss() }
        } message: {
            Text(gameOverMessage)
        }
        .overlay {
            if showHintDialog {
                HintDialogView(
                    hints: hintDialogHints,
                    remaining: hintDialogRemaining,
                    onGetNextHint: {
                        showHintDialog = false
                        viewModel.requestHint()
                    },
                    onDismiss: {
                        showHintDialog = false
                    }
                )
                .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.2), value: showHintDialog)
        .overlay(alignment: .bottom) {
            if let message = toast {
                ToastView(message: message)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                    .padding(.bottom, 100)
            }
        }
        .onReceive(viewModel.eventPublisher) { event in
            handleEvent(event)
        }
        .onAppear {
            if viewModel.board.isEmpty {
                viewModel.startGame()
            }
        }
    }

    private var header: some View {
        VStack(spacing: 4) {
            Text(viewModel.mode.displayName.uppercased())
                .font(.system(size: 28, weight: .bold))
            Text("\(viewModel.mode.wordLength) letters · \(viewModel.mode.maxGuesses) guesses")
                .font(.subheadline)
                .foregroundColor(.secondary)
            HintButtonView(
                hintsUsed: viewModel.hintsUsed,
                maxHints: viewModel.mode.maxHints,
                isLoading: viewModel.hintState == .loading
            ) {
                onHintTapped()
            }
            .padding(.top, 4)
        }
        .padding(.top, 16)
    }

    private var gameOverTitle: String {
        guard let event = gameOverEvent else { return "" }
        switch event {
        case .gameWon:  return "You won! 🎉"
        case .gameLost: return "You lost! 😢"
        default:        return ""
        }
    }

    private var gameOverMessage: String {
        guard let event = gameOverEvent else { return "" }
        switch event {
        case .gameWon:             return "Play again?"
        case .gameLost(let word):  return "The word was: \(word.uppercased())\nPlay again?"
        default:                   return ""
        }
    }

    private func onHintTapped() {
        if viewModel.receivedHints.isEmpty {
            viewModel.requestHint()
        } else {
            hintDialogHints = viewModel.receivedHints
            hintDialogRemaining = viewModel.mode.maxHints - viewModel.hintsUsed
            showHintDialog = true
        }
    }

    private func handleEvent(_ event: GameEvent) {
        switch event {
        case .invalidWord:
            showToast("Word not in dictionary")
        case .duplicateWord:
            showToast("Word already guessed")
        case .gameWon, .gameLost:
            gameOverEvent = event
            showGameOverAlert = true
        case .hintReceived(let hints):
            hintDialogHints = hints
            hintDialogRemaining = viewModel.mode.maxHints - viewModel.hintsUsed
            showHintDialog = true
        case .hintFailed:
            showToast("Could not load hint. Try again.")
        }
    }

    private func showToast(_ message: String) {
        withAnimation { toast = message }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
            withAnimation { toast = nil }
        }
    }
}

private struct ToastView: View {
    let message: String

    var body: some View {
        Text(message)
            .font(.subheadline.weight(.medium))
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(Color(.label).opacity(0.85))
            .foregroundColor(Color(.systemBackground))
            .clipShape(Capsule())
    }
}
