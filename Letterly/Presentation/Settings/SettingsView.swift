import SwiftUI

struct SettingsView: View {
    @AppStorage("soundEffectsEnabled") private var soundEffectsEnabled = true
    @AppStorage("hapticFeedbackEnabled") private var hapticFeedbackEnabled = true

    var body: some View {
        List {
            Section {
                Toggle("Sound Effects", isOn: $soundEffectsEnabled)
                Toggle("Haptic Feedback", isOn: $hapticFeedbackEnabled)
            }
        }
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.large)
    }
}
