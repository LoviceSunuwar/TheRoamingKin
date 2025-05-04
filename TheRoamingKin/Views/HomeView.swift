//
//  HomeView.swift
//  TheRoamingKin
//
//  Created by Lovice Sunuwar on 26/04/2025.
//

import SwiftUI
import MapKit
import AVFoundation

enum BottomSheetType: Identifiable {
    case camera, achievements, profile
    var id: Int { hashValue }
}

struct HomeView: View {
    @State private var isTracking = false
    @State private var showingSheet: BottomSheetType?
    @StateObject private var locationManager = LocationManager()
    @StateObject private var sessionManager = SessionManager()
    @StateObject private var attributesManager = AttributesManager()
    @ObservedObject private var proximityMonitor = ProximityMonitor()
    @StateObject private var achievementUnlockManager = AchievementUnlockManager.shared
    @Environment(\.scenePhase) private var scenePhase
    @EnvironmentObject private var loginViewModel: LoginViewModel
    @StateObject private var speedMonitor = SpeedMonitor()

    var body: some View {
        ZStack {
            if let region = locationManager.region {
                Map(
                    coordinateRegion: Binding(
                        get: { region },
                        set: { newRegion in
                            locationManager.region = newRegion
                            locationManager.zoomLevel = newRegion.span.latitudeDelta
                        }
                    ),
                    interactionModes: [.all],
                    showsUserLocation: true,
                    annotationItems: locationManager.filteredPOIs
                ) { poi in
                    MapAnnotation(coordinate: poi.coordinate) {
                        VStack(spacing: 2) {
                            Image(systemName: poi.symbol)
                                .font(.system(size: locationManager.annotationSize))
                                .foregroundColor(.blue)
                            Text(poi.category.capitalized)
                                .font(.caption2)
                                .multilineTextAlignment(.center)
                        }
                    }
                }
                .edgesIgnoringSafeArea(.all)
                .mapStyle(.standard(pointsOfInterest: .excludingAll))
            } else {
                ProgressView("Fetching your location...")
            }

            VStack {
                Spacer()
                BottomControlCard(
                    isTracking: $isTracking,
                    showingSheet: $showingSheet,
                    sessionManager: sessionManager
                )
                .padding()
            }
        }
        .sheet(item: $showingSheet) { type in
            sheetView(for: type)
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
        }
        .onAppear {
            locationManager.requestPermission()
            if loginViewModel.shouldShowWelcomeToast {
                AchievementUnlockManager.shared.toastMessage = "🎖️ Guild Registration Unlocked!"
                withAnimation {
                    achievementUnlockManager.showToast = true
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                    withAnimation {
                        achievementUnlockManager.showToast = false
                    }
                    loginViewModel.shouldShowWelcomeToast = false
                }
            }
        }
        .onChange(of: locationManager.userLocation) { _, newLocation in
            guard let location = newLocation else { return }
            proximityMonitor.checkProximity(
                to: locationManager.filteredPOIs,
                userLocation: location,
                attributesManager: attributesManager,
                scenePhase: scenePhase
            )
        }
        .onReceive(locationManager.$currentSpeed) { speed in
            speedMonitor.checkSpeed(
                speedMetersPerSecond: speed,
                attributesManager: attributesManager,
                scenePhase: scenePhase
            )
        }
        .overlay(
            toastView()
                .opacity(achievementUnlockManager.showToast ? 1 : 0)
                .animation(.easeInOut, value: achievementUnlockManager.showToast)
                .padding(.top, 50),
            alignment: .top
        )
    }

    @ViewBuilder
    private func sheetView(for type: BottomSheetType) -> some View {
        switch type {
        case .camera:
            CameraCaptureView(
                cameraViewModel: CameraViewModel(
                    locationManager: locationManager,
                    attributesManager: attributesManager,
                    isSessionActive: sessionManager.sessionActive,
                    isCameraPresented: Binding(
                        get: { showingSheet != nil },
                        set: { isPresented in
                            if !isPresented {
                                showingSheet = nil
                            }
                        }
                    )
                )
            )
        case .achievements:
            AchievementsView()
        case .profile:
            ProfileView()
                .environmentObject(loginViewModel)
        }
    }

    private func toastView() -> some View {
        HStack(spacing: 12) {
            Image(systemName: "star.fill")
                .foregroundColor(.white)
                .font(.title2)

            Text(achievementUnlockManager.toastMessage)
                .foregroundColor(.white)
                .font(.headline)
                .multilineTextAlignment(.center)
        }
        .padding()
        .background(Color.blue.opacity(0.9))
        .cornerRadius(12)
        .padding(.horizontal)
    }
}

// MARK: - Bottom Control Panel
struct BottomControlCard: View {
    @Binding var isTracking: Bool
    @Binding var showingSheet: BottomSheetType?
    @ObservedObject var sessionManager: SessionManager

    var body: some View {
        VStack(spacing: 8) {
            HStack(spacing: 16) {
                Button(action: {
                    if sessionManager.sessionActive {
                        sessionManager.stopSession()
                    } else {
                        sessionManager.startSession()
                    }
                    isTracking.toggle()
                }) {
                    Text(isTracking ? "Stop" : "Start")
                        .font(.headline)
                        .foregroundColor(.black)
                        .frame(width: 80, height: 50)
                        .background(isTracking ? Color.red : Color.green)
                        .cornerRadius(8)
                }

                Divider().frame(height: 50).background(.white.opacity(0.8))

                SmallControlButton(title: "Camera", systemImage: "camera.fill") {
                    showingSheet = .camera
                }

                SmallControlButton(title: "Achievements", systemImage: "star.fill") {
                    showingSheet = .achievements
                }

                SmallControlButton(title: "Profile", systemImage: "person.crop.circle.fill") {
                    showingSheet = .profile
                }
            }

            if sessionManager.sessionActive {
                Text("⏳ Time Left: \(formatTime(sessionManager.remainingTime))")
                    .font(.caption2)
                    .foregroundColor(.white)
            }
        }
        .padding()
        .background(Color(.sRGB, red: 0, green: 0, blue: 80/255, opacity: 0.9))
        .cornerRadius(24)
    }

    private func formatTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%02dm %02ds", minutes, seconds)
    }
}

// MARK: - Small Control Button
struct SmallControlButton: View {
    var title: String
    var systemImage: String
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: systemImage)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 24, height: 24)

                Text(title)
                    .font(.caption2)
                    .multilineTextAlignment(.center)
            }
            .padding()
            .frame(width: 70, height: 70)
            .background(Color.green)
            .cornerRadius(12)
            .foregroundColor(.black)
        }
    }
}

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


// MARK: - Profile View
struct ProfileView: View {
    @EnvironmentObject var loginViewModel: LoginViewModel

    var body: some View {
        VStack(spacing: 24) {
            Text("👤 Profile View")
                .font(.largeTitle.bold())

            Button(action: {
                loginViewModel.logout()
            }) {
                Text("Logout")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(width: 200, height: 50)
                    .background(Color.red)
                    .cornerRadius(12)
            }

            Spacer()
        }
        .padding()
    }
}
