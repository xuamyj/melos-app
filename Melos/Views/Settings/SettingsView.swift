import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var audioEngine: AudioEngine
    @EnvironmentObject var queueManager: QueueManager
    @State private var skipIntervalSeconds: Int = AppSettings.default.skipIntervalSeconds
    @State private var showClearQueueConfirmation = false

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Playback")) {
                    Picker("Skip Interval", selection: $skipIntervalSeconds) {
                        ForEach(AppSettings.skipIntervalOptions, id: \.self) { seconds in
                            Text("\(seconds) seconds").tag(seconds)
                        }
                    }
                    .onChange(of: skipIntervalSeconds) { newValue in
                        audioEngine.skipInterval = TimeInterval(newValue)
                        audioEngine.nowPlayingService?.updateSkipIntervals(TimeInterval(newValue))
                        let settings = AppSettings(skipIntervalSeconds: newValue)
                        PersistenceService.save(settings, to: PersistenceService.settingsURL)
                    }
                }

                Section(header: Text("Queue")) {
                    Button(role: .destructive) {
                        showClearQueueConfirmation = true
                    } label: {
                        HStack {
                            Text("Clear Queue")
                            Spacer()
                            Text("\(queueManager.count) item\(queueManager.count == 1 ? "" : "s")")
                                .foregroundColor(.secondary)
                        }
                    }
                    .disabled(queueManager.isEmpty)
                }

                Section(header: Text("About")) {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle("Settings")
            .alert("Clear Queue?", isPresented: $showClearQueueConfirmation) {
                Button("Cancel", role: .cancel) {}
                Button("Clear Queue", role: .destructive) {
                    audioEngine.stop()
                    queueManager.clearQueue()
                }
            } message: {
                Text("This will stop playback and remove all items from the queue.")
            }
        }
        .navigationViewStyle(.stack)
        .onAppear {
            if let settings = PersistenceService.load(AppSettings.self, from: PersistenceService.settingsURL) {
                skipIntervalSeconds = settings.skipIntervalSeconds
            }
        }
    }
}
