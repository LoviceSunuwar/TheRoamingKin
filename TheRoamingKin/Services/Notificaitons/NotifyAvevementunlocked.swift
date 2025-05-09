//
//  NotifyAvevementunlocked.swift
//  TheRoamingKin
//
//  Created by Lovice Sunuwar on 02/05/2025.
//

import UserNotifications

private func notifyAchievementUnlocked(_ achievement: Achievement) {
    let center = UNUserNotificationCenter.current()
    let content = UNMutableNotificationContent()
    content.title = "🎖️ Achievement Unlocked!"
    content.body = achievement.title
    content.sound = .default

    let request = UNNotificationRequest(
        identifier: UUID().uuidString,
        content: content,
        trigger: nil // Immediate
    )

    center.add(request)
}
