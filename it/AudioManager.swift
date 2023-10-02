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
    var audioUnCorrectPlayer: AVPlayer?
    var audioAttackPlayer: AVPlayer?
    var audioMonsterAttackPlayer: AVPlayer?
    var audioCountdownPlayer: AVPlayer?
    var audioCancelPlayer: AVPlayer?
    var audioChangePlayer: AVPlayer?

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
        if let soundURL = Bundle.main.url(forResource: "不正解", withExtension: "mp3") {
            audioUnCorrectPlayer = AVPlayer(url: soundURL)
        }
        if let soundURL = Bundle.main.url(forResource: "味方攻撃", withExtension: "mp3") {
            audioAttackPlayer = AVPlayer(url: soundURL)
        }
        if let soundURL = Bundle.main.url(forResource: "敵攻撃", withExtension: "mp3") {
            audioMonsterAttackPlayer = AVPlayer(url: soundURL)
        }
        if let soundURL = Bundle.main.url(forResource: "カウントダウン", withExtension: "mp3") {
            audioCountdownPlayer = AVPlayer(url: soundURL)
        }
        if let soundURL = Bundle.main.url(forResource: "キャンセル", withExtension: "mp3") {
            audioCancelPlayer = AVPlayer(url: soundURL)
        }
        if let soundURL = Bundle.main.url(forResource: "おとも切り替え", withExtension: "mp3") {
            audioChangePlayer = AVPlayer(url: soundURL)
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
        if let player = audioCorrectPlayer {
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
        if let player = audioUnCorrectPlayer {
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
        if let player = audioAttackPlayer {
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
        if let player = audioMonsterAttackPlayer {
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
        if let player = audioCountdownPlayer {
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
        if let player = audioCancelPlayer {
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
        if let player = audioChangePlayer {
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

    func playUnCorrectSound() {
        audioUnCorrectPlayer?.seek(to: CMTime.zero) // 再生位置を先頭に戻す
        audioUnCorrectPlayer?.play()
    }
    
    func playAttackSound() {
        audioAttackPlayer?.seek(to: CMTime.zero) // 再生位置を先頭に戻す
        audioAttackPlayer?.play()
    }

    func playMonsterAttackSound() {
        audioMonsterAttackPlayer?.seek(to: CMTime.zero) // 再生位置を先頭に戻す
        audioMonsterAttackPlayer?.play()
    }
    
    func playCountdownSound() {
        audioCountdownPlayer?.seek(to: CMTime.zero) // 再生位置を先頭に戻す
        audioCountdownPlayer?.play()
    }
    
    func playCancelSound() {
        audioCancelPlayer?.seek(to: CMTime.zero) // 再生位置を先頭に戻す
        audioCancelPlayer?.play()
    }
    
    func playChangeSound() {
        audioChangePlayer?.seek(to: CMTime.zero) // 再生位置を先頭に戻す
        audioChangePlayer?.play()
    }
}
