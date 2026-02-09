import SwiftUI

struct QueueSheetView: View {
    @EnvironmentObject var queueManager: QueueManager
    @EnvironmentObject var libraryManager: LibraryManager
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationView {
            VStack {
                if queueManager.isEmpty {
                    Spacer()
                    VStack(spacing: 12) {
                        Image(systemName: "list.bullet")
                            .font(.system(size: 40))
                            .foregroundColor(.secondary)
                        Text("Queue is Empty")
                            .font(.headline)
                        Text("Play a track from Library to start a queue")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                } else {
                    Text("\(queueManager.count) item\(queueManager.count == 1 ? "" : "s") in queue")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .padding(.top, 8)
                }
            }
            .navigationTitle("Queue")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
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
