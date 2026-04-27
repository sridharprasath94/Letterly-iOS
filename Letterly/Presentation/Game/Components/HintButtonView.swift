import SwiftUI

struct HintButtonView: View {
    let hintsUsed: Int
    let maxHints: Int
    let isLoading: Bool
    let onTap: () -> Void

    private var remaining: Int { maxHints - hintsUsed }
    private var hasReceivedHints: Bool { hintsUsed > 0 }
    private var isEnabled: Bool { !isLoading && (remaining > 0 || hasReceivedHints) }

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 4) {
                if isLoading {
                    ProgressView()
                        .tint(.primary)
                        .scaleEffect(0.8)
                } else {
                    Image(systemName: remaining > 0 ? "lightbulb.fill" : "lightbulb")
                        .foregroundColor(remaining > 0 ? .yellow : Color(.systemGray))
                }
                Text("x\(remaining)")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(remaining > 0 ? .primary : Color(.systemGray))
            }
        }
        .disabled(!isEnabled)
        .opacity(isEnabled ? 1.0 : 0.4)
    }
}
