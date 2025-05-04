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
    @Published var userLocation: CLLocationCoordinate2D?
    @Published var zoomLevel: Double = 0.05
    @Published var currentSpeed: Double = 0.0 // meters per second


    private var lastCity: String?
    private var hasSavedCityToFirestore = false

    private var allPOIs: [POI] = []

    private let manager = CLLocationManager()
    private let geocoder = CLGeocoder()

    var filteredPOIs: [POI] {
        guard let region = region else { return [] }

        let visiblePOIs = allPOIs.filter { poi in
            region.contains(poi.coordinate)
        }

        let limit: Int
        switch zoomLevel {
        case 0..<0.02: // Very zoomed in
            limit = visiblePOIs.count // Show everything
        case 0.02..<0.05: // Medium zoom
            limit = min(20, visiblePOIs.count)
        case 0.05..<0.1: // Zoomed out
            limit = min(10, visiblePOIs.count)
        default: // Very far zoomed out
            limit = min(5, visiblePOIs.count)
        }

        return Array(visiblePOIs.prefix(limit))
    }


    var annotationSize: CGFloat {
        switch zoomLevel {
        case 0..<0.02:
            return 28
        case 0.02..<0.05:
            return 22
        case 0.05..<0.1:
            return 18
        default:
            return 14
        }
    }

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

            if let speed = locations.last?.speed, speed >= 0 {
                self.currentSpeed = speed // Speed in meters per second
            } else {
                self.currentSpeed = 0
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
                    pois.append(POI(coordinate: item.placemark.coordinate, category: category))
                }
            }
        }

        DispatchQueue.main.async {
            self.allPOIs = pois
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

extension MKCoordinateRegion {
    func contains(_ coordinate: CLLocationCoordinate2D) -> Bool {
        let latMin = center.latitude - span.latitudeDelta / 2
        let latMax = center.latitude + span.latitudeDelta / 2
        let lonMin = center.longitude - span.longitudeDelta / 2
        let lonMax = center.longitude + span.longitudeDelta / 2

        return (latMin...latMax).contains(coordinate.latitude) &&
               (lonMin...lonMax).contains(coordinate.longitude)
    }
}


