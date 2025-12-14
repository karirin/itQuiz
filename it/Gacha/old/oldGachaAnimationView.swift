////
////  GachaAnimationView.swift
////  it
////
////  Created by hashimo ryoya on 2023/09/18.
////
//
//import SwiftUI
//import AVKit
//import AVFoundation
//
//// MARK: - UIKit ラッパー
//
//struct GachaPlayerContainer: UIViewControllerRepresentable {
//    let player: AVPlayer
//    let onFinished: () -> Void
//
//    class Coordinator {
//        let onFinished: () -> Void
//
//        init(onFinished: @escaping () -> Void) {
//            self.onFinished = onFinished
//        }
//
//        @objc func playerDidFinish(_ notification: Notification) {
//            onFinished()
//        }
//    }
//
//    func makeCoordinator() -> Coordinator {
//        Coordinator(onFinished: onFinished)
//    }
//
//    func makeUIViewController(context: Context) -> AVPlayerViewController {
//        let controller = AVPlayerViewController()
//        controller.player = player
//        controller.showsPlaybackControls = false
//
//        // 再生完了を監視
//        NotificationCenter.default.addObserver(
//            context.coordinator,
//            selector: #selector(Coordinator.playerDidFinish(_:)),
//            name: .AVPlayerItemDidPlayToEndTime,
//            object: player.currentItem
//        )
//
//        return controller
//    }
//
//    func updateUIViewController(_ uiViewController: AVPlayerViewController, context: Context) {
//        uiViewController.player = player
//    }
//}
//
//// MARK: - GachaAnimationView
//
//struct GachaAnimationView: View {
//    let rarity: GachaManager.Rarity?
//    let onFinished: () -> Void
//
//    @State private var player: AVPlayer?
//
//    private func createPlayer() -> AVPlayer? {
//        let videoName = (rarity ?? .normal).movieName
//        print("🎬 try load video (bundle only):", videoName)
//
//        guard let url = Bundle.main.url(forResource: videoName, withExtension: "mp4") else {
//            print("❌ movie file not found in bundle:", "\(videoName).mp4")
//            return nil
//        }
//
//        print("✅ movie url from bundle:", url)
//        return AVPlayer(url: url)
//    }
//
//
//    var body: some View {
//        Group {
//            if let player {
//                ZStack {
//                    // ✅ 動画プレイヤー
//                    VideoPlayer(player: player)
//                        .onAppear {
//                            player.seek(to: .zero)
//                            player.play()
//
//                            // 再生完了で onFinished を呼ぶ
//                            NotificationCenter.default.addObserver(
//                                forName: .AVPlayerItemDidPlayToEndTime,
//                                object: player.currentItem,
//                                queue: .main
//                            ) { _ in
//                                print("🎉 video finished")
//                                onFinished()
//                            }
//                        }
//                        .onDisappear {
//                            player.pause()
//                        }
//
//                    // ✅ デバッグ用オーバーレイ（必ず白文字が出るはず）
//                    VStack {
//                        Text("Playing: \((rarity ?? .normal).movieName)")
//                            .foregroundColor(.white)
//                            .padding()
//                            .background(Color.black.opacity(0.5))
//                        Spacer()
//                    }
//                }
//            } else {
//                Color.black
//                    .onAppear {
//                        if player == nil {
//                            player = createPlayer()
//                        }
//                        player?.seek(to: .zero)
//                        player?.play()
//                    }
//            }
//        }
//        .ignoresSafeArea()
//    }
//
//}
