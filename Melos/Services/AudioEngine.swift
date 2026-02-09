import AVFoundation
import Foundation
import UIKit

class AudioEngine: NSObject, ObservableObject {
    // MARK: - Published State

    @Published private(set) var isPlaying = false
    @Published private(set) var currentTime: TimeInterval = 0
    @Published private(set) var duration: TimeInterval = 0
    @Published private(set) var currentTrack: Track?

    // MARK: - Dependencies (set after init)

    var queueManager: QueueManager?
    var libraryManager: LibraryManager?

    // MARK: - Settings

    var skipInterval: TimeInterval = 15

    // MARK: - Private

    private var audioPlayer: AVAudioPlayer?
    private var displayLink: CADisplayLink?
    private var lastSkipBackwardTime: Date = .distantPast
    private let doubleTapThreshold: TimeInterval = 0.4

    // MARK: - Now Playing Service (set in checkpoint 8)

    var nowPlayingService: AnyObject? // Will be typed as NowPlayingService later

    // MARK: - Setup

    func setupAudioSession() {
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playback, mode: .default)
            try session.setActive(true)
        } catch {
            print("Failed to set up audio session: \(error)")
        }

        // Audio interruption handling
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleInterruption),
            name: AVAudioSession.interruptionNotification,
            object: nil
        )

        // Route change handling (e.g., headphones unplugged)
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleRouteChange),
            name: AVAudioSession.routeChangeNotification,
            object: nil
        )
    }

    // MARK: - Playback Controls

    func play(track: Track) {
        do {
            audioPlayer?.stop()
            audioPlayer = try AVAudioPlayer(contentsOf: track.fileURL)
            audioPlayer?.delegate = self
            audioPlayer?.prepareToPlay()
            audioPlayer?.play()

            currentTrack = track
            duration = audioPlayer?.duration ?? 0
            isPlaying = true

            startProgressUpdates()
        } catch {
            print("Failed to play track: \(error)")
        }
    }

    func playCurrentQueueItem() {
        guard let qm = queueManager, let lm = libraryManager,
              let queueItem = qm.currentItem else { return }

        if let track = lm.track(for: queueItem.trackID) {
            play(track: track)
        } else {
            // Track was deleted from library — skip to next
            goToNextTrack()
        }
    }

    func togglePlayPause() {
        guard let player = audioPlayer else { return }
        if player.isPlaying {
            player.pause()
            isPlaying = false
        } else {
            player.play()
            isPlaying = true
        }
    }

    func pause() {
        audioPlayer?.pause()
        isPlaying = false
    }

    func resume() {
        audioPlayer?.play()
        isPlaying = true
    }

    func stop() {
        audioPlayer?.stop()
        audioPlayer = nil
        isPlaying = false
        currentTrack = nil
        currentTime = 0
        duration = 0
        stopProgressUpdates()
    }

    // MARK: - Seeking

    func seek(to time: TimeInterval) {
        audioPlayer?.currentTime = max(0, min(time, duration))
        currentTime = audioPlayer?.currentTime ?? 0
    }

    func skipForward() {
        guard let player = audioPlayer else { return }
        let newTime = min(player.currentTime + skipInterval, duration)
        seek(to: newTime)
    }

    func skipBackwardByInterval() {
        guard let player = audioPlayer else { return }
        let newTime = max(player.currentTime - skipInterval, 0)
        seek(to: newTime)
    }

    /// Single tap: restart current track. Double tap (within threshold): go to previous track.
    func skipBackward() {
        let now = Date()
        if now.timeIntervalSince(lastSkipBackwardTime) < doubleTapThreshold {
            // Double tap → previous track
            lastSkipBackwardTime = .distantPast
            goToPreviousTrack()
        } else {
            // Single tap → delayed restart
            lastSkipBackwardTime = now
            let capturedTime = now
            DispatchQueue.main.asyncAfter(deadline: .now() + doubleTapThreshold) { [weak self] in
                guard let self = self else { return }
                if self.lastSkipBackwardTime == capturedTime {
                    self.seek(to: 0)
                }
            }
        }
    }

    func goToNextTrack() {
        guard let qm = queueManager else { return }
        if qm.advanceToNext() {
            playCurrentQueueItem()
        }
    }

    func goToPreviousTrack() {
        guard let qm = queueManager else { return }
        if qm.goToPrevious() {
            playCurrentQueueItem()
        }
    }

    // MARK: - App Lifecycle

    func handleAppBecameActive() {
        if let player = audioPlayer {
            isPlaying = player.isPlaying
            currentTime = player.currentTime
        }
    }

    // MARK: - Progress Updates

    private func startProgressUpdates() {
        stopProgressUpdates()
        displayLink = CADisplayLink(target: self, selector: #selector(updateProgress))
        // Throttle to ~15fps for battery efficiency
        displayLink?.preferredFramesPerSecond = 15
        displayLink?.add(to: .main, forMode: .common)
    }

    private func stopProgressUpdates() {
        displayLink?.invalidate()
        displayLink = nil
    }

    @objc private func updateProgress() {
        guard let player = audioPlayer else { return }
        currentTime = player.currentTime
    }

    // MARK: - Notifications

    @objc private func handleInterruption(_ notification: Notification) {
        guard let info = notification.userInfo,
              let typeValue = info[AVAudioSessionInterruptionTypeKey] as? UInt,
              let type = AVAudioSession.InterruptionType(rawValue: typeValue) else { return }

        switch type {
        case .began:
            isPlaying = false
        case .ended:
            if let optionsValue = info[AVAudioSessionInterruptionOptionKey] as? UInt {
                let options = AVAudioSession.InterruptionOptions(rawValue: optionsValue)
                if options.contains(.shouldResume) {
                    resume()
                }
            }
        @unknown default:
            break
        }
    }

    @objc private func handleRouteChange(_ notification: Notification) {
        guard let info = notification.userInfo,
              let reasonValue = info[AVAudioSessionRouteChangeReasonKey] as? UInt,
              let reason = AVAudioSession.RouteChangeReason(rawValue: reasonValue) else { return }

        if reason == .oldDeviceUnavailable {
            // Headphones were unplugged — pause
            pause()
        }
    }
}

// MARK: - AVAudioPlayerDelegate

extension AudioEngine: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        isPlaying = false
        goToNextTrack()
    }

    func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        isPlaying = false
        print("Audio decode error: \(String(describing: error))")
    }
}
