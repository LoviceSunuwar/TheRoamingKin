//
//  HomeView.swift
//  TheRoamingKin
//
//  Created by Lovice Sunuwar on 26/04/2025.
//

import SwiftUI
import MapKit

// MARK: - Bottom Sheet Type
enum BottomSheetType: Identifiable {
    case camera, achievements, profile

    var id: Int { hashValue }
}

// MARK: - Home View
struct HomeView: View {
    @State private var isTracking = false
    @State private var showingSheet: BottomSheetType?
    @StateObject private var locationManager = LocationManager()

    var body: some View {
        ZStack {
            // Fullscreen Map showing User Location
            Map(coordinateRegion: $locationManager.region, showsUserLocation: true)
                .mapControls {
                    MapUserLocationButton()
                }
                .mapStyle(.standard(elevation: .realistic))
                .edgesIgnoringSafeArea(.all)

            VStack {
                Spacer()

                // Bottom Control Card
                BottomControlCard(
                    isTracking: $isTracking,
                    showingSheet: $showingSheet
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
        }
    }

    // Bottom Sheet Content
    @ViewBuilder
    private func sheetView(for type: BottomSheetType) -> some View {
        switch type {
        case .camera:
            CameraView()
        case .achievements:
            AchievementsView()
        case .profile:
            ProfileView()
        }
    }
}

// MARK: - Bottom Control Card
struct BottomControlCard: View {
    @Binding var isTracking: Bool
    @Binding var showingSheet: BottomSheetType?

    var body: some View {
        HStack(spacing: 16) {
            // Start/Stop Button
            Button(action: {
                isTracking.toggle()
            }) {
                Text(isTracking ? "Stop" : "Start")
                    .font(.headline)
                    .foregroundColor(.black)
                    .frame(width: 80, height: 50)
                    .background(isTracking ? Color.red : Color.green)
                    .cornerRadius(8)
            }

            Divider()
                .frame(height: 50)
                .background(.white.opacity(0.8))

            // Camera Button
            SmallControlButton(title: "Camera", systemImage: "camera.fill") {
                showingSheet = .camera
            }

            // Achievements Button
            SmallControlButton(title: "Achievements", systemImage: "star.fill") {
                showingSheet = .achievements
            }

            // Profile Button
            SmallControlButton(title: "Profile", systemImage: "person.crop.circle.fill") {
                showingSheet = .profile
            }
        }
        .padding()
        .background(Color(.sRGB, red: 0/255, green: 0/255, blue: 80/255, opacity: 0.9))
        .cornerRadius(24)
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

// MARK: - Placeholder Bottom Sheet Views
struct CameraView: View {
    var body: some View {
        VStack {
            Text("📷 Supp! Nikki, How is your day so far? 😎")
                .font(.largeTitle.bold())
            Spacer()
        }
        .padding()
    }
}

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

struct ProfileView: View {
    var body: some View {
        VStack {
            Text("👤 Profile View")
                .font(.largeTitle.bold())
            Spacer()
        }
        .padding()
    }
}
