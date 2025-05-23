//
//  AudioPlayer.swift
//  TheRoamingKin
//
//  Created by Lovice Sunuwar on 22/05/2025.
//

import AVFoundation

class AudioPlayer {
    static var shared = AudioPlayer()
    private var player: AVAudioPlayer?

    func playSound(named name: String, fileExtension: String = "mp3") {
        guard let url = Bundle.main.url(forResource: name, withExtension: fileExtension) else {
            print("❌ Audio file \(name).\(fileExtension) not found.")
            return
        }

        do {
            player = try AVAudioPlayer(contentsOf: url)
            player?.prepareToPlay()
            player?.play()
        } catch {
            print("❌ Failed to play sound: \(error.localizedDescription)")
        }
    }
}
