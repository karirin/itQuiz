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

    func makeUIViewController(context: Context) -> AVPlayerViewController {
        let controller = AVPlayerViewController()
        controller.player = player
        controller.showsPlaybackControls = false
        return controller
    }

    func updateUIViewController(_ uiViewController: AVPlayerViewController, context: Context) {
        // 何もしない
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

    @Binding var isFinished: Bool

    var body: some View {
        AVPlayerViewControllerRepresentable(player: player)
            .onAppear {
                NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: self.player.currentItem, queue: .main) { _ in
                    isFinished = true
                }
                player.play()  // ここで再生を開始
            }
    }
}
