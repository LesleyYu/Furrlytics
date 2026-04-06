import SwiftUI
import SwiftData

@main
struct FurrlyticsApp: App {
    private let modelContainer: ModelContainer

    @State private var appState = AppState()
    @State private var petlibroService = PetlibroService()

    init() {
        do {
            let schema = Schema([
                CareEvent.self,
                CatProfile.self,
                HomeLocation.self,
                DewormingSchedule.self,
                TreatItem.self
            ])
            let configuration = ModelConfiguration(isStoredInMemoryOnly: false)
            modelContainer = try ModelContainer(for: schema, configurations: [configuration])
        } catch {
            fatalError("Failed to create ModelContainer: \(error)")
        }
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(appState)
                .environment(petlibroService)
        }
        .modelContainer(modelContainer)
    }
}
