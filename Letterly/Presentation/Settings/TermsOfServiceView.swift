import SwiftUI

struct TermsOfServiceView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                policySection(
                    title: "Effective Date",
                    body: "June 11, 2026"
                )
                policySection(
                    title: "Acceptance",
                    body: "By downloading or using Letterly, you agree to be bound by these Terms of Service. If you do not agree to these terms, please do not use the app."
                )
                policySection(
                    title: "License",
                    body: "Letterly grants you a personal, non-exclusive, non-transferable, revocable license to use the app for personal entertainment on any Apple device you own or control, subject to these terms and the App Store Terms of Service."
                )
                policySection(
                    title: "Permitted Use",
                    body: "You may use Letterly for personal, non-commercial purposes only. You may not reproduce, distribute, modify, create derivative works from, or reverse-engineer any part of the app."
                )
                policySection(
                    title: "AI-Generated Hints",
                    body: "The hint feature uses artificial intelligence and may occasionally produce inaccurate or unhelpful suggestions. Hints are provided as guidance only and carry no guarantee of accuracy."
                )
                policySection(
                    title: "Disclaimer of Warranties",
                    body: "Letterly is provided \"as is\" and \"as available\" without warranties of any kind, either express or implied. We do not warrant that the app will be uninterrupted, error-free, or free of harmful components."
                )
                policySection(
                    title: "Limitation of Liability",
                    body: "To the fullest extent permitted by law, the developer shall not be liable for any indirect, incidental, special, or consequential damages arising from your use of or inability to use Letterly."
                )
                policySection(
                    title: "Intellectual Property",
                    body: "All content, design, and code within Letterly, including the game name, word lists, and interface, are the intellectual property of \(AppConfiguration.developerName) and are protected by applicable copyright and trademark laws."
                )
                policySection(
                    title: "Changes to These Terms",
                    body: "We reserve the right to update these terms at any time. Continued use of Letterly after changes are posted constitutes acceptance of the updated terms."
                )
                policySection(
                    title: "Contact",
                    body: "For questions about these terms, contact us at \(AppConfiguration.contactEmail)."
                )
            }
            .padding()
        }
        .navigationTitle("Terms of Service")
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
