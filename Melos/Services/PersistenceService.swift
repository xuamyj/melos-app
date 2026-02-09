import Foundation

enum PersistenceService {
    private static var documentsDirectory: URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }

    static var musicDirectoryURL: URL {
        let url = documentsDirectory.appendingPathComponent("Music", isDirectory: true)
        try? FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
        return url
    }

    // MARK: - File Paths

    static var libraryManifestURL: URL {
        documentsDirectory.appendingPathComponent("library.json")
    }

    static var queueManifestURL: URL {
        documentsDirectory.appendingPathComponent("queue.json")
    }

    static var settingsURL: URL {
        documentsDirectory.appendingPathComponent("settings.json")
    }

    // MARK: - Generic JSON Read/Write

    static func load<T: Decodable>(_ type: T.Type, from url: URL) -> T? {
        guard let data = try? Data(contentsOf: url) else { return nil }
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try? decoder.decode(type, from: data)
    }

    static func save<T: Encodable>(_ value: T, to url: URL) {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = .prettyPrinted
        guard let data = try? encoder.encode(value) else { return }
        try? data.write(to: url, options: .atomic)
    }

    // MARK: - Music File Management

    /// Copies an MP3 file into Documents/Music, handling duplicate filenames.
    /// Returns the relative path from Documents (e.g., "Music/track.mp3").
    static func copyMusicFile(from sourceURL: URL) -> String? {
        let fileName = sourceURL.lastPathComponent
        let destURL = musicDirectoryURL.appendingPathComponent(fileName)

        let finalURL: URL
        if FileManager.default.fileExists(atPath: destURL.path) {
            let stem = destURL.deletingPathExtension().lastPathComponent
            let ext = destURL.pathExtension
            let uniqueName = "\(stem)_\(UUID().uuidString.prefix(8)).\(ext)"
            finalURL = musicDirectoryURL.appendingPathComponent(uniqueName)
        } else {
            finalURL = destURL
        }

        do {
            try FileManager.default.copyItem(at: sourceURL, to: finalURL)
            return "Music/\(finalURL.lastPathComponent)"
        } catch {
            print("Failed to copy music file: \(error)")
            return nil
        }
    }

    static func deleteMusicFile(relativePath: String) {
        let url = documentsDirectory.appendingPathComponent(relativePath)
        try? FileManager.default.removeItem(at: url)
    }
}
