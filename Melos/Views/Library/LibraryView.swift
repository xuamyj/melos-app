import SwiftUI

struct LibraryView: View {
    @EnvironmentObject var libraryManager: LibraryManager
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
                                    // Will be wired in checkpoint 7
                                },
                                onPlayNext: {
                                    // Will be wired in checkpoint 7
                                }
                            )
                            .onTapGesture {
                                if isSelecting {
                                    toggleSelection(track.id)
                                } else {
                                    // Will play track in checkpoint 6
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
