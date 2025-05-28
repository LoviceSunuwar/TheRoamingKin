//
//  MainTabView.swift
//  TheRoamingKin
//
//  Created by Lovice Sunuwar on 22/05/2025.
//

import SwiftUI

struct MainTabView: View {
    @StateObject private var loginViewModel = LoginViewModel()

    // MARK: - Fix translucent tab bar
    init() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor.systemBackground // or any solid color

        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }

    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Label("Explore", systemImage: "map.fill")
                }

            NavigationStack {
                AchievementsView()
            }
            .tabItem {
                Label("Achievement", systemImage: "star.fill")
            }

            NavigationStack {
                SettingsView()
                    .environmentObject(loginViewModel)
            }
            .tabItem {
                Label("More", systemImage: "person.crop.circle")
            }
        }
    }
}
