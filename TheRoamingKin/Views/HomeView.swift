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
    @State private var showToast = false //
    @StateObject private var locationManager = LocationManager()
    @StateObject private var sessionManager = SessionManager()
    @EnvironmentObject private var loginViewModel: LoginViewModel

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
                .mapStyle(.imagery)
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
                showToastMessage()
            }
        }
        .onChange(of: loginViewModel.shouldShowWelcomeToast) { _, newValue in
            if newValue {
                showToastMessage()
            }
        }

        .overlay(
            toastView()
                .opacity(showToast ? 1 : 0)
                .animation(.easeInOut, value: showToast)
                .padding(.top, 50),
            alignment: .top
        )
    }

    @ViewBuilder
    private func sheetView(for type: BottomSheetType) -> some View {
        switch type {
        case .camera:
            CameraCaptureView()
        case .achievements:
            AchievementsView()
        case .profile:
            ProfileView()
                .environmentObject(loginViewModel)
        }
    }

    // MARK: - Toast
    private func toastView() -> some View {
        HStack(spacing: 12) {
            Image(systemName: "star.fill")
                .foregroundColor(.white)
                .font(.title2)

            Text("🎖️ Guild Registration Unlocked!")
                .foregroundColor(.white)
                .font(.headline)
                .multilineTextAlignment(.center)
        }
        .padding()
        .background(Color.blue.opacity(0.9))
        .cornerRadius(12)
        .padding(.horizontal)
    }

    private func showToastMessage() {
        withAnimation {
            showToast = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) { // show for 5 seconds
            withAnimation {
                showToast = false
                loginViewModel.shouldShowWelcomeToast = false
            }
        }
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
    var body: some View {
        VStack {
            Text("🏆 Achievements View")
                .font(.largeTitle.bold())
            Spacer()
        }
        .padding()
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
