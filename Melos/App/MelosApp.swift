import SwiftUI

@main
struct MelosApp: App {
    @StateObject private var libraryManager = LibraryManager()

    var body: some Scene {
        WindowGroup {
            TabRootView()
                .environmentObject(libraryManager)
        }
    }
}
