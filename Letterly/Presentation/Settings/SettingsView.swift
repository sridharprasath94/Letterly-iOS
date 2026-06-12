import SwiftUI

struct SettingsView: View {
    @AppStorage("soundEffectsEnabled") private var soundEffectsEnabled = true
    @AppStorage("hapticFeedbackEnabled") private var hapticFeedbackEnabled = true
    @Environment(\.openURL) private var openURL

    private let container = AppContainer.shared

    var body: some View {
        List {
            Section("Gameplay") {
                Toggle(isOn: $soundEffectsEnabled) {
                    Label("Sound Effects", systemImage: "speaker.wave.2")
                }
                Toggle(isOn: $hapticFeedbackEnabled) {
                    Label("Haptic Feedback", systemImage: "hand.tap")
                }
            }

            Section("Help") {
                NavigationLink {
                    HowToPlayView()
                } label: {
                    Label("How To Play", systemImage: "questionmark.circle")
                }
            }

            Section("Statistics") {
                NavigationLink {
                    StatsView(viewModel: container.makeStatsViewModel())
                } label: {
                    Label("Statistics", systemImage: "chart.bar.xaxis")
                }
            }

            Section("Support") {
                Button {
                    openURL(AppConfiguration.appStoreURL)
                } label: {
                    Label("Rate App", systemImage: "star")
                }
                ShareLink(
                    item: AppConfiguration.appStoreURL,
                    subject: Text("Try Letterly"),
                    message: Text("Check out Letterly – a fun word puzzle game!")
                ) {
                    Label("Share App", systemImage: "square.and.arrow.up")
                }
            }

            Section("About") {
                NavigationLink {
                    AboutView()
                } label: {
                    Label("About", systemImage: "info.circle")
                }
            }
        }
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.large)
    }
}
