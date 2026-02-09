import Foundation
import MediaPlayer

class NowPlayingService {
    private weak var audioEngine: AudioEngine?

    init(audioEngine: AudioEngine) {
        self.audioEngine = audioEngine
        setupRemoteCommands()
    }

    // MARK: - Update Now Playing Info

    func updateNowPlayingInfo(track: Track, currentTime: TimeInterval, duration: TimeInterval, isPlaying: Bool) {
        var info = [String: Any]()
        info[MPMediaItemPropertyTitle] = track.title
        info[MPMediaItemPropertyPlaybackDuration] = duration
        info[MPNowPlayingInfoPropertyElapsedPlaybackTime] = currentTime
        info[MPNowPlayingInfoPropertyPlaybackRate] = isPlaying ? 1.0 : 0.0

        MPNowPlayingInfoCenter.default().nowPlayingInfo = info
    }

    func clearNowPlayingInfo() {
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nil
    }

    func updateSkipIntervals(_ interval: TimeInterval) {
        let commandCenter = MPRemoteCommandCenter.shared()
        commandCenter.skipForwardCommand.preferredIntervals = [NSNumber(value: interval)]
        commandCenter.skipBackwardCommand.preferredIntervals = [NSNumber(value: interval)]
    }

    // MARK: - Remote Command Center

    private func setupRemoteCommands() {
        let commandCenter = MPRemoteCommandCenter.shared()

        commandCenter.playCommand.isEnabled = true
        commandCenter.playCommand.addTarget { [weak self] _ in
            self?.audioEngine?.resume()
            return .success
        }

        commandCenter.pauseCommand.isEnabled = true
        commandCenter.pauseCommand.addTarget { [weak self] _ in
            self?.audioEngine?.pause()
            return .success
        }

        commandCenter.togglePlayPauseCommand.isEnabled = true
        commandCenter.togglePlayPauseCommand.addTarget { [weak self] _ in
            self?.audioEngine?.togglePlayPause()
            return .success
        }

        commandCenter.nextTrackCommand.isEnabled = true
        commandCenter.nextTrackCommand.addTarget { [weak self] _ in
            self?.audioEngine?.goToNextTrack()
            return .success
        }

        commandCenter.previousTrackCommand.isEnabled = true
        commandCenter.previousTrackCommand.addTarget { [weak self] _ in
            self?.audioEngine?.goToPreviousTrack()
            return .success
        }

        commandCenter.changePlaybackPositionCommand.isEnabled = true
        commandCenter.changePlaybackPositionCommand.addTarget { [weak self] event in
            guard let event = event as? MPChangePlaybackPositionCommandEvent else {
                return .commandFailed
            }
            self?.audioEngine?.seek(to: event.positionTime)
            return .success
        }

        commandCenter.skipForwardCommand.isEnabled = true
        commandCenter.skipForwardCommand.preferredIntervals = [NSNumber(value: audioEngine?.skipInterval ?? 15)]
        commandCenter.skipForwardCommand.addTarget { [weak self] _ in
            self?.audioEngine?.skipForward()
            return .success
        }

        commandCenter.skipBackwardCommand.isEnabled = true
        commandCenter.skipBackwardCommand.preferredIntervals = [NSNumber(value: audioEngine?.skipInterval ?? 15)]
        commandCenter.skipBackwardCommand.addTarget { [weak self] _ in
            self?.audioEngine?.skipBackwardByInterval()
            return .success
        }
    }
}
