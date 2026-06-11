import SwiftUI

struct AboutView: View {
    private var version: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
    }
    private var build: String {
        Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
    }
    private var iosVersion: String {
        let v = ProcessInfo.processInfo.operatingSystemVersion
        return v.patchVersion == 0
            ? "\(v.majorVersion).\(v.minorVersion)"
            : "\(v.majorVersion).\(v.minorVersion).\(v.patchVersion)"
    }

    var body: some View {
        List {
            appIdentitySection
            descriptionSection
            technologySection
            developerSection
            legalSection
            diagnosticsSection
        }
        .navigationTitle("About")
        .navigationBarTitleDisplayMode(.large)
    }

    // MARK: - Sections

    private var appIdentitySection: some View {
        Section {
            HStack(spacing: 16) {
                ZStack {
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(Color.accentColor)
                        .frame(width: 60, height: 60)
                    Text("L")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(.white)
                }
                .accessibilityHidden(true)
                VStack(alignment: .leading, spacing: 4) {
                    Text("Letterly")
                        .font(.title2.bold())
                    Text("Version \(version) (\(build))")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
            .padding(.vertical, 4)
        }
    }

    private var descriptionSection: some View {
        Section("Description") {
            Text("Letterly is a word puzzle game where players guess hidden words and receive color-coded feedback.")
        }
    }

    private var technologySection: some View {
        Section("Technology") {
            Label("SwiftUI",            systemImage: "swift")
            Label("Combine",            systemImage: "arrow.triangle.2.circlepath")
            Label("Clean Architecture", systemImage: "building.columns")
            Label("MVVM",               systemImage: "rectangle.3.group")
            Label("Async/Await",        systemImage: "clock.arrow.circlepath")
        }
    }

    private var developerSection: some View {
        Section("Developer") {
            infoRow("Developer", value: AppConfiguration.developerName)
        }
    }

    private var legalSection: some View {
        Section("Legal") {
            Link(destination: AppConfiguration.privacyPolicyURL) {
                Label("Privacy Policy", systemImage: "hand.raised")
            }
            Link(destination: AppConfiguration.termsOfServiceURL) {
                Label("Terms of Service", systemImage: "doc.text")
            }
        }
    }

    private var diagnosticsSection: some View {
        Section("Diagnostics") {
            infoRow("Version", value: version)
            infoRow("Build",   value: build)
            infoRow("iOS",     value: iosVersion)
        }
    }

    // MARK: - Helpers

    private func infoRow(_ label: String, value: String) -> some View {
        HStack {
            Text(label)
            Spacer()
            Text(value)
                .foregroundColor(.secondary)
        }
    }
}
