import SwiftUI

struct QueueItemRowView: View {
    let position: Int
    let track: Track
    let isCurrent: Bool

    var body: some View {
        HStack(spacing: 12) {
            Text("\(position)")
                .font(.caption)
                .foregroundColor(.secondary)
                .frame(width: 24)

            Circle()
                .fill(TrackColor.forIndex(track.colorIndex).color)
                .frame(width: 32, height: 32)
                .overlay(
                    Group {
                        if isCurrent {
                            Image(systemName: "speaker.wave.2.fill")
                                .font(.caption2)
                                .foregroundColor(.white)
                        }
                    }
                )

            VStack(alignment: .leading, spacing: 2) {
                Text(track.title)
                    .font(.body.weight(isCurrent ? .semibold : .regular))
                    .lineLimit(1)

                Text(formatDuration(track.duration))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()
        }
        .padding(.vertical, 2)
        .listRowBackground(isCurrent ? Color.melosPrimary.opacity(0.1) : Color.clear)
    }

    private func formatDuration(_ seconds: TimeInterval) -> String {
        let totalSeconds = Int(seconds)
        let mins = totalSeconds / 60
        let secs = totalSeconds % 60
        return String(format: "%d:%02d", mins, secs)
    }
}
