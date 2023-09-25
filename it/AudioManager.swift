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
    var audioKetteiPlayer: AVPlayer?
    var audioCorrectPlayer: AVPlayer?

    @Published var isMuted: Bool = false

    private init() {
        if let soundURL = Bundle.main.url(forResource: "sound", withExtension: "mp3") {
            audioPlayer = AVPlayer(url: soundURL)
        }
        if let soundURL = Bundle.main.url(forResource: "soundKettei", withExtension: "mp3") {
            audioKetteiPlayer = AVPlayer(url: soundURL)
        }
        if let soundURL = Bundle.main.url(forResource: "正解", withExtension: "mp3") {
            audioCorrectPlayer = AVPlayer(url: soundURL)
        }
    }

    func toggleSound() {
        if let player = audioPlayer {
            if player.volume == 0 {
                player.pause()  // 一時停止
                player.volume = 1.0
                isMuted = false
                player.play()  // 再生
            } else {
                player.pause()  // 一時停止
                player.volume = 0
                isMuted = true
                player.play()  // 再生
            }
        }
        if let player = audioKetteiPlayer {
            if player.volume == 0 {
                player.pause()  // 一時停止
                player.volume = 1.0
                isMuted = false
                player.play()  // 再生
            } else {
                player.pause()  // 一時停止
                player.volume = 0
                isMuted = true
                player.play()  // 再生
            }
        }
    }


    func playSound() {
        audioPlayer?.seek(to: CMTime.zero) // 再生位置を先頭に戻す
        audioPlayer?.play()
    }
    
    func playKetteiSound() {
        audioKetteiPlayer?.seek(to: CMTime.zero) // 再生位置を先頭に戻す
        audioKetteiPlayer?.play()
    }
    
    func playCorrectSound() {
        audioCorrectPlayer?.seek(to: CMTime.zero) // 再生位置を先頭に戻す
        audioCorrectPlayer?.play()
    }

}
