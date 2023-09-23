//
//  AudioManager.swift
//  it
//
//  Created by hashimo ryoya on 2023/09/23.
//

import SwiftUI
import AVFoundation

class AudioManager: ObservableObject {
    static let shared = AudioManager()
    var audioPlayer: AVPlayer?

    @Published var isMuted: Bool = false

    private init() {
        if let soundURL = Bundle.main.url(forResource: "soundFileName", withExtension: "mp3") {
            audioPlayer = AVPlayer(url: soundURL)
        }
    }

    func toggleSound() {
        if let player = audioPlayer {
            if player.volume == 0 {
                player.volume = 1.0
                isMuted = false
            } else {
                player.volume = 0
                isMuted = true
            }
        }
    }

    func playSound() {
        audioPlayer?.play()
    }
}
