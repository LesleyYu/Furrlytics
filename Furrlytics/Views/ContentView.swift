import SwiftUI

struct ContentView: View {
    @Environment(AppState.self) private var appState

    var body: some View {
        if appState.isOnboardingComplete {
            Text("Furrlytics Home")
                .font(.largeTitle)
        } else {
            Text("Onboarding Placeholder")
                .font(.largeTitle)
        }
    }
}
