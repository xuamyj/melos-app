import Foundation

class QueueManager: ObservableObject {
    @Published private(set) var items: [QueueItem] = []
    @Published var currentIndex: Int = 0

    init() {
        loadQueue()
    }

    // MARK: - Computed

    var currentItem: QueueItem? {
        guard currentIndex >= 0, currentIndex < items.count else { return nil }
        return items[currentIndex]
    }

    var isEmpty: Bool { items.isEmpty }
    var count: Int { items.count }

    // MARK: - Queue Manipulation

    func addToQueue(trackID: UUID) {
        items.append(QueueItem(trackID: trackID))
        saveQueue()
    }

    func addToQueueNext(trackID: UUID) {
        let insertIndex = min(currentIndex + 1, items.count)
        items.insert(QueueItem(trackID: trackID), at: insertIndex)
        saveQueue()
    }

    func replaceQueue(with trackIDs: [UUID], startingAt index: Int = 0) {
        items = trackIDs.map { QueueItem(trackID: $0) }
        currentIndex = max(0, min(index, items.count - 1))
        saveQueue()
    }

    func removeFromQueue(at offsets: IndexSet) {
        let currentID = currentItem?.id

        items.remove(atOffsets: offsets)

        // Restore currentIndex to follow the previously current item
        if let currentID = currentID,
           let newIndex = items.firstIndex(where: { $0.id == currentID }) {
            currentIndex = newIndex
        } else {
            currentIndex = min(currentIndex, max(0, items.count - 1))
        }
        saveQueue()
    }

    func moveItems(from source: IndexSet, to destination: Int) {
        let currentID = currentItem?.id

        items.move(fromOffsets: source, toOffset: destination)

        if let currentID = currentID,
           let newIndex = items.firstIndex(where: { $0.id == currentID }) {
            currentIndex = newIndex
        }
        saveQueue()
    }

    func advanceToNext() -> Bool {
        guard !items.isEmpty else { return false }
        if currentIndex + 1 < items.count {
            currentIndex += 1
        } else {
            // Auto-loop: wrap to beginning
            currentIndex = 0
        }
        saveQueue()
        return true
    }

    func goToPrevious() -> Bool {
        guard !items.isEmpty else { return false }
        if currentIndex > 0 {
            currentIndex -= 1
        } else {
            // Auto-loop: wrap to end
            currentIndex = items.count - 1
        }
        saveQueue()
        return true
    }

    func jumpTo(index: Int) {
        guard index >= 0, index < items.count else { return }
        currentIndex = index
        saveQueue()
    }

    func clearQueue() {
        items.removeAll()
        currentIndex = 0
        saveQueue()
    }

    // MARK: - Persistence

    private struct QueueState: Codable {
        let items: [QueueItem]
        let currentIndex: Int
    }

    private func loadQueue() {
        if let state = PersistenceService.load(QueueState.self, from: PersistenceService.queueManifestURL) {
            items = state.items
            currentIndex = state.currentIndex
        }
    }

    private func saveQueue() {
        let state = QueueState(items: items, currentIndex: currentIndex)
        PersistenceService.save(state, to: PersistenceService.queueManifestURL)
    }
}
