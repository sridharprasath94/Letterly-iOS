import SwiftUI
import Combine

struct GameView: View {
    @StateObject var viewModel: GameViewModel
    @Environment(\.dismiss) private var dismiss

    @State private var showLeaveAlert = false
    @State private var endGameResult: EndGameResult? = nil
    @State private var showHintDialog = false
    @State private var hintDialogHints: [String] = []
    @State private var hintDialogRemaining: Int = 0
    @State private var toast: String? = nil

    var body: some View {
        ZStack(alignment: .topLeading) {
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

            Button {
                if viewModel.gameStatus == .continueGame {
                    showLeaveAlert = true
                } else {
                    dismiss()
                }
            } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(.primary)
                    .padding(12)
                    .background(Color(.systemGray5).opacity(0.8))
                    .clipShape(Circle())
            }
            .padding(.leading, 16)
            .padding(.top, 8)
        }
        .navigationBarHidden(true)
        .alert("Leave game?", isPresented: $showLeaveAlert) {
            Button("Leave", role: .destructive) { dismiss() }
            Button("Stay", role: .cancel) { }
        } message: {
            Text("Your current game will be lost.")
        }
        .overlay {
            if let result = endGameResult {
                EndGameView(
                    result: result,
                    onNewGame: {
                        endGameResult = nil
                        viewModel.resetGame()
                    },
                    onBack: {
                        endGameResult = nil
                        dismiss()
                    }
                )
                .transition(.opacity)
            }
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
        .animation(.easeInOut(duration: 0.2), value: endGameResult != nil)
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
        case .gameWon(let guesses, let streak, let best):
            endGameResult = .won(guessesUsed: guesses, currentStreak: streak, bestStreak: best)
        case .gameLost(let target, let streak, let best):
            endGameResult = .lost(target: target, currentStreak: streak, bestStreak: best)
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
