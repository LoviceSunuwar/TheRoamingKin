//
//  TheRoamingKinApp.swift
//  TheRoamingKin
//
//  Created by Lovice Sunuwar on 26/04/2025.
//

import SwiftUI
import FirebaseCore
import UserNotifications

// MARK: - AppDelegate for Firebase
class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions:
                     [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        FirebaseApp.configure()
        return true
    }
}

@main
struct TheRoamingKinApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @StateObject private var viewModel = LoginViewModel()
    @Environment(\.scenePhase) private var scenePhase

    var body: some Scene {
        WindowGroup {
            ContentView(viewModel: viewModel)
                .onAppear {
                    viewModel.checkSessionValidityOnLaunch()
                }
        }
        .onChange(of: scenePhase) { _, newPhase in
            if newPhase == .background || newPhase == .inactive {
                // Handle cleanup if app was closed or backgrounded
                UNUserNotificationCenter.current()
                    .removePendingNotificationRequests(withIdentifiers: ["session_end_warning"])
                print("🧹 Removed 'session_end_warning' notification due to app state change.")
            }
        }
    }
}
