//
//  POI.swift
//  TheRoamingKin
//
//  Created by Lovice Sunuwar on 08/05/2025.
//

import Foundation
import MapKit

struct POI: Identifiable {
    let id = UUID()
    let coordinate: CLLocationCoordinate2D
    let category: String

    var imageName: String? {
        switch category.lowercased() {
        case "amusementpark": return "POI_AmusementPark"
        //case "aquarium": return "POI_Aquarium"
        case "bakery": return "POI_Bakery"
        case "beach": return "POI_Beach"
        case "brewery": return "POI_Brewery"
        case "cafe": return "POI_Cafe"
        case "campground": return "POI_Campground"
        //case "firestation": return "POI_FireStation"
        case "fitnesscenter": return "POI_FitnessCenter"
        //case "hospital": return "POI_Hospital"
        case "hotel": return "POI_Hotel"
        case "library": return "POI_Library"
        case "movietheater": return "POI_MovieTheater"
        case "museum": return "POI_Museum"
        case "nationalpark": return "POI_NationalPark"
        case "park": return "POI_Park"
        case "restaurant": return "POI_Restaurant"
        case "school": return "POI_School"
        //case "stadium": return "POI_Stadium"
        case "theater": return "POI_Theater"
        case "zoo": return "POI_Zoo"
        case "fishingspot": return "POI_FishingSpot"
        default:
            print("Unknown POI category: \(category)")
            return nil
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
