//
//  CameraCaptureView.swift
//  TheRoamingKin
//
//  Created by Lovice Sunuwar on 29/04/2025.
//

import SwiftUI
import AVFoundation

struct CameraCaptureView: View {
    @StateObject var cameraViewModel: CameraViewModel
    @State private var showInstructions = false

    var body: some View {
        VStack(spacing: 24) {
            Text("Show your haul")
                .font(.headline)
                .padding(.top)

            ZStack {
                Rectangle()
                    .fill(Color.gray.opacity(0.2))
                    .aspectRatio(1, contentMode: .fit)
                    .overlay(
                        Group {
                            if let image = cameraViewModel.capturedImage {
                                Image(uiImage: image)
                                    .resizable()
                                    .scaledToFill()
                                    .clipped()
                            } else {
                                CameraPreview(session: cameraViewModel.session)
                                    .onAppear {
                                        cameraViewModel.startCamera()
                                    }
                                    .onDisappear {
                                        cameraViewModel.stopCamera()
                                    }
                            }
                        }
                    )
            }
            .cornerRadius(12)
            .padding(.horizontal)

            Button(action: {
                if cameraViewModel.capturedImage == nil {
                    cameraViewModel.capturePhoto()
                }
            }) {
                Text("Capture")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(Color.blue)
                    .cornerRadius(10)
            }
            .padding(.horizontal)

            // MARK: - Expandable Instruction with Tertiary Background
            VStack(spacing: 0) {
                Button(action: {
                    withAnimation {
                        showInstructions.toggle()
                    }
                }) {
                    HStack {
                        Image(systemName: "info.circle.fill")
                            .foregroundColor(.blue)
                        Text("How to Complete This Task")
                            .font(.headline)
                        Spacer()
                        Image(systemName: showInstructions ? "chevron.up" : "chevron.down")
                            .foregroundColor(.gray)
                    }
                    .padding()
                    .background(Color(UIColor.tertiarySystemBackground))
                }

                if showInstructions {
                    VStack(alignment: .leading, spacing: 8) {
                        Divider()
                        Text("""
📍 Be at the location shown on your map.
📸 Take a clear photo of your activity (like a fish, a gym sign, or hiking trail marker).
🌐 Your location is used to verify you're nearby.
💡 Make sure the object is well-lit and centered in frame.
""")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .padding()
                    }
                    .background(Color(UIColor.tertiarySystemBackground))
                    .transition(.opacity.combined(with: .move(edge: .top)))
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.gray.opacity(0.2), lineWidth: 1)
            )
            .padding(.horizontal)
        }
        .padding()
        .onChange(of: cameraViewModel.didUnlockAchievement) { _, didUnlock in
            if didUnlock {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    cameraViewModel.isCameraPresented = false
                }
            }
        }
    }
}
