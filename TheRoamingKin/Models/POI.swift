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
