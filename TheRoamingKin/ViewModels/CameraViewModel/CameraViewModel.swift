import Foundation
import AVFoundation
import UIKit
import Vision
import CoreLocation
import SwiftUI

@MainActor
class CameraViewModel: NSObject, ObservableObject {
    @Published var capturedImage: UIImage?
    @Published var errorMessage: String?
    @Published var didUnlockAchievement: Bool = false

    let session = AVCaptureSession()
    private let output = AVCapturePhotoOutput()
    private let queue = DispatchQueue(label: "camera.queue")

    private let locationManager: LocationManager
    private let attributesManager: AttributesManager
    private let isSessionActive: Bool
    @Binding var isCameraPresented: Bool

    init(locationManager: LocationManager, attributesManager: AttributesManager, isSessionActive: Bool, isCameraPresented: Binding<Bool>) {
        self.locationManager = locationManager
        self.attributesManager = attributesManager
        self.isSessionActive = isSessionActive
        self._isCameraPresented = isCameraPresented
        super.init()
    }

    func startCamera() {
        AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
            guard let self else { return }
            guard granted else { return }
            self.configure()
            self.queue.async {
                Task { @MainActor in
                    self.session.startRunning()
                }
            }
        }
    }

    func stopCamera() {
        session.stopRunning()
    }

    private func configure() {
        session.beginConfiguration()

        guard let device = AVCaptureDevice.default(for: .video),
              let input = try? AVCaptureDeviceInput(device: device) else {
            return
        }

        if session.inputs.isEmpty {
            session.addInput(input)
        }

        if session.outputs.isEmpty {
            session.addOutput(output)
        }

        session.commitConfiguration()
    }

    func capturePhoto() {
        let settings = AVCapturePhotoSettings()
        output.capturePhoto(with: settings, delegate: self)
    }

    private func classifyCapturedImage(_ image: UIImage) {
        guard let cgImage = image.cgImage else { return }

        let request = VNClassifyImageRequest { [weak self] request, error in
            guard let self else { return }
            guard error == nil else {
                self.handleFailure(message: "❌ Could not process image.")
                return
            }

            if let results = request.results as? [VNClassificationObservation] {
                let labels = results.map { $0.identifier.lowercased() }
                print("🖼️ Captured labels: \(labels)")

                AchievementUnlockManager.shared.attemptUnlockAchievements(
                    locationManager: self.locationManager,
                    capturedLabel: labels.first,
                    sessionActive: self.isSessionActive,
                    attributesManager: self.attributesManager,
                    scenePhase: .active
                )

                DispatchQueue.main.async {  // ✅ Always update Published inside main thread
                    if AchievementUnlockManager.shared.showToast {
                        self.didUnlockAchievement = true
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                            self.isCameraPresented = false
                        }
                    } else {
                        self.handleFailure(message: "❌ Nothing recognizable. Try again!")
                    }
                }
            } else {
                self.handleFailure(message: "❌ Could not recognize anything.")
            }
        }

        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        try? handler.perform([request])
    }

    private func handleFailure(message: String) {
        DispatchQueue.main.async { // ✅ Must ensure this
            self.errorMessage = message
            self.capturedImage = nil
            self.isCameraPresented = false
        }
    }
}

// MARK: - AVCapturePhotoCaptureDelegate
extension CameraViewModel: @preconcurrency AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput,
                     didFinishProcessingPhoto photo: AVCapturePhoto,
                     error: Error?) {
        if let data = photo.fileDataRepresentation(),
           let image = UIImage(data: data) {
            DispatchQueue.main.async {  // ✅ fix
                self.capturedImage = image
                self.classifyCapturedImage(image)
            }
        }
    }
}
