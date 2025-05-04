//
//  SpeedMonitor.swift
//  TheRoamingKin
//
//  Created by Lovice Sunuwar on 03/05/2025.
//

import Foundation
import CoreLocation
import SwiftUI

@MainActor
class SpeedMonitor: ObservableObject {
    private var achievementUnlockManager = AchievementUnlockManager.shared

    func checkSpeed(
        speedMetersPerSecond: Double,
        attributesManager: AttributesManager,
        scenePhase: ScenePhase
    ) {
        let speedKmh = speedMetersPerSecond * 3.6

        if (30...40).contains(speedKmh) {
            if let voyagerAchievement = AchievementLibrary.allAchievements.first(where: { $0.title == "Voyager" }) {
                achievementUnlockManager.unlock(
                    achievement: voyagerAchievement,
                    attributesManager: attributesManager,
                    scenePhase: scenePhase
                )
            }
        } else if speedKmh > 80 {
            if let shuttleExplorerAchievement = AchievementLibrary.allAchievements.first(where: { $0.title == "Shuttle Explorer" }) {
                achievementUnlockManager.unlock(
                    achievement: shuttleExplorerAchievement,
                    attributesManager: attributesManager,
                    scenePhase: scenePhase
                )
            }
        }
    }
}
