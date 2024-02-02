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
    var audioReturnPlayer: AVPlayer?
    var audioDownPlayer: AVPlayer?
    var audioLevelUpPlayer: AVPlayer?
    var audioGameClearPlayer: AVPlayer?
    var audioGameOverPlayer: AVPlayer?
    var audioTittlePlayer: AVPlayer?

    @Published var isMuted: Bool = false

    init() {
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
        if let soundURL = Bundle.main.url(forResource: "ホームに戻る", withExtension: "mp3") {
            audioReturnPlayer = AVPlayer(url: soundURL)
        }
        if let soundURL = Bundle.main.url(forResource: "倒れる", withExtension: "mp3") {
            audioDownPlayer = AVPlayer(url: soundURL)
        }
        if let soundURL = Bundle.main.url(forResource: "レベルアップ", withExtension: "mp3") {
            audioLevelUpPlayer = AVPlayer(url: soundURL)
        }
        if let soundURL = Bundle.main.url(forResource: "ゲームクリア", withExtension: "mp3") {
            audioGameClearPlayer = AVPlayer(url: soundURL)
        }
        if let soundURL = Bundle.main.url(forResource: "ゲームオーバー", withExtension: "mp3") {
            audioGameOverPlayer = AVPlayer(url: soundURL)
        }
        if let soundURL = Bundle.main.url(forResource: "称号", withExtension: "mp3") {
            audioTittlePlayer = AVPlayer(url: soundURL)
        }
    }
    
    func toggleSound() {
        let players = [audioPlayer, audioKetteiPlayer, audioCorrectPlayer,audioUnCorrectPlayer,audioAttackPlayer,audioMonsterAttackPlayer,audioCountdownPlayer,audioCancelPlayer,audioChangePlayer,audioReturnPlayer,audioDownPlayer,audioLevelUpPlayer,audioGameClearPlayer,audioGameOverPlayer]
        for player in players {
            if let player = player {
                if player.volume == 0 {
                    player.volume = 1.0
                    isMuted = false
                } else {
                    player.volume = 0
                    isMuted = true
                }
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
    
    func playReturnSound() {
        audioReturnPlayer?.seek(to: CMTime.zero) // 再生位置を先頭に戻す
        audioReturnPlayer?.play()
    }
    
    func playDownSound() {
        audioDownPlayer?.seek(to: CMTime.zero) // 再生位置を先頭に戻す
        audioDownPlayer?.play()
    }
    func playLevelUpSound() {
        audioLevelUpPlayer?.seek(to: CMTime.zero) // 再生位置を先頭に戻す
        audioLevelUpPlayer?.play()
    }
    func playGameClearSound() {
        audioGameClearPlayer?.seek(to: CMTime.zero) // 再生位置を先頭に戻す
        audioGameClearPlayer?.play()
    }
    func playGameOverSound() {
        audioGameOverPlayer?.seek(to: CMTime.zero) // 再生位置を先頭に戻す
        audioGameOverPlayer?.play()
    }
    func playTittleSound() {
        audioTittlePlayer?.seek(to: CMTime.zero) // 再生位置を先頭に戻す
        audioTittlePlayer?.play()
    }
}
