//
//  AchievementManager.swift
//  TheRoamingKin
//
//  Created by Lovice Sunuwar on 02/05/2025.
//

import Foundation
import UserNotifications
import SwiftUI

// Achievement.swift

import Foundation

struct Achievement: Identifiable, Codable, Equatable {
    var id: UUID = UUID()
    let title: String
    let description: String
    let imageName: String
    let attributeAffected: AttributeType
    let points: Int

    enum AttributeType: String, Codable {
        case strength
        case constitution
        case dexterity
        case intelligence
        case wisdom
        case none
    }
}

import Foundation
import SwiftUI
import UserNotifications
import FirebaseFirestore
import FirebaseAuth

@MainActor
class AchievementUnlockManager: ObservableObject {
    static let shared = AchievementUnlockManager()

    @Published var unlockedAchievements: [Achievement] = []
    @Published var showToast: Bool = false
    @Published var toastMessage: String = ""

    private let db = Firestore.firestore()

    func unlock(achievement: Achievement, attributesManager: AttributesManager, scenePhase: ScenePhase) {
        guard !unlockedAchievements.contains(achievement) else {
            print("❌ Achievement already unlocked: \(achievement.title)")
            return
        }

        unlockedAchievements.append(achievement)
        AchievementService.uploadAchievement(achievement) // Save immediately to Firebase

        if achievement.attributeAffected != .none {
            attributesManager.claimPoints(for: achievement.attributeAffected.rawValue, points: achievement.points)
            AttributesService.uploadAttributes( // Save latest attributes after points added
                strength: attributesManager.strength,
                constitution: attributesManager.constitution,
                dexterity: attributesManager.dexterity,
                intelligence: attributesManager.intelligence,
                wisdom: attributesManager.wisdom
            )
        }

        let message = "🎖️ \(achievement.title) unlocked! +\(achievement.points) \(achievement.attributeAffected.rawValue.capitalized)"

        if scenePhase == .active {
            toastMessage = message
            withAnimation {
                showToast = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
                withAnimation {
                    self.showToast = false
                }
            }
        } else {
            sendLocalNotification(message: message)
        }
    }

    private func sendLocalNotification(message: String) {
        let content = UNMutableNotificationContent()
        content.title = "Achievement Unlocked!"
        content.body = message
        content.sound = .default

        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: nil
        )

        UNUserNotificationCenter.current().add(request)
    }

    func loadUnlockedAchievements() async {
        guard let uid = Auth.auth().currentUser?.uid else { return }

        do {
            let snapshot = try await db.collection("users")
                .document(uid)
                .collection("achievements")
                .getDocuments()

            let achievements = snapshot.documents.compactMap { doc -> Achievement? in
                guard let title = doc.data()["title"] as? String,
                      let description = doc.data()["description"] as? String,
                      let imageName = doc.data()["imageName"] as? String
                else { return nil }

                // Match to local achievement template to get attributeAffected and points
                if let template = AchievementLibrary.allAchievements.first(where: { $0.title == title }) {
                    return Achievement(
                        id: UUID(uuidString: doc.documentID) ?? UUID(),
                        title: title,
                        description: description,
                        imageName: imageName,
                        attributeAffected: template.attributeAffected,
                        points: template.points
                    )
                }
                return nil
            }

            DispatchQueue.main.async {
                self.unlockedAchievements = achievements
                print("✅ Synced achievements from Firebase")
            }
        } catch {
            print("❌ Failed to load achievements: \(error.localizedDescription)")
        }
    }

    func resetUnlockedAchievements() {
        unlockedAchievements = []
        print("🧹 Cleared unlocked achievements on logout")
    }
}
