import SwiftUI

@Observable
class AppState {
    @ObservationIgnored
    @AppStorage("isOnboardingComplete") var isOnboardingComplete = false

    @ObservationIgnored
    @AppStorage("activeCatId") private var activeCatIdString: String = ""

    var activeCatId: UUID? {
        get { UUID(uuidString: activeCatIdString) }
        set { activeCatIdString = newValue?.uuidString ?? "" }
    }
}
