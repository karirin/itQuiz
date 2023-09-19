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
        return controller
    }

    func updateUIViewController(_ uiViewController: AVPlayerViewController, context: Context) {
        // 何もしない
    }
}


struct GachaAnimationView: View {
    private var player: AVPlayer {
        AVPlayer(url: Bundle.main.url(forResource: "test.mp4", withExtension: "mp4")!)
    }

    @Binding var isFinished: Bool

    var body: some View {
        AVPlayerViewControllerRepresentable(player: player)
            .onAppear {
                NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: player.currentItem, queue: .main) { _ in
                    isFinished = true
                }
                player.play()
            }
    }
}
