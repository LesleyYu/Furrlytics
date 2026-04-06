import SwiftUI
import SwiftData

struct HomeLocationSettingsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var homeLocations: [HomeLocation]

    @State private var latitude: Double = 0
    @State private var longitude: Double = 0
    @State private var radiusMeters: Double = GeofenceDefaults.radiusMeters
    @State private var didSave = false

    var body: some View {
        VStack(spacing: 16) {
            LocationPickerView(
                latitude: $latitude,
                longitude: $longitude,
                radiusMeters: $radiusMeters
            )
            saveButton
        }
        .padding()
        .navigationTitle("家的位置")
        .onAppear { loadExistingLocation() }
    }

    // MARK: - Subviews

    private var saveButton: some View {
        Button {
            saveLocation()
        } label: {
            Text(didSave ? "已保存 ✓" : "保存")
                .font(.headline)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.accentColor)
                .foregroundStyle(.white)
                .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }

    // MARK: - Actions

    private func loadExistingLocation() {
        guard let existing = homeLocations.first else { return }
        latitude = existing.latitude
        longitude = existing.longitude
        radiusMeters = existing.radiusMeters
    }

    private func saveLocation() {
        if let existing = homeLocations.first {
            existing.latitude = latitude
            existing.longitude = longitude
            existing.radiusMeters = radiusMeters
        } else {
            let location = HomeLocation(
                latitude: latitude,
                longitude: longitude,
                radiusMeters: radiusMeters
            )
            modelContext.insert(location)
        }
        didSave = true
    }
}
