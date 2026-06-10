import SwiftUI

struct StartView: View {
    private let container = AppContainer.shared

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
                        NavigationLink {
                            GameView(viewModel: container.makeGameViewModel(mode: mode))
                        } label: {
                            ModeButton(mode: mode)
                        }
                    }
                }
                .padding(.top, 40)
                .padding(.horizontal, 32)

                Spacer()
            }
            .toolbar {
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
