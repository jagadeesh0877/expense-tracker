import SwiftUI

@main
struct HelloSideloadApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

struct ContentView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "hand.wave")
                .font(.system(size: 64))
            Text("Hello World")
                .font(.largeTitle)
                .fontWeight(.bold)
            Text("Built for sideloading via Sideloadly")
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
    }
}
