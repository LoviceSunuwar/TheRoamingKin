//
//  ProximityMonitor.swift
//  TheRoamingKin
//
//  Created by Lovice Sunuwar on 02/05/2025.
//

import Foundation
import CoreLocation
import MapKit
import SwiftUI

struct ProximityConfig {
    let title: String
    let category: String
    let distanceThreshold: Double
    let stayDuration: TimeInterval
}

@MainActor
class ProximityMonitor: ObservableObject {
    @Published var isNearPOI: Bool = false
    private var timer: Timer?

    private let proximityConfigs: [ProximityConfig] = [
        // Basic tutorial / welcome achievement
        ProximityConfig(title: "Guild Registration", category: "home", distanceThreshold: 100, stayDuration: 1),

        // Movement and walking achievements
        ProximityConfig(title: "Walker", category: "walk", distanceThreshold: 0, stayDuration: 0),
        ProximityConfig(title: "Explorer", category: "walk", distanceThreshold: 0, stayDuration: 0),
        ProximityConfig(title: "Endurance Pro", category: "walk", distanceThreshold: 0, stayDuration: 0),
        ProximityConfig(title: "Sprinter", category: "run", distanceThreshold: 0, stayDuration: 0),

        // Specific places
        ProximityConfig(title: "Bookworm", category: "library", distanceThreshold: 100, stayDuration: 5),
        ProximityConfig(title: "Fisherman", category: "beach", distanceThreshold: 100, stayDuration: 5),
        ProximityConfig(title: "Naturalist", category: "tree", distanceThreshold: 100, stayDuration: 5),
        ProximityConfig(title: "Voyager", category: "road", distanceThreshold: 0, stayDuration: 0),
        ProximityConfig(title: "Shuttle Explorer", category: "highway", distanceThreshold: 0, stayDuration: 0),
        ProximityConfig(title: "Campfire Hero", category: "campground", distanceThreshold: 100, stayDuration: 5),
        ProximityConfig(title: "Night Owl", category: "walk_night", distanceThreshold: 0, stayDuration: 0),
        ProximityConfig(title: "Cafe Hopper", category: "cafe", distanceThreshold: 100, stayDuration: 5),
        ProximityConfig(title: "Meditator", category: "park", distanceThreshold: 100, stayDuration: 5),
        ProximityConfig(title: "Lifesaver", category: "hospital", distanceThreshold: 100, stayDuration: 5),
        ProximityConfig(title: "Performer", category: "theater", distanceThreshold: 100, stayDuration: 5),
        ProximityConfig(title: "Storyteller", category: "museum", distanceThreshold: 100, stayDuration: 5),
        ProximityConfig(title: "Strength Booster", category: "active_calories", distanceThreshold: 0, stayDuration: 0),
        ProximityConfig(title: "Forest Whisperer", category: "national park", distanceThreshold: 100, stayDuration: 5),
        ProximityConfig(title: "Scholar", category: "university", distanceThreshold: 100, stayDuration: 5),
        ProximityConfig(title: "Trail Blazer", category: "poi", distanceThreshold: 0, stayDuration: 0)
    ]


    func checkProximity(
        to pois: [POI],
        userLocation: CLLocationCoordinate2D,
        attributesManager: AttributesManager,
        scenePhase: ScenePhase
    ) {
        let userLoc = CLLocation(latitude: userLocation.latitude, longitude: userLocation.longitude)

        for config in proximityConfigs {
            if let poi = pois.first(where: { $0.category.lowercased() == config.category.lowercased() }) {
                let poiLoc = CLLocation(latitude: poi.coordinate.latitude, longitude: poi.coordinate.longitude)
                let distance = userLoc.distance(from: poiLoc)

                if distance <= config.distanceThreshold {
                    if timer == nil {
                        startTimer(
                            attributesManager: attributesManager,
                            scenePhase: scenePhase,
                            achievementTitle: config.title,
                            stayDuration: config.stayDuration
                        )
                    }
                    return
                }
            }
        }

        // No matching POI close enough
        resetTimer()
    }

    private func startTimer(
        attributesManager: AttributesManager,
        scenePhase: ScenePhase,
        achievementTitle: String,
        stayDuration: TimeInterval
    ) {
        timer = Timer.scheduledTimer(withTimeInterval: stayDuration, repeats: false) { [weak self] _ in
            guard let self else { return }
            Task { @MainActor in
                self.unlockAchievement(
                    attributesManager: attributesManager,
                    scenePhase: scenePhase,
                    title: achievementTitle
                )
            }
        }
    }

    private func resetTimer() {
        timer?.invalidate()
        timer = nil
    }

    private func unlockAchievement(
        attributesManager: AttributesManager,
        scenePhase: ScenePhase,
        title: String
    ) {
        resetTimer()

        if let achievement = AchievementLibrary.allAchievements.first(where: { $0.title == title }) {
            AchievementUnlockManager.shared.unlock(
                achievement: achievement,
                attributesManager: attributesManager,
                scenePhase: scenePhase
            )
        }
    }
}

// MARK: - CLLocationCoordinate2D Equatable Support
extension CLLocationCoordinate2D: Equatable {
    public static func == (lhs: CLLocationCoordinate2D, rhs: CLLocationCoordinate2D) -> Bool {
        lhs.latitude == rhs.latitude && lhs.longitude == rhs.longitude
    }
}
