import Foundation
import AVFoundation

class LibraryManager: ObservableObject {
    @Published private(set) var tracks: [Track] = []

    /// Tracks the next color index to assign to imported tracks (cycles through 7 colors)
    private var nextColorIndex: Int = 0

    init() {
        loadLibrary()
        // Set next color index based on existing track count
        if !tracks.isEmpty {
            nextColorIndex = tracks.count % TrackColor.allCases.count
        }
    }

    // MARK: - Computed

    /// Tracks sorted by import date, newest first
    var sortedTracks: [Track] {
        tracks.sorted { $0.importDate > $1.importDate }
    }

    func track(for id: UUID) -> Track? {
        tracks.first { $0.id == id }
    }

    // MARK: - Import

    func importTracks(from urls: [URL]) {
        for url in urls {
            importSingleTrack(from: url)
        }
    }

    private func importSingleTrack(from sourceURL: URL) {
        let accessing = sourceURL.startAccessingSecurityScopedResource()
        defer {
            if accessing { sourceURL.stopAccessingSecurityScopedResource() }
        }

        guard let relativePath = PersistenceService.copyMusicFile(from: sourceURL) else { return }

        let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let fileURL = docs.appendingPathComponent(relativePath)

        // Extract duration
        let asset = AVURLAsset(url: fileURL)
        let duration = CMTimeGetSeconds(asset.duration)

        let fileName = sourceURL.lastPathComponent
        let title = sourceURL.deletingPathExtension().lastPathComponent

        let track = Track(
            fileName: fileName,
            title: title,
            duration: duration.isNaN ? 0 : duration,
            colorIndex: nextColorIndex,
            relativePath: relativePath
        )

        nextColorIndex = (nextColorIndex + 1) % TrackColor.allCases.count
        tracks.append(track)
        saveLibrary()
    }

    // MARK: - Delete

    func deleteTrack(_ track: Track) {
        PersistenceService.deleteMusicFile(relativePath: track.relativePath)
        tracks.removeAll { $0.id == track.id }
        saveLibrary()
    }

    func deleteTracks(ids: Set<UUID>) {
        for id in ids {
            if let track = track(for: id) {
                PersistenceService.deleteMusicFile(relativePath: track.relativePath)
            }
        }
        tracks.removeAll { ids.contains($0.id) }
        saveLibrary()
    }

    // MARK: - Persistence

    private func loadLibrary() {
        tracks = PersistenceService.load([Track].self, from: PersistenceService.libraryManifestURL) ?? []
    }

    private func saveLibrary() {
        PersistenceService.save(tracks, to: PersistenceService.libraryManifestURL)
    }
}
