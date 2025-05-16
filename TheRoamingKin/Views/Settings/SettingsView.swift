//
//  SettingsView.swift
//  TheRoamingKin
//
//  Created by Lovice Sunuwar on 15/05/2025.
//

import SwiftUI

struct SettingsView: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {

                // MARK: - Header Image
                Image("SettingTRK")
                    .resizable()
                    .scaledToFill()
                    .frame(height: 180)
                    .clipped()

                // MARK: - Setting Section
                SectionHeader(title: "Setting")

                VStack(spacing: 1) {
                    SettingsRow(icon: "bell", title: "Notification")
                    SettingsRow(icon: "person.crop.circle", title: "Profile")
                    SettingsRow(icon: "globe", title: "Language")
                    SettingsRow(icon: "checkmark.shield", title: "Authorize Management")
                }
                .background(Color(.systemBackground))
                .cornerRadius(12)
                .padding(.horizontal)

                // MARK: - Support & About Section
                SectionHeader(title: "Support & About")

                VStack(spacing: 1) {
                    SettingsRow(icon: "questionmark.circle", title: "FAQ & Feedback")
                    SettingsRow(icon: "hand.thumbsup", title: "Rate & Review")
                    SettingsRow(icon: "gamecontroller", title: "Join us")
                    SettingsRow(icon: "info.circle", title: "About us")
                }
                .background(Color(.systemBackground))
                .cornerRadius(12)
                .padding(.horizontal)

                Spacer(minLength: 24)
            }
        }
        .background(Color(.secondarySystemBackground).ignoresSafeArea())
        .navigationTitle("")
        .navigationBarHidden(true)
    }
}

struct SectionHeader: View {
    let title: String
    var body: some View {
        HStack {
            Text(title)
                .font(.title3.bold())
                .foregroundColor(.primary)
            Spacer()
        }
        .padding(.horizontal)
    }
}

struct SettingsRow: View {
    let icon: String
    let title: String

    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .frame(width: 24)
                .foregroundColor(.primary)
            Text(title)
                .foregroundColor(.primary)
            Spacer()
            Image(systemName: "chevron.right")
                .foregroundColor(.gray)
        }
        .padding()
        .background(Color(.systemBackground))
    }
}

//#Preview {
//    SettingsView()
//}
