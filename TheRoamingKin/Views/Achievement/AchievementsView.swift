//
//  AchievementView.swift
//  TheRoamingKin
//
//  Created by Lovice Sunuwar on 08/05/2025.
//

import SwiftUI

struct AchievementsView: View {
    @StateObject private var attributeManager = AttributesManager.shared
    @StateObject private var achievementManager = AchievementUnlockManager.shared

    private let userAvatarName = "person.crop.circle.fill" // Replace with your SVG rendering if needed

    private let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]

    var totalXP: Int {
        attributeManager.strength * 7 +
        attributeManager.dexterity * 6 +
        attributeManager.constitution * 6 +
        attributeManager.intelligence * 8 +
        attributeManager.wisdom * 7
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {

                // MARK: - Top Avatar + Stats View
                HStack(alignment: .top, spacing: 16) {
                    Image(systemName: userAvatarName)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 120, height: 120)
                        .foregroundColor(.green)
                        .padding(.leading)

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Strength: \(attributeManager.strength)")
                        Text("Dexterity: \(attributeManager.dexterity)")
                        Text("Wisdom: \(attributeManager.wisdom)")
                        Text("Intelligence: \(attributeManager.intelligence)")
                        Text("Constitution: \(attributeManager.constitution)")
                    }
                    .font(.subheadline)
                    .padding(.top, 8)
                }
                .padding(.horizontal)

                // MARK: - XP and Badges Summary
                HStack {
                    VStack {
                        Image(systemName: "shield.fill")
                        Text("\(achievementManager.unlockedAchievements.count)")
                            .font(.title3).bold()
                        Text("Badges")
                            .font(.caption)
                    }
                    Spacer()
                    VStack {
                        Image(systemName: "star.fill")
                        Text("\(totalXP)")
                            .font(.title3).bold()
                        Text("XP")
                            .font(.caption)
                    }
                }
                .padding(.horizontal, 40)
                .padding(.top, 8)

                Divider()

                // MARK: - Achievements Grid
                Text("Badges")
                    .font(.headline)
                    .padding(.top)

                LazyVGrid(columns: columns, spacing: 24) {
                    ForEach(achievementManager.unlockedAchievements) { achievement in
                        VStack(spacing: 8) {
                            Image(systemName: achievement.imageName)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 50, height: 50)
                                .foregroundColor(.yellow)

                            Text(achievement.title)
                                .font(.caption)
                                .multilineTextAlignment(.center)
                        }
                    }
                }
                .padding()
            }
        }
        .navigationTitle("Achievements")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            Task {
                await attributeManager.loadAttributes()
            }
        }
    }
}
