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

@MainActor
class SessionManager: NSObject, ObservableObject, @preconcurrency CLLocationManagerDelegate {
    @Published var sessionActive = false
    @Published var sessionStartTime: Date?
    @Published var sessionEndTime: Date?
    @Published var remainingTime: TimeInterval = 0

    private var locationManager: CLLocationManager?
    private var healthManager = HealthManager()
    private var sessionTimer: Timer?

    override init() {
        super.init()
        requestNotificationPermission()
    }

    func startSession() {
        sessionActive = true
        sessionStartTime = Date()
        sessionEndTime = Calendar.current.date(byAdding: .hour, value: 2, to: sessionStartTime!)
        remainingTime = sessionEndTime!.timeIntervalSinceNow

        startTrackingLocation()
        startTimer()
        scheduleStartNotification()
        scheduleEndNotification()

        Task {
            await healthManager.requestAuthorization()
            await fetchHealthDataAtStart()
        }
    }

    func stopSession() {
        sessionActive = false
        sessionTimer?.invalidate()
        sessionTimer = nil
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


    private func startTrackingLocation() {
        locationManager = CLLocationManager()
        locationManager?.delegate = self
        locationManager?.desiredAccuracy = kCLLocationAccuracyHundredMeters
        locationManager?.requestWhenInUseAuthorization()
        locationManager?.startUpdatingLocation()
    }

    private func fetchHealthDataAtStart() async {
        let steps = await healthManager.fetchTodayStepCount()
        let calories = await healthManager.fetchTodayActiveCalories()
        let distance = await healthManager.fetchTodayWalkingDistance()

        print("👣 Steps at session start: \(Int(steps)) steps")
        print("🔥 Calories burned at session start: \(Int(calories)) kcal")
        print("🚶‍♂️ Distance walked at session start: \(String(format: "%.2f", distance/1000)) km")
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

    // CLLocationManagerDelegate (if needed for future)
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        Task { @MainActor in
            // You can track user's movement here if needed later
        }
    }

}
