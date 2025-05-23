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

    @StateObject private var locationManager: LocationManager
    @StateObject private var sessionManager: SessionManager

    @StateObject private var attributesManager = AttributesManager()
    @ObservedObject private var proximityMonitor = ProximityMonitor()
    @StateObject private var achievementUnlockManager = AchievementUnlockManager.shared
    @Environment(\.scenePhase) private var scenePhase
    @EnvironmentObject private var loginViewModel: LoginViewModel
    @StateObject private var speedMonitor = SpeedMonitor()

    // MARK: - Injected initializer
    init() {
        let sharedLocationManager = LocationManager()
        _locationManager = StateObject(wrappedValue: sharedLocationManager)
        _sessionManager = StateObject(wrappedValue: SessionManager(locationManagerUpdateCity: sharedLocationManager))
    }

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
                        if let imageName = poi.imageName {
                            VStack(spacing: 2) {
                                Image(imageName)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: locationManager.annotationSize * 2,
                                           height: locationManager.annotationSize * 2)

                                Text(poi.category.capitalized)
                                    .font(.caption2)
                                    .multilineTextAlignment(.center)
                            }
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

                HStack {
                    Spacer()
                    Button(action: centerMapOnUserLocation) {
                        Image(systemName: "location.fill")
                            .foregroundColor(.white)
                            .padding(16)
                            .background(Color.blue)
                            .clipShape(Circle())
                            .shadow(radius: 4)
                    }
                    .padding(.trailing, 20)
                    .padding(.bottom, 160)
                }

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
                scenePhase: scenePhase,
                sessionActive: sessionManager.sessionActive
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

    // MARK: - Center Map Helper
    private func centerMapOnUserLocation() {
        guard let userLocation = locationManager.userLocation else { return }
        let span = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        locationManager.region = MKCoordinateRegion(center: userLocation, span: span)
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
            NavigationStack {
                SettingsView()
                    .environmentObject(loginViewModel)
            }
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
