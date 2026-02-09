import SwiftUI

struct NowPlayingView: View {
    @EnvironmentObject var audioEngine: AudioEngine
    @EnvironmentObject var queueManager: QueueManager
    @EnvironmentObject var libraryManager: LibraryManager
    @State private var showingQueue = false

    private var trackColor: Color {
        guard let track = audioEngine.currentTrack else { return .melosPrimary }
        return TrackColor.forIndex(track.colorIndex).color
    }

    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                Spacer()

                if audioEngine.currentTrack != nil {
                    // Track color art placeholder
                    RoundedRectangle(cornerRadius: 24)
                        .fill(
                            LinearGradient(
                                colors: [trackColor, trackColor.opacity(0.7)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 260, height: 260)
                        .shadow(color: trackColor.opacity(0.4), radius: 20, y: 10)
                        .overlay(
                            Image(systemName: "music.note")
                                .font(.system(size: 64))
                                .foregroundColor(.white.opacity(0.7))
                        )

                    // Track info
                    VStack(spacing: 6) {
                        Text(audioEngine.currentTrack?.title ?? "")
                            .font(.title2.weight(.semibold))
                            .lineLimit(1)

                        // Queue position
                        if queueManager.count > 0 {
                            Text("Track \(queueManager.currentIndex + 1) of \(queueManager.count)")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.horizontal, 32)

                    // Progress bar
                    ProgressBarView(
                        currentTime: audioEngine.currentTime,
                        duration: audioEngine.duration,
                        onSeek: { time in
                            audioEngine.seek(to: time)
                        }
                    )
                    .padding(.horizontal, 32)

                    // Playback controls
                    PlaybackControlsView(
                        isPlaying: audioEngine.isPlaying,
                        skipInterval: Int(audioEngine.skipInterval),
                        onPlayPause: { audioEngine.togglePlayPause() },
                        onSkipBackward: { audioEngine.skipBackward() },
                        onSkipForward: { audioEngine.goToNextTrack() },
                        onBackwardInterval: { audioEngine.skipBackwardByInterval() },
                        onForwardInterval: { audioEngine.skipForward() }
                    )
                } else {
                    // No track playing
                    VStack(spacing: 16) {
                        Image(systemName: "music.note")
                            .font(.system(size: 48))
                            .foregroundColor(.secondary)
                        Text("Not Playing")
                            .font(.title3.weight(.medium))
                        Text("Select a track from your Library")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }

                Spacer()
            }
            .navigationTitle("Now Playing")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingQueue = true
                    } label: {
                        Image(systemName: "list.bullet")
                    }
                }
            }
            .sheet(isPresented: $showingQueue) {
                QueueSheetView()
            }
        }
        .navigationViewStyle(.stack)
    }
}
