//
//  CameraCaptureView.swift
//  TheRoamingKin
//
//  Created by Lovice Sunuwar on 29/04/2025.
//

import SwiftUI
import AVFoundation

struct CameraCaptureView: View {
    @StateObject private var cameraViewModel = CameraViewModel()

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

            HStack(spacing: 16) {
                // Retry Button - Only show if image is captured
                if cameraViewModel.capturedImage != nil {
                    Button(action: {
                        cameraViewModel.capturedImage = nil
                        cameraViewModel.startCamera()
                    }) {
                        Text("Retry")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(width: 80, height: 50)
                            .background(Color.blue)
                            .cornerRadius(10)
                    }
                }

                // Submit Button
                Button(action: {
                    if cameraViewModel.capturedImage == nil {
                        cameraViewModel.capturePhoto()
                    } else {
                        // Upload logic here
                        print("✅ Image ready to upload.")
                    }
                }) {
                    Text("Submit")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(Color.blue)
                        .cornerRadius(10)
                }
            }
            .padding(.horizontal)
        }
        .padding()
    }
}
