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
        // 毎回バインディングされた player を反映する
        uiViewController.player = player
        
        if showAnimation {
            uiViewController.player?.seek(to: .zero)
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

    private func createPlayer() -> AVPlayer? {
        let videoName: String
        switch rarity {
        case .normal:
            videoName = "normal"
        case .rare:
            videoName = "rare"
        case .superRare:
            videoName = "superRare"
        case .ultraRare:
            videoName = "ultraRare"
        case .Rrare:
            videoName = "Rrare"
        case .RsuperRare:
            videoName = "RsuperRare"
        case .RultraRare:
            videoName = "RultraRare"
        case .legendRare:
            videoName = "legendRare"
        case .mekaRare:
            videoName = "mekaRare"
        case .mekaSuperRare:
            videoName = "mekaSuperRare"
        case .mekaUltraRare:
            videoName = "mekaUltraRare"
        case .mekaLegendRare:
            videoName = "mekaLegendRare"
        default:
            videoName = "normal"
        }

//        let asset = NSDataAsset(name: videoName)
//        print("videoName    :\(videoName)")
////        print(videoName)
//        let videoUrl = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("\(videoName).mp4")
//        try? asset?.data.write(to: videoUrl, options: [.atomic])
//        let playerItem = AVPlayerItem(url: videoUrl)
////        print("playerItem:\(playerItem)")
//        return AVPlayer(playerItem: playerItem)
        guard let asset = NSDataAsset(name: videoName) else {
            print("❌ video not found in Assets.xcassets: \(videoName)")
            return nil
        }
        let videoUrl = URL(fileURLWithPath: NSTemporaryDirectory())
            .appendingPathComponent("\(videoName).mp4")
        try? asset.data.write(to: videoUrl, options: [.atomic])
        return AVPlayer(url: videoUrl)
    }

    var body: some View {
        AVPlayerViewControllerRepresentable(player: $player, showAnimation: $showAnimation)
            .onAppear {
                self.player = createPlayer()
                self.player?.play()
            }
            .onChange(of: rarity) { _ in
                self.player = createPlayer()
                self.player?.play()
            }
            .onDisappear {
                self.player?.pause()
                self.player = nil
            }
    }
}
