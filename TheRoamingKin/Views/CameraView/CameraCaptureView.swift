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
