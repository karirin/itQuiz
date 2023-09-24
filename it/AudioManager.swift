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
        if let soundURL = Bundle.main.url(forResource: "sound", withExtension: "mp3") {
            audioPlayer = AVPlayer(url: soundURL)
        }
    }

    func toggleSound() {
        if let player = audioPlayer {
            print("test1")
            if player.volume == 0 {
                print("test2")
                player.pause()  // 一時停止
                player.volume = 1.0
                isMuted = false
                player.play()  // 再生
            } else {
                print("test3")
                player.pause()  // 一時停止
                player.volume = 0
                isMuted = true
                player.play()  // 再生
            }
        }
    }


    func playSound() {
        audioPlayer?.play()
    }
}
