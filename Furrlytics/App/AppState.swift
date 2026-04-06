import SwiftUI

@Observable
class AppState {
    var isOnboardingComplete: Bool {
        didSet { UserDefaults.standard.set(isOnboardingComplete, forKey: "isOnboardingComplete") }
    }

    var activeCatId: UUID? {
        get { UUID(uuidString: activeCatIdString) }
        set {
            activeCatIdString = newValue?.uuidString ?? ""
            UserDefaults.standard.set(activeCatIdString, forKey: "activeCatId")
        }
    }

    private var activeCatIdString: String

    init() {
        self.isOnboardingComplete = UserDefaults.standard.bool(forKey: "isOnboardingComplete")
        self.activeCatIdString = UserDefaults.standard.string(forKey: "activeCatId") ?? ""
    }
}
