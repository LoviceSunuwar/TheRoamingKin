import Foundation
import MapKit
import Combine
import FirebaseFirestore
import FirebaseAuth

struct POI: Identifiable {
    let id = UUID()
    let coordinate: CLLocationCoordinate2D
    let category: String

    var symbol: String {
        switch category {
        case "airport": return "airplane"
        case "amusementpark": return "ferris.wheel"
        case "aquarium": return "tortoise"
        case "bakery": return "cupcake"
        case "beach": return "sun.max"
        case "brewery": return "wineglass"
        case "cafe": return "cup.and.saucer"
        case "campground": return "tent"
        case "firestation": return "flame"
        case "fitnesscenter": return "figure.walk"
        case "hospital": return "cross.case"
        case "hotel": return "bed.double"
        case "library": return "books.vertical"
        case "movietheater": return "film"
        case "museum": return "building.columns"
        case "nationalpark": return "leaf"
        case "park": return "tree"
        case "pharmacy": return "pills"
        case "restaurant": return "fork.knife"
        case "school": return "graduationcap"
        case "stadium": return "sportscourt"
        case "theater": return "theatermasks"
        case "winery": return "wineglass"
        case "zoo": return "pawprint"
        case "fishingspot": return "fish"
        default: return "mappin"
        }
    }
}

extension POI: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(coordinate.latitude)
        hasher.combine(coordinate.longitude)
        hasher.combine(category)
    }

    static func == (lhs: POI, rhs: POI) -> Bool {
        lhs.id == rhs.id
    }
}

@MainActor
class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    @Published var region: MKCoordinateRegion?
    @Published var filteredPOIs: [POI] = []
    @Published var userLocation: CLLocationCoordinate2D?

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

        DispatchQueue.main.async {
            self.userLocation = location.coordinate
            if self.region == nil {
                self.region = MKCoordinateRegion(
                    center: location.coordinate,
                    span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
                )
            }
            Task {
                await self.updateCity(for: location)
            }
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
                    await fetchPOIsNearby(center: location.coordinate)

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

    private func fetchPOIsNearby(center: CLLocationCoordinate2D) async {
        let searchRegion = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1))
        let userLocation = CLLocation(latitude: center.latitude, longitude: center.longitude)

        let categories = [
            "airport", "amusementpark", "aquarium", "bakery", "beach",
            "brewery", "cafe", "campground", "firestation", "fitnesscenter",
            "hospital", "hotel", "library", "movietheater", "museum",
            "nationalpark", "park", "pharmacy", "restaurant", "school",
            "stadium", "theater", "university", "winery", "zoo", "fishingspot"
        ]

        var pois: [POI] = []

        for category in categories {
            let request = MKLocalSearch.Request()
            request.naturalLanguageQuery = category
            request.region = searchRegion

            let search = MKLocalSearch(request: request)
            if let response = try? await search.start() {
                for item in response.mapItems {
                    let coord = item.placemark.coordinate
                    let loc = CLLocation(latitude: coord.latitude, longitude: coord.longitude)
                    if userLocation.distance(from: loc) <= 5000 {
                        pois.append(POI(coordinate: coord, category: category))
                    }
                }
            }
        }

        DispatchQueue.main.async {
            self.filteredPOIs = pois
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
            print("✅ Saved city: \(city), country: \(country)")
        } catch {
            print("❌ Firestore save error: \(error.localizedDescription)")
        }
    }
}
