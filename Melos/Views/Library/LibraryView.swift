import SwiftUI

struct LibraryView: View {
    @Binding var selectedTab: Int
    @EnvironmentObject var libraryManager: LibraryManager
    @EnvironmentObject var queueManager: QueueManager
    @EnvironmentObject var audioEngine: AudioEngine
    @State private var showingDocumentPicker = false
    @State private var isSelecting = false
    @State private var selectedIDs: Set<UUID> = []
    @State private var showDeleteConfirmation = false

    var body: some View {
        NavigationView {
            Group {
                if libraryManager.sortedTracks.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "music.note")
                            .font(.system(size: 48))
                            .foregroundColor(.secondary)
                        Text("No Music Yet")
                            .font(.title3.weight(.medium))
                        Text("Tap + to import MP3 files")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                } else {
                    List {
                        ForEach(libraryManager.sortedTracks) { track in
                            TrackRowView(
                                track: track,
                                isSelected: selectedIDs.contains(track.id),
                                isSelecting: isSelecting,
                                onAddToQueue: {
                                    queueManager.addToQueue(trackID: track.id)
                                },
                                onPlayNext: {
                                    queueManager.addToQueueNext(trackID: track.id)
                                }
                            )
                            .onTapGesture {
                                if isSelecting {
                                    toggleSelection(track.id)
                                } else {
                                    playTrack(track)
                                }
                            }
                        }
                        .onDelete(perform: deleteTracks)
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle("Library")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    if isSelecting {
                        Button("Cancel") {
                            isSelecting = false
                            selectedIDs.removeAll()
                        }
                    } else if !libraryManager.tracks.isEmpty {
                        Menu {
                            Button {
                                isSelecting = true
                                selectedIDs.removeAll()
                            } label: {
                                Label("Select Files to Delete", systemImage: "trash")
                            }
                        } label: {
                            Image(systemName: "ellipsis.circle")
                        }
                    }
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    if isSelecting {
                        Button("Delete") {
                            if !selectedIDs.isEmpty {
                                showDeleteConfirmation = true
                            }
                        }
                        .foregroundColor(.red)
                        .disabled(selectedIDs.isEmpty)
                    } else {
                        Button {
                            showingDocumentPicker = true
                        } label: {
                            Image(systemName: "plus")
                        }
                    }
                }
            }
            .sheet(isPresented: $showingDocumentPicker) {
                DocumentPickerView { urls in
                    libraryManager.importTracks(from: urls)
                }
            }
            .alert("Delete Selected?", isPresented: $showDeleteConfirmation) {
                Button("Cancel", role: .cancel) {}
                Button("Delete", role: .destructive) {
                    libraryManager.deleteTracks(ids: selectedIDs)
                    selectedIDs.removeAll()
                    isSelecting = false
                }
            } message: {
                Text("This will permanently delete \(selectedIDs.count) track\(selectedIDs.count == 1 ? "" : "s").")
            }
        }
        .navigationViewStyle(.stack)
    }

    private func playTrack(_ track: Track) {
        let sorted = libraryManager.sortedTracks
        let trackIDs = sorted.map { $0.id }
        let startIndex = sorted.firstIndex(where: { $0.id == track.id }) ?? 0
        queueManager.replaceQueue(with: trackIDs, startingAt: startIndex)
        audioEngine.playCurrentQueueItem()
        selectedTab = 1 // Switch to Now Playing tab
    }

    private func toggleSelection(_ id: UUID) {
        if selectedIDs.contains(id) {
            selectedIDs.remove(id)
        } else {
            selectedIDs.insert(id)
        }
    }

    private func deleteTracks(at offsets: IndexSet) {
        let sorted = libraryManager.sortedTracks
        for index in offsets {
            libraryManager.deleteTrack(sorted[index])
        }
    }
}
