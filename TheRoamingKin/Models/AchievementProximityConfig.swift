//
//  AchievementProximityConfig.swift
//  TheRoamingKin
//
//  Created by Lovice Sunuwar on 02/05/2025.
//
import SwiftUI

struct AchievementProximityConfig {
    let title: String          // Achievement title (matches in library)
    let category: String       // POI category
    let distanceThreshold: Double // How close (meters)
    let stayDuration: TimeInterval // How long to stay (seconds)
}
