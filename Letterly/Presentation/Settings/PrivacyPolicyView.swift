import SwiftUI

struct PrivacyPolicyView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                policySection(
                    title: "Effective Date",
                    body: "June 11, 2026"
                )
                policySection(
                    title: "Overview",
                    body: "Letterly is a word puzzle game. We are committed to protecting your privacy. This policy explains what information is collected when you use Letterly and how it is handled."
                )
                policySection(
                    title: "Data Stored on Your Device",
                    body: "Letterly stores your game statistics (games played, wins, current streak, best streak) and preferences (sound effects, haptic feedback) locally on your device using iOS UserDefaults. This data remains entirely on your device, is never transmitted to any server, and is not accessible to the developer."
                )
                policySection(
                    title: "AI Hints",
                    body: "When you request a hint, Letterly sends the following information to Groq's AI service: your current game mode, the number of guesses remaining, and your previous guesses in the current game. No personally identifiable information is included in these requests. Groq's privacy policy governs how they handle this data."
                )
                policySection(
                    title: "Analytics and Tracking",
                    body: "Letterly does not include any analytics, advertising, or user-tracking frameworks. We do not collect device identifiers, usage patterns, or any other telemetry."
                )
                policySection(
                    title: "Third-Party Services",
                    body: "Letterly uses the Groq API solely to generate in-game hints. This is the only third-party service the app communicates with, and only when you explicitly request a hint."
                )
                policySection(
                    title: "Data Retention",
                    body: "All game data is stored on your device and is deleted when you uninstall the app. No data is retained by the developer."
                )
                policySection(
                    title: "Children's Privacy",
                    body: "Letterly does not collect personal information from any users, including children under the age of 13."
                )
                policySection(
                    title: "Changes to This Policy",
                    body: "We may update this privacy policy from time to time. Any changes will be reflected in the app with an updated effective date."
                )
                policySection(
                    title: "Contact",
                    body: "If you have questions about this privacy policy, you can reach us at \(AppConfiguration.contactEmail)."
                )
            }
            .padding()
        }
        .navigationTitle("Privacy Policy")
        .navigationBarTitleDisplayMode(.large)
    }

    private func policySection(title: String, body: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)
            Text(body)
                .font(.body)
                .foregroundColor(.secondary)
        }
    }
}
