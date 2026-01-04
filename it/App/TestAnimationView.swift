////
////  TestAnimationView.swift
////  it
////
////  Created by Apple on 2024/02/14.
////
//
//import SwiftUI
//import AVKit
//import AVFoundation
//
//struct VideoPlayerView: View {
//    private var player: AVPlayer
//    @Binding var showAnimation: Bool
//
//    init(videoName: String, videoType: String, showAnimation: Binding<Bool>) {
//        let filePath = Bundle.main.path(forResource: videoName, ofType: videoType)!
//        let fileURL = URL(fileURLWithPath: filePath)
//        self.player = AVPlayer(url: fileURL)
//        self._showAnimation = showAnimation
//    }
//
//    var body: some View {
//        ZStack {
//            VideoPlayer(player: player)
//                .onAppear {
//                    player.play()
//                }
//                .onDisappear {
//                    player.pause()
//                }
//
//            // スキップボタン
//            VStack {
//                Spacer()
//                HStack {
//                    Spacer()
//                    Button("スキップ") {
//                        // スキップボタンがタップされたときのアクション
//                        showAnimation = false
//                        player.pause()
//                    }
//                    .padding()
//                    .background(Color.white.opacity(0.7))
//                    .cornerRadius(10)
//                    .foregroundColor(Color.black)
//                    .padding()
//                }
//            }
//        }
//        .edgesIgnoringSafeArea(.all)
//        .onDisappear {
//            // ビデオ再生が終わったときにも再生を停止
//            player.pause()
//        }
//    }
//}
//
////struct AVPlayerViewControllerRepresentable: UIViewControllerRepresentable {
////    @Binding var player: AVPlayer?
////    @Binding var showAnimation: Bool
////
////    func makeUIViewController(context: Context) -> AVPlayerViewController {
////        let controller = AVPlayerViewController()
////        controller.player = player
////        controller.showsPlaybackControls = false
////        return controller
////    }
////
////    func updateUIViewController(_ uiViewController: AVPlayerViewController, context: Context) {
////        if uiViewController.player == nil {
////          uiViewController.player = player
////        }
////        if showAnimation {
////          uiViewController.player?.play()
////        } else {
////          uiViewController.player?.pause()
////        }
////    }
////}
//
//struct TestAnimationView: View {
//    @State private var player: AVPlayer?
//    @Binding var showAnimation: Bool
////    var rarity: GachaManager.Rarity?
////    @Binding var showResult: Bool
//
//    private func createPlayer() -> AVPlayer {
//        let videoName: String
////        switch rarity {
////        case .normal:
////            videoName = "normal"
////        case .rare:
////            videoName = "rare"
////        case .superRare:
////            videoName = "superRare"
////        case .ultraRare:
////            videoName = "ultraRare"
////        case .Rrare:
////            videoName = "Rrare"
////        case .RsuperRare:
////            videoName = "RsuperRare"
////        case .RultraRare:
////            videoName = "RultraRare"
////        case .legendRare:
////            videoName = "legendRare"
////        default:
////            videoName = "normal"
////        }
//
//        let asset = NSDataAsset(name: "物語のはじまり")
////        print("videoName")
////        print(videoName)
//        let videoUrl = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("物語のはじまり.mp4")
//        try? asset?.data.write(to: videoUrl, options: [.atomic])
//        let playerItem = AVPlayerItem(url: videoUrl)
////        print("playerItem:\(playerItem)")
//        return AVPlayer(playerItem: playerItem)
//    }
//
//    var body: some View {
//        AVPlayerViewControllerRepresentable(player: $player, showAnimation: $showAnimation)
//            .onAppear {
//                self.player = createPlayer()
//                NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: self.player?.currentItem, queue: .main) { _ in
//                  showAnimation.toggle()
////                  showResult = true
//                }
//            }
////            .onChange(of: rarity) { _ in
////                self.player = createPlayer()
////            }
//    }
//}
//
//struct TestAnimation1View: View {
//    @State private var player: AVPlayer?
//    @Binding var showAnimation: Bool
////    var rarity: GachaManager.Rarity?
////    @Binding var showResult: Bool
//
//    private func createPlayer() -> AVPlayer {
//        let videoName: String
////        switch rarity {
////        case .normal:
////            videoName = "normal"
////        case .rare:
////            videoName = "rare"
////        case .superRare:
////            videoName = "superRare"
////        case .ultraRare:
////            videoName = "ultraRare"
////        case .Rrare:
////            videoName = "Rrare"
////        case .RsuperRare:
////            videoName = "RsuperRare"
////        case .RultraRare:
////            videoName = "RultraRare"
////        case .legendRare:
////            videoName = "legendRare"
////        default:
////            videoName = "normal"
////        }
//
//        let asset = NSDataAsset(name: "出会い")
//        print("videoName")
////        print(videoName)
//        let videoUrl = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("出会い.mp4")
//        try? asset?.data.write(to: videoUrl, options: [.atomic])
//        let playerItem = AVPlayerItem(url: videoUrl)
////        print("playerItem:\(playerItem)")
//        return AVPlayer(playerItem: playerItem)
//    }
//
//    var body: some View {
//        AVPlayerViewControllerRepresentable(player: $player, showAnimation: $showAnimation)
//            .onAppear {
//                self.player = createPlayer()
//                NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: self.player?.currentItem, queue: .main) { _ in
//                  showAnimation.toggle()
////                  showResult = true
//                }
//            }
////            .onChange(of: rarity) { _ in
////                self.player = createPlayer()
////            }
//    }
//}
//
//
//#Preview {
//    TestAnimationView(showAnimation: .constant(false))
//}
