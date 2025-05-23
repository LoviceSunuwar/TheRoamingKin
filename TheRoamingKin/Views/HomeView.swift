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
    case camera
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
                .mapStyle(.standard(elevation: .realistic, pointsOfInterest: .excludingAll))
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
                .environmentObject(locationManager)
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
        .background(Color(.tertiarySystemBackground))
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
    @EnvironmentObject var locationManager: LocationManager

    var body: some View {
        VStack(spacing: 12) {
            HStack(spacing: 8) {
                if !isTracking {
                    SlideToStartButton(isTracking: $isTracking) {
                        sessionManager.startSession()
                        isTracking = true
                    }
                } else {
                    Button(action: {
                        sessionManager.stopSession()
                        isTracking = false
                    }) {
                        Text("⏹ Stop: \(formatTime(sessionManager.remainingTime))")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.red)
                            .cornerRadius(12)
                    }
                }

                Divider().frame(height: 60).background(.white.opacity(0.5))

                HStack(spacing: 8) {
                    SmallControlButton(title: "Camera", systemImage: "camera.fill") {
                        showingSheet = .camera
                    }

                    SmallControlButton(title: "Center", systemImage: "location.fill") {
                        centerMapOnUserLocation()
                    }
                }
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 10)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 0)
                .fill(Color(.sRGB, red: 0, green: 0, blue: 0.4, opacity: 0.9))
        )
    }

    private func centerMapOnUserLocation() {
        guard let userLocation = locationManager.userLocation else { return }
        let span = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        locationManager.region = MKCoordinateRegion(center: userLocation, span: span)
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

// MARK: - Slide to Start Button
struct SlideToStartButton: View {
    @Binding var isTracking: Bool
    var action: () -> Void

    @GestureState private var dragOffset: CGSize = .zero
    @State private var isCompleted = false

    var body: some View {
        ZStack(alignment: .leading) {
            RoundedRectangle(cornerRadius: 30)
                .fill(Color.blue)
                .frame(width: 220, height: 60)

            Text("Slide to Start >>")
                .foregroundColor(.white)
                .frame(width: 220, height: 60, alignment: .center)
                .padding(.horizontal)

            Circle()
                .fill(Color.white)
                .frame(width: 50, height: 50)
                .offset(x: dragOffset.width)
                .gesture(
                    DragGesture()
                        .updating($dragOffset) { value, state, _ in
                            if value.translation.width > 0 && value.translation.width < 170 {
                                state = value.translation
                            }
                        }
                        .onEnded { value in
                            if value.translation.width > 150 {
                                isCompleted = true
                                AudioPlayer.shared.playSound(named: "TRKStart") // ✅ play sound
                                action()
                            }
                        }
                )
                .animation(.easeOut, value: dragOffset)
        }
    }
}
