//
//  SettingsView.swift
//  TheRoamingKin
//
//  Created by Lovice Sunuwar on 15/05/2025.
//

import SwiftUI
import CoreLocation
import HealthKit
import AVFoundation

struct SettingsView: View {
    @EnvironmentObject var loginViewModel: LoginViewModel
    @State private var showingAuthorizationSheet = false

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
                    NavigationLink(destination: ProfileEditView(loginViewModel: loginViewModel)) {
                        SettingsRow(icon: "person.crop.circle", title: "Profile")
                    }
                    SettingsRow(icon: "globe", title: "Language")

                    Button(action: {
                        showingAuthorizationSheet = true
                    }) {
                        SettingsRow(icon: "checkmark.shield", title: "Authorize Management")
                    }
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
        .sheet(isPresented: $showingAuthorizationSheet) {
            AuthorizationSettingsView()
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
        }
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

struct AuthorizationSettingsView: View {
    @State private var locationEnabled: Bool = {
        let manager = CLLocationManager()
        let status = manager.authorizationStatus
        return status == .authorizedWhenInUse || status == .authorizedAlways
    }()

    @State private var healthEnabled = HKHealthStore.isHealthDataAvailable()
    @State private var cameraEnabled = AVCaptureDevice.authorizationStatus(for: .video) == .authorized

    var body: some View {
        VStack(spacing: 24) {
            Text("Manage Permissions")
                .font(.title2.bold())
                .padding(.top)

            Toggle("📍 Location Access", isOn: Binding(
                get: { locationEnabled },
                set: { _ in openSettingsApp() }
            ))
            .disabled(true)

            Toggle("❤️ Health Access", isOn: Binding(
                get: { healthEnabled },
                set: { _ in openSettingsApp() }
            ))
            .disabled(true)

            Toggle("📷 Camera Access", isOn: Binding(
                get: { cameraEnabled },
                set: { _ in openSettingsApp() }
            ))
            .disabled(true)

            Button(action: {
                openSettingsApp()
            }) {
                Label("Open Settings", systemImage: "gear")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(12)
            }
            .padding(.top)

            Spacer()
        }
        .padding()
    }

    private func openSettingsApp() {
        if let url = URL(string: UIApplication.openSettingsURLString),
           UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        }
    }
}
