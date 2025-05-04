//
//  AchievementUnlockManager.swift
//  TheRoamingKin
//
//  Created by Lovice Sunuwar on 29/04/2025.
//

import Foundation
import SwiftUI
import UserNotifications
import FirebaseFirestore
import FirebaseAuth
import CoreLocation

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
            showAlreadyUnlockedToast(for: achievement.title)
            return
        }

        unlockedAchievements.append(achievement)

        AchievementService.uploadAchievement(achievement)

        if achievement.attributeAffected != .none {
            attributesManager.claimPoints(for: achievement.attributeAffected.rawValue, points: achievement.points)

            AttributesService.uploadAttributes(
                strength: attributesManager.strength,
                constitution: attributesManager.constitution,
                dexterity: attributesManager.dexterity,
                intelligence: attributesManager.intelligence,
                wisdom: attributesManager.wisdom
            )
        }

        let message = "🎖️ \(achievement.title) unlocked! +\(achievement.points) \(achievement.attributeAffected.rawValue.capitalized)"

        if scenePhase == .active {
            showToastMessage(message)
        } else {
            sendLocalNotification(message: message)
        }
    }

    private func showAlreadyUnlockedToast(for title: String) {
        let message = "⭐ Already unlocked: \(title)"
        showToastMessage(message)
    }

    private func showToastMessage(_ message: String) {
        DispatchQueue.main.async {
            self.toastMessage = message
            withAnimation {
                self.showToast = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
                withAnimation {
                    self.showToast = false
                }
            }
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

@MainActor
extension AchievementUnlockManager {

    func attemptUnlockAchievements(
        locationManager: LocationManager,
        capturedLabel: String?,
        sessionActive: Bool,
        attributesManager: AttributesManager,
        scenePhase: ScenePhase
    ) {
        guard let userLocation = locationManager.userLocation else { return }
        let location = CLLocation(latitude: userLocation.latitude, longitude: userLocation.longitude)

        for achievement in AchievementLibrary.allAchievements {

            if unlockedAchievements.contains(achievement) {
                continue
            }

            if achievement.requiredSessionActive && !sessionActive {
                continue
            }

            if let requiredPOI = achievement.triggerPOICategory {
                let matchingPOI = locationManager.filteredPOIs.first {
                    $0.category.lowercased() == requiredPOI.lowercased() &&
                    CLLocation(latitude: $0.coordinate.latitude, longitude: $0.coordinate.longitude)
                        .distance(from: location) <= 100
                }
                if matchingPOI == nil {
                    continue
                }
            }

            if let requiredLabel = achievement.requiredPhotoLabel?.lowercased() {
                if capturedLabel?.lowercased().contains(requiredLabel) != true {
                    continue
                }
            }

            print("🏆 Unlocking dynamic achievement: \(achievement.title)")
            unlock(achievement: achievement, attributesManager: attributesManager, scenePhase: scenePhase)
        }
    }
}
