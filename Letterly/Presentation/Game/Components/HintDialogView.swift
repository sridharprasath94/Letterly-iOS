import SwiftUI

struct HintDialogView: View {
    let hints: [String]
    let remaining: Int
    let onGetNextHint: () -> Void
    let onDismiss: () -> Void

    var body: some View {
        ZStack {
            Color.black.opacity(0.4)
                .ignoresSafeArea()
                .onTapGesture { onDismiss() }

            VStack(alignment: .leading, spacing: 16) {
                Text("Hints")
                    .font(.headline)

                Text(message)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)

                Divider()

                if remaining > 0 {
                    Button(action: onGetNextHint) {
                        Text("Get Next Hint")
                            .frame(maxWidth: .infinity)
                            .font(.body.weight(.semibold))
                            .foregroundColor(.accentColor)
                    }

                    Divider()
                }

                Button(action: onDismiss) {
                    Text("OK")
                        .frame(maxWidth: .infinity)
                        .font(.body)
                        .foregroundColor(.primary)
                }
            }
            .padding(20)
            .background(.regularMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .padding(.horizontal, 40)
            .shadow(color: .black.opacity(0.3), radius: 20)
        }
    }

    private var message: String {
        hints.enumerated()
            .map { "Hint \($0.offset + 1): \($0.element)" }
            .joined(separator: "\n\n")
    }
}
