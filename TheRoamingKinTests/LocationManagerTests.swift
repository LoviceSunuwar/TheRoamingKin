//
//  LocationManagerTests.swift
//  TheRoamingKin
//
//  Created by Lovice Sunuwar on 29/04/2025.
//

import XCTest
@testable import TheRoamingKin

@MainActor
final class LocationManagerTests: XCTestCase {
    var locationManager: LocationManager!

    override func setUp() {
        super.setUp()
        locationManager = LocationManager()
    }

    func testInitialCameraPosition() {
        XCTAssertEqual(locationManager.cameraPosition, .userLocation(fallback: .automatic))
    }

    func testSaveCityFailsIfNotLoggedIn() async {
        await locationManager.saveCityAndCountryToFirestore(city: "TestCity", country: "TestCountry")
        // no crash = pass (or spy on Firestore method if mocked)
    }

    // Further tests can mock CLLocationManager, CLGeocoder, Firestore
}
