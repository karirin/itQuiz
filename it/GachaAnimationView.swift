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

class GachaAnimationViewModel: ObservableObject {
    @Published var isFinished: Bool = false {
        didSet {
            onIsFinishedChanged?(isFinished)
        }
    }
    @Published var isPlaying: Bool = true

    var onIsFinishedChanged: ((Bool) -> Void)?  // この行を追加

    var player: AVPlayer {
        let asset = NSDataAsset(name: "test")
        let videoUrl = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("test.mp4")
        try? asset?.data.write(to: videoUrl, options: [.atomic])
        let playerItem = AVPlayerItem(url: videoUrl)
        return AVPlayer(playerItem: playerItem)
    }

    init() {
        NotificationCenter.default.addObserver(self, selector: #selector(playerItemDidReachEnd(notification:)), name: .AVPlayerItemDidPlayToEndTime, object: self.player.currentItem)
    }

    @objc func playerItemDidReachEnd(notification: Notification) {
        isFinished = true
        isPlaying = false
    }
}

struct GachaAnimationView: View {
    @ObservedObject private var viewModel = GachaAnimationViewModel()
    @Binding var isFinished: Bool

    var body: some View {
        AVPlayerViewControllerRepresentable(player: viewModel.player, isPlaying: $viewModel.isPlaying)
            .onAppear {
                // ここでviewModelのisFinishedが変更されたときの処理をセットします。
                self.viewModel.onIsFinishedChanged = { finished in
                    self.isFinished = finished
                }
            }
            .onDisappear {
                NotificationCenter.default.removeObserver(self.viewModel, name: .AVPlayerItemDidPlayToEndTime, object: self.viewModel.player.currentItem)
            }
    }
}

