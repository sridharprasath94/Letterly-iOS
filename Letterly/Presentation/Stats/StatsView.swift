import SwiftUI

struct StatsView: View {
    @StateObject private var viewModel: StatsViewModel
    @State private var showResetConfirmation = false

    init(viewModel: StatsViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        List {
            Section {
                statRow("Games Played", value: "\(viewModel.stats.gamesPlayed)")
                statRow("Games Won",    value: "\(viewModel.stats.gamesWon)")
                statRow("Win %",        value: String(format: "%.0f%%", viewModel.stats.winPercentage))
            }
            Section("Streaks") {
                statRow("Current Streak", value: "\(viewModel.stats.currentStreak)")
                statRow("Best Streak",    value: "\(viewModel.stats.bestStreak)")
            }
            Section {
                Button(role: .destructive) {
                    showResetConfirmation = true
                } label: {
                    Label("Reset Statistics", systemImage: "trash")
                }
            }
        }
        .navigationTitle("Statistics")
        .navigationBarTitleDisplayMode(.large)
        .onAppear { viewModel.reload() }
        .confirmationDialog(
            "Reset all statistics?",
            isPresented: $showResetConfirmation,
            titleVisibility: .visible
        ) {
            Button("Reset Statistics", role: .destructive) {
                viewModel.resetStats()
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("This action cannot be undone.")
        }
    }

    private func statRow(_ label: String, value: String) -> some View {
        HStack {
            Text(label)
                .foregroundColor(.primary)
            Spacer()
            Text(value)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.accentColor)
        }
    }
}
