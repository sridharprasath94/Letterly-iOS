import SwiftUI

struct StartView: View {
    private let container = AppContainer.shared

    @State private var navigatingTo: GameMode? = nil
    @State private var pendingMode: GameMode? = nil
    @State private var showResumeAlert = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                Spacer()
                Text("Letterly")
                    .font(.system(size: 48, weight: .bold))
                    .foregroundColor(.accentColor)

                Text("Choose your difficulty")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .padding(.top, 8)

                VStack(spacing: 12) {
                    ForEach(GameMode.allCases) { mode in
                        Button {
                            handleModeTap(mode)
                        } label: {
                            ModeButton(mode: mode)
                        }
                    }
                }
                .padding(.top, 40)
                .padding(.horizontal, 32)

                Spacer()
            }
            .navigationDestination(item: $navigatingTo) { mode in
                GameView(viewModel: container.makeGameViewModel(mode: mode))
            }
            .alert("Resume Previous Game?", isPresented: $showResumeAlert) {
                Button("Resume Game") {
                    navigatingTo = pendingMode
                    pendingMode = nil
                }
                Button("Start New Game", role: .destructive) {
                    if let mode = pendingMode {
                        container.clearGameStateUseCase.execute(mode: mode)
                        navigatingTo = mode
                    }
                    pendingMode = nil
                }
                Button("Cancel", role: .cancel) {
                    pendingMode = nil
                }
            } message: {
                Text("You have an unfinished game in progress.")
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    NavigationLink {
                        StatsView(viewModel: container.makeStatsViewModel())
                    } label: {
                        Image(systemName: "chart.bar.xaxis")
                            .font(.system(size: 17, weight: .medium))
                            .foregroundColor(.primary)
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    NavigationLink {
                        SettingsView()
                    } label: {
                        Image(systemName: "gearshape")
                            .font(.system(size: 17, weight: .medium))
                            .foregroundColor(.primary)
                    }
                }
            }
        }
    }

    private func handleModeTap(_ mode: GameMode) {
        if container.loadGameStateUseCase.execute(mode: mode) != nil {
            pendingMode = mode
            showResumeAlert = true
        } else {
            navigatingTo = mode
        }
    }
}

private struct ModeButton: View {
    let mode: GameMode

    var body: some View {
        Text(mode.displayName.uppercased())
            .font(.system(size: 16, weight: .bold))
            .tracking(1)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(Color.accentColor)
            .foregroundColor(.white)
            .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}
