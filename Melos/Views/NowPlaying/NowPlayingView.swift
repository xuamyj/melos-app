import SwiftUI

struct NowPlayingView: View {
    var body: some View {
        NavigationView {
            Text("Now Playing — Coming Soon")
                .navigationTitle("Now Playing")
        }
        .navigationViewStyle(.stack)
    }
}
