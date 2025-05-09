//
//  AchievementService.swift
//  TheRoamingKin
//
//  Created by Lovice Sunuwar on 02/05/2025.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth

struct AchievementService {
    static func uploadAchievement(_ achievement: Achievement) {
        guard let uid = Auth.auth().currentUser?.uid else { return }

        Task {
            let db = Firestore.firestore()
            let achievementData: [String: Any] = [
                "title": achievement.title,
                "description": achievement.description,
                "imageName": achievement.imageName,
                "unlockedAt": Timestamp(date: Date())
            ]

            do {
                try await db.collection("users")
                    .document(uid)
                    .collection("achievements")
                    .document(achievement.id.uuidString)
                    .setData(achievementData)

                print("✅ Achievement uploaded: \(achievement.title)")
            } catch {
                print("❌ Error uploading achievement: \(error.localizedDescription)")
            }
        }
    }
}
