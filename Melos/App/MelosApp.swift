import SwiftUI

@main
struct MelosApp: App {
    @StateObject private var libraryManager = LibraryManager()
    @StateObject private var queueManager = QueueManager()
    @StateObject private var audioEngine = AudioEngine()
    @Environment(\.scenePhase) private var scenePhase

    /// Strong reference to keep NowPlayingService alive
    @State private var nowPlayingService: NowPlayingService?

    var body: some Scene {
        WindowGroup {
            TabRootView()
                .environmentObject(libraryManager)
                .environmentObject(queueManager)
                .environmentObject(audioEngine)
                .onAppear {
                    audioEngine.queueManager = queueManager
                    audioEngine.libraryManager = libraryManager
                    audioEngine.setupAudioSession()

                    // Create and wire NowPlayingService
                    let service = NowPlayingService(audioEngine: audioEngine)
                    audioEngine.nowPlayingService = service
                    nowPlayingService = service

                    // Load saved settings
                    if let settings = PersistenceService.load(AppSettings.self, from: PersistenceService.settingsURL) {
                        audioEngine.skipInterval = TimeInterval(settings.skipIntervalSeconds)
                        service.updateSkipIntervals(TimeInterval(settings.skipIntervalSeconds))
                    }
                }
                .onChange(of: scenePhase) { newPhase in
                    if newPhase == .active {
                        audioEngine.handleAppBecameActive()
                    }
                }
        }
    }
}
