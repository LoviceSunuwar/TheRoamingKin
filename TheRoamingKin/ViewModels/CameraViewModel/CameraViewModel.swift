//
//  CameraViewModel.swift
//  TheRoamingKin
//
//  Created by Lovice Sunuwar on 29/04/2025.
//

import Foundation
import AVFoundation
import UIKit

@MainActor
class CameraViewModel: NSObject, ObservableObject {
    @Published var capturedImage: UIImage?
    let session = AVCaptureSession()
    private let output = AVCapturePhotoOutput()
    private let queue = DispatchQueue(label: "camera.queue")

    func startCamera() {
        AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
            guard granted else { return }
            self?.configure()
            self?.queue.async {
                self?.session.startRunning()
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
}

extension CameraViewModel: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput,
                     didFinishProcessingPhoto photo: AVCapturePhoto,
                     error: Error?) {
        if let data = photo.fileDataRepresentation(),
           let image = UIImage(data: data) {
            self.capturedImage = image
        }
    }
}
