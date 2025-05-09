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
        ProximityConfig(title: "Healer's Path", category: "hospital", distanceThreshold: 150, stayDuration: 5),
        ProximityConfig(title: "Cafe Lover", category: "cafe", distanceThreshold: 150, stayDuration: 5),
        ProximityConfig(title: "Museum Wanderer", category: "museum", distanceThreshold: 150, stayDuration: 5),
        ProximityConfig(title: "Forever learner", category: "university",distanceThreshold: 200, stayDuration: 5)
    ]

    func checkProximity(
        to pois: [POI],
        userLocation: CLLocationCoordinate2D,
        attributesManager: AttributesManager,
        scenePhase: ScenePhase,
        sessionActive: Bool
    ) {
        guard sessionActive else { return } // 🛑 Must be during active session

        let userLoc = CLLocation(latitude: userLocation.latitude, longitude: userLocation.longitude)

        for config in proximityConfigs {
            if let poi = pois.first(where: { $0.category.lowercased() == config.category.lowercased() }) {
                let poiLoc = CLLocation(latitude: poi.coordinate.latitude, longitude: poi.coordinate.longitude)
                let distance = userLoc.distance(from: poiLoc)

                if distance <= config.distanceThreshold {
                    // Before starting timer, double check achievement doesn't require photo
                    if let achievement = AchievementLibrary.allAchievements.first(where: { $0.title == config.title }) {
                        if achievement.requiredPhotoLabel == nil {
                            if timer == nil {
                                startTimer(
                                    attributesManager: attributesManager,
                                    scenePhase: scenePhase,
                                    achievementTitle: config.title,
                                    stayDuration: config.stayDuration
                                )
                            }
                        } else {
                            print("⛔ Skipping proximity unlock: \(achievement.title) needs a photo capture")
                        }
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

        guard let achievement = AchievementLibrary.allAchievements.first(where: { $0.title == title }) else {
            return
        }

        // 🛑 Check if already unlocked
        if AchievementUnlockManager.shared.unlockedAchievements.contains(where: { $0.id == achievement.id }) {
            print("✅ Already unlocked previously: \(achievement.title) - Skipping unlock")
            return
        }

        // 🏆 If not unlocked yet, unlock it
        AchievementUnlockManager.shared.unlock(
            achievement: achievement,
            attributesManager: attributesManager,
            scenePhase: scenePhase
        )
    }

}

// MARK: - CLLocationCoordinate2D Equatable Support
extension CLLocationCoordinate2D: Equatable {
    public static func == (lhs: CLLocationCoordinate2D, rhs: CLLocationCoordinate2D) -> Bool {
        lhs.latitude == rhs.latitude && lhs.longitude == rhs.longitude
    }
}
