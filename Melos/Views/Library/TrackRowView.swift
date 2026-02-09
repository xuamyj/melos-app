import SwiftUI

struct TrackRowView: View {
    let track: Track
    let isSelected: Bool
    let isSelecting: Bool
    let onAddToQueue: () -> Void
    let onPlayNext: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            if isSelecting {
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.title3)
                    .foregroundColor(isSelected ? .melosPrimary : .secondary)
            }

            Circle()
                .fill(TrackColor.forIndex(track.colorIndex).color)
                .frame(width: 36, height: 36)

            VStack(alignment: .leading, spacing: 2) {
                Text(track.title)
                    .font(.body.weight(.medium))
                    .lineLimit(1)

                Text(formatDuration(track.duration))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()

            if !isSelecting {
                Menu {
                    Button {
                        onAddToQueue()
                    } label: {
                        Label("Add to Queue", systemImage: "text.append")
                    }

                    Button {
                        onPlayNext()
                    } label: {
                        Label("Play Next", systemImage: "text.insert")
                    }
                } label: {
                    Image(systemName: "ellipsis")
                        .font(.body)
                        .foregroundColor(.secondary)
                        .frame(width: 44, height: 44)
                }
            }
        }
        .padding(.vertical, 4)
        .contentShape(Rectangle())
    }

    private func formatDuration(_ seconds: TimeInterval) -> String {
        let totalSeconds = Int(seconds)
        let mins = totalSeconds / 60
        let secs = totalSeconds % 60
        return String(format: "%d:%02d", mins, secs)
    }
}
