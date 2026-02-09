import Foundation

struct Track: Codable, Identifiable {
    let id: UUID
    let fileName: String
    let title: String
    let duration: TimeInterval
    let importDate: Date
    var colorIndex: Int

    /// Relative path within the app's Documents directory (e.g., "Music/track.mp3")
    let relativePath: String

    init(
        id: UUID = UUID(),
        fileName: String,
        title: String,
        duration: TimeInterval = 0,
        importDate: Date = Date(),
        colorIndex: Int = 0,
        relativePath: String
    ) {
        self.id = id
        self.fileName = fileName
        self.title = title
        self.duration = duration
        self.importDate = importDate
        self.colorIndex = colorIndex
        self.relativePath = relativePath
    }

    var fileURL: URL {
        let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        return docs.appendingPathComponent(relativePath)
    }
}
