import Foundation

/// A queue item wraps a track ID with its own unique identity,
/// allowing the same track to appear multiple times in the queue.
struct QueueItem: Codable, Identifiable {
    let id: UUID
    let trackID: UUID

    init(id: UUID = UUID(), trackID: UUID) {
        self.id = id
        self.trackID = trackID
    }
}
