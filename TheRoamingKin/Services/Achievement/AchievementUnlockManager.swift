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

    private var unlockedIDs: Set<UUID> = []
    @Published var isLoaded: Bool = false
    private let db = Firestore.firestore()

    func unlock(achievement: Achievement, attributesManager: AttributesManager, scenePhase: ScenePhase) {
        Task {
            // 🔥 1. Local fast Set check
            if unlockedIDs.contains(achievement.id) {
                print("✅ Already unlocked locally: \(achievement.title) - Skipping unlock")
                return
            }

            do {
                // 🔥 2. Remote Firestore check
                guard let uid = Auth.auth().currentUser?.uid else { return }
                let snapshot = try await db.collection("users")
                    .document(uid)
                    .collection("achievements")
                    .document(achievement.id.uuidString)
                    .getDocument()

                if snapshot.exists {
                    print("✅ Already unlocked on Firestore: \(achievement.title) - Syncing locally")
                    DispatchQueue.main.async {
                        self.unlockedAchievements.append(achievement)
                        self.unlockedIDs.insert(achievement.id) // Sync Set too
                    }
                    return
                }

                // 🔥 3. Safe to unlock
                unlockedAchievements.append(achievement)
                unlockedIDs.insert(achievement.id)

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

                print("🏆 Achievement unlocked and saved: \(achievement.title)")

            } catch {
                print("❌ Error checking Firestore for achievement: \(error.localizedDescription)")
            }
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
                self.unlockedIDs = Set(achievements.map { $0.id })
                self.isLoaded = true
                print("✅ Synced achievements from Firebase")
            }
        } catch {
            print("❌ Failed to load achievements: \(error.localizedDescription)")
        }
    }

    func resetUnlockedAchievements() {
        unlockedAchievements = []
        unlockedIDs = []
        isLoaded = false
        print("🧹 Cleared unlocked achievements on logout")
    }
}

@MainActor
extension AchievementUnlockManager {
    func attemptUnlockAchievements(
        locationManager: LocationManager,
        capturedLabels: [String]?,
        sessionActive: Bool,
        attributesManager: AttributesManager,
        scenePhase: ScenePhase
    ) {
        guard let userLocation = locationManager.userLocation else { return }
        let location = CLLocation(latitude: userLocation.latitude, longitude: userLocation.longitude)

        for achievement in AchievementLibrary.allAchievements {
            if unlockedIDs.contains(achievement.id) {
                print("✅ Achievement already unlocked previously: \(achievement.title)")
                continue
            }

            if achievement.requiredSessionActive && !sessionActive {
                continue
            }

            print("📍 Checking achievement: \(achievement.title)")

            var poiMatched = false
            var labelMatched = false

            if let requiredPOI = achievement.triggerPOICategory {
                if let matchingPOI = locationManager.filteredPOIs.first(where: {
                    $0.category.lowercased() == requiredPOI.lowercased() &&
                    CLLocation(latitude: $0.coordinate.latitude, longitude: $0.coordinate.longitude)
                        .distance(from: location) <= 150
                }) {
                    poiMatched = true
                    print("✅ Found matching POI: \(requiredPOI)")
                } else {
                    print("🚫 No matching POI found nearby for: \(requiredPOI)")
                }
            }

            if let requiredLabel = achievement.requiredPhotoLabel?.lowercased() {
                if let labels = capturedLabels, labels.contains(where: { $0.lowercased() == requiredLabel }) {
                    labelMatched = true
                } else {
                    print("🚫 Required label '\(requiredLabel)' not found in captured labels")
                }
            }

            if achievement.triggerPOICategory != nil && achievement.requiredPhotoLabel != nil {
                // Both POI and label required
                if poiMatched && labelMatched {
                    print("🏆 Unlocking achievement with both POI and label: \(achievement.title)")
                    unlock(achievement: achievement, attributesManager: attributesManager, scenePhase: scenePhase)
                }
            } else if achievement.triggerPOICategory != nil {
                // Only POI required
                if poiMatched {
                    print("🏆 Unlocking POI-based achievement: \(achievement.title)")
                    unlock(achievement: achievement, attributesManager: attributesManager, scenePhase: scenePhase)
                }
            } else if achievement.requiredPhotoLabel != nil {
                // Only label required
                if labelMatched {
                    print("🏆 Unlocking label-based achievement: \(achievement.title)")
                    unlock(achievement: achievement, attributesManager: attributesManager, scenePhase: scenePhase)
                }
            }
        }
    }
}
