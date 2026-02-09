import SwiftUI

struct QueueSheetView: View {
    @EnvironmentObject var queueManager: QueueManager
    @EnvironmentObject var libraryManager: LibraryManager
    @EnvironmentObject var audioEngine: AudioEngine
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationView {
            Group {
                if queueManager.isEmpty {
                    VStack(spacing: 12) {
                        Spacer()
                        Image(systemName: "list.bullet")
                            .font(.system(size: 40))
                            .foregroundColor(.secondary)
                        Text("Queue is Empty")
                            .font(.headline)
                        Text("Play a track from Library to start a queue")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        Spacer()
                    }
                } else {
                    List {
                        ForEach(Array(queueManager.items.enumerated()), id: \.element.id) { index, item in
                            if let track = libraryManager.track(for: item.trackID) {
                                QueueItemRowView(
                                    position: index + 1,
                                    track: track,
                                    isCurrent: index == queueManager.currentIndex
                                )
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    queueManager.jumpTo(index: index)
                                    audioEngine.playCurrentQueueItem()
                                }
                            }
                        }
                        .onDelete { offsets in
                            queueManager.removeFromQueue(at: offsets)
                        }
                        .onMove { source, destination in
                            queueManager.moveItems(from: source, to: destination)
                        }
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle("Queue")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    if !queueManager.isEmpty {
                        EditButton()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
        .navigationViewStyle(.stack)
    }
}
