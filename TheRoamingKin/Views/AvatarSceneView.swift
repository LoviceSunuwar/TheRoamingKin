//
//  AvatarSceneView.swift
//  TheRoamingKin
//
//  Created by Lovice Sunuwar on 27/05/2025.
//

import SwiftUI
import SceneKit
import GLTFKit2

struct AvatarSceneView: UIViewRepresentable {
    let avatarName: String
    let isInteractive: Bool

    func makeUIView(context: Context) -> SCNView {
        let scnView = SCNView()
        scnView.backgroundColor = .clear
        scnView.allowsCameraControl = isInteractive 
        scnView.autoenablesDefaultLighting = true
        scnView.scene = SCNScene()

        loadModel(into: scnView)

        return scnView
    }

    func updateUIView(_ uiView: SCNView, context: Context) {}

    private func loadModel(into scnView: SCNView) {
        guard let url = Bundle.main.url(forResource: avatarName, withExtension: "glb") else {
            print("❌ Could not find model: \(avatarName).glb")
            return
        }

        GLTFAsset.load(with: url, options: [:]) { progress, status, asset, error, _ in
            if status == .complete, let asset = asset {
                let source = GLTFSCNSceneSource(asset: asset)
                if let scene = source.defaultScene {
                    DispatchQueue.main.async {
                        let rootScene = SCNScene()
                        let clonedNode = scene.rootNode.clone()
                        rootScene.rootNode.addChildNode(clonedNode)

                        let cameraNode = SCNNode()
                        cameraNode.camera = SCNCamera()
                        cameraNode.position = SCNVector3(x: 0, y: 0, z: 5)
                        rootScene.rootNode.addChildNode(cameraNode)

                        scnView.scene = rootScene
                    }
                }
            } else if let error = error {
                print("❌ Failed to load: \(error)")
            }
        }
    }
}
