import SwiftUI
import UIKit

// パーティクルエフェクトの追加（オプション）
struct ParticleEmitterView: UIViewRepresentable {
    func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: .zero)
        let emitter = CAEmitterLayer()
        emitter.emitterPosition = CGPoint(x: UIScreen.main.bounds.width / 2, y: UIScreen.main.bounds.height / 2)
        emitter.emitterShape = .circle
        emitter.emitterSize = CGSize(width: 100, height: 100)

        let cell = CAEmitterCell()
        cell.birthRate = 20
        cell.lifetime = 5.0
        cell.velocity = 100
        cell.velocityRange = 50
        cell.emissionRange = .pi * 2
        cell.scale = 0.05
        cell.contents = UIImage(systemName: "sparkle")?.cgImage
        cell.color = UIColor.white.cgColor // パーティクルの色を白に設定

        emitter.emitterCells = [cell]
        view.layer.addSublayer(emitter)
        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {}
}

struct SplashScreenView: View {
    @State private var isActive = false
    @State private var scale: CGFloat = 0.5
    @State private var opacity = 0.0
    @State private var opacity2 = 0.0
    @State private var bgGradientStart = Color.white
    @State private var bgGradientEnd = Color.white
    @State private var showText = false
    @State private var colorCycle: Double = 0
    @State private var textBlur: CGFloat = 10.0 // テキストのブラー半径
    @State private var textScale: CGFloat = 0.8 // テキストのスケール
    @State private var textScale2: CGFloat = 0.8 // テキストのスケール

    var body: some View {
//        if isActive {
//            TopView()
//        } else {
            ZStack {
                // 背景グラデーション（より水色系）
//                LinearGradient(gradient: Gradient(colors: [bgGradientStart, bgGradientEnd]),
//                               startPoint: .topLeading,
//                               endPoint: .bottomTrailing)
//                    .animation(.easeInOut(duration: 3).repeatForever(autoreverses: true), value: bgGradientStart)
//                    .edgesIgnoringSafeArea(.all)
//                    .onAppear {
//                        // グラデーションの色を水色系に変更してアニメーションさせる
//                        bgGradientStart = Color.cyan.opacity(0.6)
//                        bgGradientEnd = Color.blue.opacity(0.6)
//                    }
                
                VStack(spacing: 20) {
                    
                    // ロゴ画像
                    Image("ロゴ") // ロゴ画像を指定
                        .resizable()
                        .cornerRadius(20)
                        .scaledToFit()
                        .frame(width: 100, height: 100) // サイズを少し大きく
                        .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 5) // シャドウの色と位置を調整
                        .scaleEffect(scale)
                        .opacity(opacity)
                        .foregroundColor(Color(hue: colorCycle, saturation: 1, brightness: 1))
                        .onAppear {
                            // バウンスアニメーション
                            withAnimation(.interpolatingSpring(stiffness: 50, damping: 5).delay(0.2)) {
                                self.scale = 1.0
                                self.opacity = 1.0
                            }
                            
                            // カラーサイクルアニメーション
                            withAnimation(.linear(duration: 3).repeatForever(autoreverses: false)) {
                                self.colorCycle = 1.0
                            }
                            
                            // テキストのフェードインとブラーのアニメーション
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                                withAnimation(.easeIn(duration: 1.0)) {
                                    self.showText = true
                                    self.textBlur = 0.0 // ブラーを減少
                                    self.textScale = 1.0 // スケールを戻す
                                }
                            }
                            
                            // アニメーション後にメインコンテンツに遷移
                            DispatchQueue.main.asyncAfter(deadline: .now() + 4.0) {
                                withAnimation {
                                    self.isActive = true
                                }
                            }
                        }
                    
                    // テキストビュー
                    if showText {
                        Image("ITクエスト文字")
                            .resizable()
                            .frame(width: 180, height: 50) // サイズを調整
                            .opacity(opacity2)
                            .blur(radius: textBlur) // ブラーエフェクト
                            .scaleEffect(textScale2) // スケールエフェクト
                            .transition(.opacity)
                            .onAppear {
                                withAnimation(.easeOut(duration: 1.0)) {
                                    self.textScale2 = 1.0
                                    self.opacity2 = 1.0
                                }
                            }
                    }
                }
                .frame(maxWidth:.infinity,maxHeight:.infinity)
                .background(Color("Color2"))
                
                // パーティクルエフェクトを追加（オプション）
                ParticleEmitterView()
                    .blendMode(.screen)
                    .edgesIgnoringSafeArea(.all)
            }
        }
//    }
}

struct SplashScreenView_Previews: PreviewProvider {
    static var previews: some View {
        SplashScreenView()
    }
}
