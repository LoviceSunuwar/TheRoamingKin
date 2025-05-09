//
//  SessionManager.swift
//  TheRoamingKin
//
//  Created by Lovice Sunuwar on 02/05/2025.
//

import Foundation
import UserNotifications
import CoreLocation
import HealthKit
import SwiftUI

@MainActor
class SessionManager: NSObject, ObservableObject, @preconcurrency CLLocationManagerDelegate {
    @Published var sessionActive = false
    @Published var sessionStartTime: Date?
    @Published var sessionEndTime: Date?
    @Published var remainingTime: TimeInterval = 0

    private var locationManager: CLLocationManager?
    private var healthManager = HealthManager()
    private var sessionTimer: Timer?
    private var healthTimer: Timer?

    private var stepsAtStart: Double = 0
    private var caloriesAtStart: Double = 0
    private var distanceAtStart: Double = 0

    override init() {
        super.init()
        requestNotificationPermission()
    }

    func startSession() {
        Task {
            // ✅ First wait until achievements are fully loaded
            while AchievementUnlockManager.shared.isLoaded == false {
                print("⏳ Waiting for achievements to load...")
                try? await Task.sleep(nanoseconds: 200_000_000) // 0.2 seconds
            }

            print("✅ Achievements loaded. Starting session!")

            sessionActive = true
            sessionStartTime = Date()
            sessionEndTime = Calendar.current.date(byAdding: .hour, value: 2, to: sessionStartTime!)
            remainingTime = sessionEndTime!.timeIntervalSinceNow

            startTrackingLocation()
            startTimer()
            scheduleStartNotification()
            scheduleEndNotification()

            await healthManager.requestAuthorization()
            await fetchHealthDataAtStart()
            startHealthTracking()
        }
    }

    func stopSession() {
        sessionActive = false
        sessionTimer?.invalidate()
        sessionTimer = nil
        healthTimer?.invalidate()
        healthTimer = nil
        locationManager?.stopUpdatingLocation()
        removePendingNotifications()
    }

    private func startTimer() {
        sessionTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            Task { @MainActor in
                guard let end = self.sessionEndTime else { return }
                self.remainingTime = end.timeIntervalSinceNow

                if self.remainingTime <= 0 {
                    self.stopSession()
                }
            }
        }
    }

    private func startHealthTracking() {
        healthTimer = Timer.scheduledTimer(withTimeInterval: 30.0, repeats: true) { _ in
            Task { @MainActor in
                await self.checkHealthAchievements()
            }
        }
    }

    private func startTrackingLocation() {
        locationManager = CLLocationManager()
        locationManager?.delegate = self
        locationManager?.desiredAccuracy = kCLLocationAccuracyHundredMeters
        locationManager?.requestWhenInUseAuthorization()
        locationManager?.startUpdatingLocation()
    }

    private func fetchHealthDataAtStart() async {
        stepsAtStart = await healthManager.fetchTodayStepCount()
        caloriesAtStart = await healthManager.fetchTodayActiveCalories()
        distanceAtStart = await healthManager.fetchTodayWalkingDistance()

        print("👣 Steps at session start: \(Int(stepsAtStart)) steps")
        print("🔥 Calories burned at session start: \(Int(caloriesAtStart)) kcal")
        print("🚶‍♂️ Distance walked at session start: \(String(format: "%.2f", distanceAtStart/1000)) km")
    }

    private func checkHealthAchievements() async {
        let currentSteps = await healthManager.fetchTodayStepCount()
        let currentCalories = await healthManager.fetchTodayActiveCalories()
        let currentDistance = await healthManager.fetchTodayWalkingDistance()

        let stepsGained = currentSteps - stepsAtStart
        let caloriesGained = currentCalories - caloriesAtStart
        let distanceGained = currentDistance - distanceAtStart

        print("📈 Session Progress - Steps: \(Int(stepsGained)), Calories: \(Int(caloriesGained)), Distance: \(String(format: "%.2f", distanceGained/1000)) km")

        for achievement in AchievementLibrary.allAchievements {
            guard achievement.requiredSessionActive else { continue }
            guard let requiredValue = achievement.requiredHealthValue else { continue }

            switch achievement.healthMetricType {
            case .steps:
                if stepsGained >= requiredValue {
                    unlockHealthAchievement(title: achievement.title)
                }
            case .distance:
                if distanceGained >= requiredValue {
                    unlockHealthAchievement(title: achievement.title)
                }
            case .calories:
                if caloriesGained >= requiredValue {
                    unlockHealthAchievement(title: achievement.title)
                }
            case .none:
                continue
            }
        }
    }

    private func unlockHealthAchievement(title: String) {
        if let achievement = AchievementLibrary.allAchievements.first(where: { $0.title == title }) {
            AchievementUnlockManager.shared.unlock(
                achievement: achievement,
                attributesManager: AttributesManager.shared,
                scenePhase: UIApplication.shared.connectedScenes.first?.activationState == .foregroundActive ? .active : .background
            )
        }
    }

    private func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { success, error in
            if success {
                print("✅ Notification permission granted")
            } else {
                print("❌ Notification permission denied: \(error?.localizedDescription ?? "Unknown error")")
            }
        }
    }

    private func scheduleStartNotification() {
        let content = UNMutableNotificationContent()
        content.title = "Session Started"
        content.body = "Your exploration session has begun. Enjoy your adventure!"
        content.sound = .default

        let request = UNNotificationRequest(
            identifier: "session_start",
            content: content,
            trigger: nil
        )

        UNUserNotificationCenter.current().add(request)
    }

    private func scheduleEndNotification() {
        guard let end = sessionEndTime else { return }
        let fiveMinutesBeforeEnd = end.addingTimeInterval(-5 * 60)
        let timeInterval = max(fiveMinutesBeforeEnd.timeIntervalSinceNow, 1)

        let content = UNMutableNotificationContent()
        content.title = "Session Ending Soon"
        content.body = "Your session will end in 5 minutes!"
        content.sound = .default

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: timeInterval, repeats: false)

        let request = UNNotificationRequest(
            identifier: "session_end_warning",
            content: content,
            trigger: trigger
        )

        UNUserNotificationCenter.current().add(request)
    }

    private func removePendingNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }

    // CLLocationManagerDelegate (future use)
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        Task { @MainActor in
            // You can add tracking logic here if needed later
        }
    }
}
