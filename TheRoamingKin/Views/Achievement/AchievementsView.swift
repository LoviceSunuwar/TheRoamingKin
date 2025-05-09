//
//  AchievementView.swift
//  TheRoamingKin
//
//  Created by Lovice Sunuwar on 08/05/2025.
//

import SwiftUI

// MARK: - Achievements View

struct AchievementsView: View {
    @StateObject private var achievementManager = AchievementUnlockManager.shared

    let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]

    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 16) {
                ForEach(achievementManager.unlockedAchievements) { achievement in
                    AchievementCard(achievement: achievement)
                }
            }
            .padding()
        }
        .navigationTitle("🏆 Achievements")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Achievement Card

struct AchievementCard: View {
    let achievement: Achievement

    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: achievement.imageName)
                .resizable()
                .scaledToFit()
                .frame(width: 50, height: 50)
                .padding()
                .background(Color.blue.opacity(0.1))
                .clipShape(Circle())

            Text(achievement.title)
                .font(.headline)
                .multilineTextAlignment(.center)

            Text("+\(achievement.points) \(achievement.attributeAffected.rawValue.capitalized)")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color(.secondarySystemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}
