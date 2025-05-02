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

    @ViewBuilder
    private func sheetView(for type: BottomSheetType) -> some View {
        switch type {
        case .camera:
            CameraCaptureView()
        case .achievements:
            AchievementsView()
        case .profile:
            ProfileView()
        }
    }
}


struct BottomControlCard: View {
    @Binding var isTracking: Bool
    @Binding var showingSheet: BottomSheetType?

    var body: some View {
        HStack(spacing: 16) {
            Button(action: { isTracking.toggle() }) {
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
        .padding()
        .background(Color(.sRGB, red: 0, green: 0, blue: 80/255, opacity: 0.9))
        .cornerRadius(24)
    }
}

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
