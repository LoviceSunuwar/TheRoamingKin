//
//  AchievementManager.swift
//  TheRoamingKin
//
//  Created by Lovice Sunuwar on 02/05/2025.
//

import Foundation
import UserNotifications

struct Achievement: Identifiable, Hashable {
    let id = UUID()
    let title: String
    let description: String
    let imageName: String
    let bonusAttribute: BonusAttribute?

    struct BonusAttribute: Hashable {
        let attributeName: String // like "intelligence", "strength"
        let points: Int
    }
}


@MainActor
class AchievementUnlockManager: ObservableObject {
    @Published var unlockedAchievements: [Achievement] = []

    private var unlockedTitles: Set<String> = []

    func unlockAchievement(title: String, description: String, imageName: String) {
        guard !unlockedTitles.contains(title) else {
            print("❌ Achievement already unlocked: \(title)")
            return
        }

        let achievement = Achievement(title: title, description: description, imageName: imageName)
        unlockedAchievements.append(achievement)
        unlockedTitles.insert(title)

        sendPushNotification(for: achievement)
        print("🏆 Achievement unlocked: \(title)")
    }

    private func sendPushNotification(for achievement: Achievement) {
        let content = UNMutableNotificationContent()
        content.title = "🏆 Achievement Unlocked!"
        content.body = "\(achievement.title): \(achievement.description)"
        content.sound = .default

        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: nil
        )

        UNUserNotificationCenter.current().add(request)
    }
}
