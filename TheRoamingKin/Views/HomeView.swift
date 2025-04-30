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
            if let lockRegion = locationManager.lockedRegion {
                Map(position: $locationManager.cameraPosition) {
                    UserAnnotation()

                    if let polygon = locationManager.cityBoundaryPolygon {
                            MapPolygon(polygon)
                                .stroke(.red, lineWidth: 2)
                                .foregroundStyle(.clear) 
                        }
                }
                .mapStyle(.standard(elevation: .realistic))
                .edgesIgnoringSafeArea(.all)
                .onMapCameraChange { context in
                    let center = context.camera.centerCoordinate
                    if isOutside(region: lockRegion, coordinate: center) {
                        if let user = locationManager.currentLocation {
                            locationManager.cameraPosition = .camera(
                                MapCamera(centerCoordinate: user, distance: 500)
                            )
                        } else {
                            locationManager.cameraPosition = .region(lockRegion)
                        }
                    }
                }
            } else {
                ProgressView("Loading map...")
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

    private func isOutside(region: MKCoordinateRegion, coordinate: CLLocationCoordinate2D) -> Bool {
        let lat = coordinate.latitude
        let lon = coordinate.longitude

        let minLat = region.center.latitude - region.span.latitudeDelta / 2
        let maxLat = region.center.latitude + region.span.latitudeDelta / 2
        let minLon = region.center.longitude - region.span.longitudeDelta / 2
        let maxLon = region.center.longitude + region.span.longitudeDelta / 2

        return lat < minLat || lat > maxLat || lon < minLon || lon > maxLon
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
