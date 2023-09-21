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
    var player: AVPlayer
    @Binding var isPlaying: Bool  // 再生の状態を監視するためのプロパティ

    func makeUIViewController(context: Context) -> AVPlayerViewController {
        let controller = AVPlayerViewController()
        controller.player = player
        controller.showsPlaybackControls = false
        return controller
    }

    func updateUIViewController(_ uiViewController: AVPlayerViewController, context: Context) {
        if isPlaying {
            player.play()
        } else {
            player.pause()
        }
    }
}

struct GachaAnimationView: View {
    private var player: AVPlayer {
      let asset = NSDataAsset(name: "test")
      let videoUrl = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("test.mp4")
      try? asset?.data.write(to: videoUrl, options: [.atomic])
      let playerItem = AVPlayerItem(url: videoUrl)
      return AVPlayer(playerItem: playerItem)
    }

    @State private var isPlaying = true  // 再生の状態を管理するためのプロパティ
    @Binding var isFinished: Bool

    var body: some View {
        AVPlayerViewControllerRepresentable(player: player, isPlaying: $isPlaying)
            .onAppear {
                NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: self.player.currentItem, queue: .main) { _ in
                    isFinished = true
                    isPlaying = false  // 再生が終了したら、再生の状態をfalseに設定
                }
            }
    }
}
