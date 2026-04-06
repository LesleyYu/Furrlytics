import SwiftUI
import MapKit
import CoreLocation

struct LocationPickerView: View {
    @Binding var latitude: Double
    @Binding var longitude: Double
    @Binding var radiusMeters: Double

    @State private var cameraPosition: MapCameraPosition = .automatic
    @State private var locationFetcher = LocationFetcher()

    var body: some View {
        VStack(spacing: 16) {
            mapSection
            radiusSlider
            coordinateDisplay
        }
        .onAppear { fetchInitialLocation() }
    }

    // MARK: - Subviews

    private var mapSection: some View {
        MapReader { proxy in
            Map(position: $cameraPosition) {
                Annotation("Home", coordinate: pinCoordinate) {
                    pinView
                }
                MapCircle(center: pinCoordinate, radius: radiusMeters)
                    .foregroundStyle(.blue.opacity(0.15))
                    .stroke(.blue.opacity(0.5), lineWidth: 1)
            }
            .mapControls {
                MapUserLocationButton()
                MapCompass()
            }
            .onTapGesture { screenPoint in
                guard let coordinate = proxy.convert(screenPoint, from: .local) else { return }
                updatePin(to: coordinate)
            }
        }
        .frame(height: 350)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private var pinView: some View {
        Image(systemName: "house.circle.fill")
            .font(.title)
            .foregroundStyle(.white, .blue)
    }

    private var radiusSlider: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("围栏半径: \(Int(radiusMeters))米")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Slider(value: $radiusMeters, in: 100...500, step: 25)
        }
        .padding(.horizontal)
    }

    private var coordinateDisplay: some View {
        Text(String(format: "%.4f, %.4f", latitude, longitude))
            .font(.caption)
            .foregroundStyle(.tertiary)
    }

    // MARK: - Computed

    private var pinCoordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }

    // MARK: - Actions

    private func fetchInitialLocation() {
        guard latitude == 0 && longitude == 0 else {
            centerCamera()
            return
        }

        locationFetcher.requestLocation { coordinate in
            latitude = coordinate.latitude
            longitude = coordinate.longitude
            centerCamera()
        }
    }

    private func updatePin(to coordinate: CLLocationCoordinate2D) {
        latitude = coordinate.latitude
        longitude = coordinate.longitude
        centerCamera()
    }

    private func centerCamera() {
        withAnimation {
            cameraPosition = .region(MKCoordinateRegion(
                center: pinCoordinate,
                latitudinalMeters: radiusMeters * 4,
                longitudinalMeters: radiusMeters * 4
            ))
        }
    }
}

// MARK: - Location Fetcher

@Observable
private class LocationFetcher: NSObject, CLLocationManagerDelegate {
    private let manager = CLLocationManager()
    private var completion: ((CLLocationCoordinate2D) -> Void)?
    private var didDeliver = false

    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
    }

    func requestLocation(completion: @escaping (CLLocationCoordinate2D) -> Void) {
        self.completion = completion
        didDeliver = false

        switch manager.authorizationStatus {
        case .notDetermined:
            manager.requestWhenInUseAuthorization()
        case .authorizedWhenInUse, .authorizedAlways:
            manager.requestLocation()
        default:
            deliverDefault()
        }
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        guard !didDeliver else { return }
        switch manager.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            manager.requestLocation()
        case .denied, .restricted:
            deliverDefault()
        default:
            break
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard !didDeliver, let location = locations.first else { return }
        didDeliver = true
        completion?(location.coordinate)
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        guard !didDeliver else { return }
        deliverDefault()
    }

    private func deliverDefault() {
        didDeliver = true
        // Default to a central location if GPS unavailable
        completion?(CLLocationCoordinate2D(latitude: 39.9042, longitude: 116.4074))
    }
}
