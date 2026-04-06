import SwiftUI
import SwiftData

struct OnboardingFlowView: View {
    @Environment(AppState.self) private var appState
    @Environment(\.modelContext) private var modelContext

    @State private var currentStep = OnboardingStep.catProfile

    var body: some View {
        NavigationStack {
            Group {
                switch currentStep {
                case .catProfile:
                    CatProfileSetupView(onComplete: handleCatProfilesCreated)
                case .homeLocation:
                    HomeLocationSetupView(onComplete: handleHomeLocationSet)
                case .petlibroConnect:
                    PetlibroConnectView(
                        onComplete: finishOnboarding,
                        onSkip: finishOnboarding
                    )
                }
            }
            .animation(.easeInOut, value: currentStep)
        }
    }

    // MARK: - Actions

    private func handleCatProfilesCreated(_ profiles: [CatProfile]) {
        for profile in profiles {
            modelContext.insert(profile)
        }
        if let firstCat = profiles.first {
            appState.activeCatId = firstCat.id
        }
        currentStep = .homeLocation
    }

    private func handleHomeLocationSet(_ location: HomeLocation) {
        modelContext.insert(location)
        currentStep = .petlibroConnect
    }

    private func finishOnboarding() {
        appState.isOnboardingComplete = true
    }
}

// MARK: - Step Enum

private enum OnboardingStep: Int, CaseIterable {
    case catProfile
    case homeLocation
    case petlibroConnect
}
