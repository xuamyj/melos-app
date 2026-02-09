import SwiftUI

@main
struct MelosApp: App {
    @StateObject private var libraryManager = LibraryManager()
    @StateObject private var queueManager = QueueManager()
    @StateObject private var audioEngine = AudioEngine()

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

                    // Load saved settings
                    if let settings = PersistenceService.load(AppSettings.self, from: PersistenceService.settingsURL) {
                        audioEngine.skipInterval = TimeInterval(settings.skipIntervalSeconds)
                    }
                }
        }
    }
}
