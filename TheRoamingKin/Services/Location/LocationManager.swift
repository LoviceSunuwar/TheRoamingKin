import Foundation
import _MapKit_SwiftUI
import MapKit
import Combine
import FirebaseFirestore
import FirebaseAuth

@MainActor
class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    @Published var cameraPosition: MapCameraPosition = .userLocation(fallback: .automatic)
    @Published var cameraCenter: CLLocationCoordinate2D = .init()
    @Published var lockedRegion: MKCoordinateRegion?
    @Published var currentLocation: CLLocationCoordinate2D?
    @Published var cityBoundaryPolygon: MKPolygon?

    private var lastCity: String?
    private var hasSavedCityToFirestore = false

    private let manager = CLLocationManager()
    private let geocoder = CLGeocoder()

    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
    }

    func requestPermission() {
        manager.requestWhenInUseAuthorization()
        manager.startUpdatingLocation()
    }

    nonisolated func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }

        Task { @MainActor in
            self.currentLocation = location.coordinate
            self.cameraCenter = location.coordinate
            await updateCity(for: location)
        }
    }

    private func updateCity(for location: CLLocation) async {
        do {
            let placemarks = try await geocoder.reverseGeocodeLocation(location)

            if let placemark = placemarks.first,
               let city = placemark.locality,
               let country = placemark.country {

                if city != lastCity {
                    print("🌆 City: \(city)")
                    lastCity = city
                    await fetchCityRegion(named: city)

                    if !hasSavedCityToFirestore {
                        await saveCityAndCountryToFirestore(city: city, country: country)
                        hasSavedCityToFirestore = true
                    }
                }
            }
        } catch {
            print("❌ Geocoding failed: \(error.localizedDescription)")
        }
    }

    private func fetchCityRegion(named city: String) async {
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = city

        let search = MKLocalSearch(request: request)
        do {
            let response = try await search.start()
            let region = response.boundingRegion
            self.lockedRegion = region
            self.cameraCenter = region.center

            // Build city boundary polygon
            let topLeft = CLLocationCoordinate2D(
                latitude: region.center.latitude + region.span.latitudeDelta / 2,
                longitude: region.center.longitude - region.span.longitudeDelta / 2
            )
            let topRight = CLLocationCoordinate2D(
                latitude: region.center.latitude + region.span.latitudeDelta / 2,
                longitude: region.center.longitude + region.span.longitudeDelta / 2
            )
            let bottomRight = CLLocationCoordinate2D(
                latitude: region.center.latitude - region.span.latitudeDelta / 2,
                longitude: region.center.longitude + region.span.longitudeDelta / 2
            )
            let bottomLeft = CLLocationCoordinate2D(
                latitude: region.center.latitude - region.span.latitudeDelta / 2,
                longitude: region.center.longitude - region.span.longitudeDelta / 2
            )

            let coords = [topLeft, topRight, bottomRight, bottomLeft]
            self.cityBoundaryPolygon = MKPolygon(coordinates: coords, count: coords.count)

        } catch {
            print("❌ Failed to fetch city region: \(error.localizedDescription)")
        }
    }

    func saveCityAndCountryToFirestore(city: String, country: String) async {
        guard let uid = Auth.auth().currentUser?.uid else { return }

        let docRef = Firestore.firestore().collection("users").document(uid)

        do {
            try await docRef.setData([
                "visitedCities": FieldValue.arrayUnion([city]),
                "visitedCountries": FieldValue.arrayUnion([country])
            ], merge: true)

            print("✅ Saved city: \(city), country: \(country) to Firestore")

        } catch {
            print("❌ Error saving city/country to Firestore: \(error.localizedDescription)")
        }
    }
}
