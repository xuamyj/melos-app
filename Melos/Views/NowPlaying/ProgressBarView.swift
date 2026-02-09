import SwiftUI

struct ProgressBarView: View {
    let currentTime: TimeInterval
    let duration: TimeInterval
    let onSeek: (TimeInterval) -> Void

    @State private var isDragging = false
    @State private var dragValue: Double = 0

    private var progress: Double {
        guard duration > 0 else { return 0 }
        return isDragging ? dragValue : currentTime / duration
    }

    var body: some View {
        VStack(spacing: 4) {
            Slider(
                value: Binding(
                    get: { progress },
                    set: { newValue in
                        isDragging = true
                        dragValue = newValue
                    }
                ),
                in: 0...1,
                onEditingChanged: { editing in
                    if !editing {
                        onSeek(dragValue * duration)
                        isDragging = false
                    }
                }
            )
            .accentColor(.melosPrimary)

            HStack {
                Text(formatTime(isDragging ? dragValue * duration : currentTime))
                    .font(.caption2)
                    .foregroundColor(.secondary)
                    .monospacedDigit()

                Spacer()

                Text("-\(formatTime(duration - (isDragging ? dragValue * duration : currentTime)))")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                    .monospacedDigit()
            }
        }
    }

    private func formatTime(_ seconds: TimeInterval) -> String {
        let totalSeconds = max(0, Int(seconds))
        let mins = totalSeconds / 60
        let secs = totalSeconds % 60
        return String(format: "%d:%02d", mins, secs)
    }
}
