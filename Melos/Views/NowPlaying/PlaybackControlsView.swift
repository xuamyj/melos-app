import SwiftUI

struct PlaybackControlsView: View {
    let isPlaying: Bool
    let skipInterval: Int
    let onPlayPause: () -> Void
    let onSkipBackward: () -> Void
    let onSkipForward: () -> Void
    let onBackwardInterval: () -> Void
    let onForwardInterval: () -> Void

    var body: some View {
        HStack(spacing: 28) {
            // Skip backward by interval
            Button(action: onBackwardInterval) {
                Image(systemName: "gobackward.\(skipInterval)")
                    .font(.title2)
            }
            .frame(width: 44, height: 44)

            // Previous / restart track
            Button(action: onSkipBackward) {
                Image(systemName: "backward.fill")
                    .font(.title)
            }
            .frame(width: 44, height: 44)

            // Play / Pause
            Button(action: onPlayPause) {
                Image(systemName: isPlaying ? "pause.circle.fill" : "play.circle.fill")
                    .font(.system(size: 56))
            }
            .frame(width: 60, height: 60)

            // Next track
            Button(action: onSkipForward) {
                Image(systemName: "forward.fill")
                    .font(.title)
            }
            .frame(width: 44, height: 44)

            // Skip forward by interval
            Button(action: onForwardInterval) {
                Image(systemName: "goforward.\(skipInterval)")
                    .font(.title2)
            }
            .frame(width: 44, height: 44)
        }
        .foregroundColor(.melosPrimary)
    }
}
