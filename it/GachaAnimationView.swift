//
//  GachaAnimationView.swift
//  it
//
//  Created by hashimo ryoya on 2023/09/18.
//

import SwiftUI
import AVKit
import AVFoundation

struct AVPlayerViewControllerRepresentable: UIViewControllerRepresentable {
    @Binding var player: AVPlayer?
    @Binding var showAnimation: Bool

    func makeUIViewController(context: Context) -> AVPlayerViewController {
        let controller = AVPlayerViewController()
        controller.player = player
        controller.showsPlaybackControls = false
        return controller
    }

    func updateUIViewController(_ uiViewController: AVPlayerViewController, context: Context) {
        if uiViewController.player == nil {
          uiViewController.player = player
        }
        if showAnimation {
          uiViewController.player?.play()
        } else {
          uiViewController.player?.pause()
        }
    }
}

struct GachaAnimationView: View {
    @State private var player: AVPlayer?
    @Binding var showAnimation: Bool
    var rarity: GachaManager.Rarity?
//    @Binding var showResult: Bool

    private func createPlayer() -> AVPlayer {
        let videoName: String
        switch rarity {
        case .normal:
            videoName = "normal"
        case .rare:
            videoName = "rare"
        case .superRare:
            videoName = "superRare"
        case .ultraRare:
            videoName = "RultraRare"
        case .Rrare:
            videoName = "Rrare"
        case .RsuperRare:
            videoName = "RsuperRare"
        case .RultraRare:
            videoName = "ultraRare"
        case .legendRare:
            videoName = "legendRare"
        default:
            videoName = "normal"
        }

        let asset = NSDataAsset(name: videoName)
        print("videoName")
        print(videoName)
        let videoUrl = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("\(videoName).mp4")
        try? asset?.data.write(to: videoUrl, options: [.atomic])
        let playerItem = AVPlayerItem(url: videoUrl)
//        print("playerItem:\(playerItem)")
        return AVPlayer(playerItem: playerItem)
    }

    var body: some View {
        AVPlayerViewControllerRepresentable(player: $player, showAnimation: $showAnimation)
            .onAppear {
                self.player = createPlayer()
                NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: self.player?.currentItem, queue: .main) { _ in
                  showAnimation.toggle()
//                  showResult = true
                }
            }
            .onChange(of: rarity) { _ in
                self.player = createPlayer()
            }
    }
}
