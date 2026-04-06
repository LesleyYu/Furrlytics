import SwiftUI

struct HomeLocationSetupView: View {
    @State private var latitude: Double = 0
    @State private var longitude: Double = 0
    @State private var radiusMeters: Double = GeofenceDefaults.radiusMeters

    let onComplete: (HomeLocation) -> Void

    var body: some View {
        VStack(spacing: 24) {
            headerSection
            LocationPickerView(
                latitude: $latitude,
                longitude: $longitude,
                radiusMeters: $radiusMeters
            )
            continueButton
        }
        .padding()
        .navigationTitle("设置家的位置")
        .navigationBarTitleDisplayMode(.large)
    }

    // MARK: - Subviews

    private var headerSection: some View {
        VStack(spacing: 8) {
            Image(systemName: "house.fill")
                .font(.system(size: 40))
                .foregroundStyle(.tint)
            Text("点击地图设置家的位置")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }

    private var continueButton: some View {
        Button {
            let location = HomeLocation(
                latitude: latitude,
                longitude: longitude,
                radiusMeters: radiusMeters
            )
            onComplete(location)
        } label: {
            Text("继续")
                .font(.headline)
                .frame(maxWidth: .infinity)
                .padding()
                .background(hasValidLocation ? Color.accentColor : Color.gray.opacity(0.3))
                .foregroundStyle(.white)
                .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .disabled(!hasValidLocation)
    }

    // MARK: - Computed

    private var hasValidLocation: Bool {
        latitude != 0 || longitude != 0
    }
}
