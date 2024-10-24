//
//  TestView.swift
//  kyuyo
//
//  Created by Apple on 2024/08/30.
//

import SwiftUI

import SwiftUI
import UIKit

// パーティクルエフェクトの追加（オプション）
struct ParticleEmitterView1: UIViewRepresentable {
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
        cell.color = UIColor.cyan.cgColor // パーティクルの色を水色に設定

        emitter.emitterCells = [cell]
        view.layer.addSublayer(emitter)
        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {}
}

struct RippleEffect: View {
    @State private var ripple = false
    
    var body: some View {
        Circle()
            .stroke(Color.gray.opacity(0.5), lineWidth: 2)
            .frame(width: ripple ? 200 : 100, height: ripple ? 200 : 100)
            .opacity(ripple ? 0 : 1)
            .animation(Animation.easeOut(duration: 2).repeatForever(autoreverses: false), value: ripple)
            .onAppear {
                self.ripple = true
            }
    }
}

struct BubblesSpinner: View {
    @State private var animate = false
       private let numberOfBubbles = 6
       private let bubbleSize: CGFloat = 15
       private let animationDuration: Double = 1.2
       private let delayBetweenBubbles: Double = 0.2

       var body: some View {
           HStack(spacing: bubbleSize) {
               ForEach(0..<numberOfBubbles, id: \.self) { index in
                   Circle()
                       .fill(Color.blue)
                       .frame(width: bubbleSize, height: bubbleSize)
                       .scaleEffect(animate ? 1.5 : 0.5)
                       .opacity(animate ? 0.3 : 1.0)
                       .animation(
                           Animation.easeInOut(duration: animationDuration)
                               .repeatForever(autoreverses: true)
                               .delay(Double(index) * delayBetweenBubbles),
                           value: animate
                       )
               }
           }
           .onAppear {
               self.animate = true
           }
       }
}

struct CustomSpinner1: View {
    @State private var animate = false
       private let numberOfRings = 3
       private let ringSize: CGFloat = 60
       private let animationDuration: Double = 1.5
       private let delayBetweenRings: Double = 0.3

       var body: some View {
           ZStack {
               ForEach(0..<numberOfRings, id: \.self) { index in
                   Circle()
                       .stroke(Color.gray.opacity(0.5), lineWidth: 4)
                       .frame(width: ringSize, height: ringSize)
                       .scaleEffect(animate ? 2.0 : 0.5)
                       .opacity(animate ? 0.0 : 1.0)
                       .animation(
                           Animation.easeOut(duration: animationDuration)
                               .repeatForever(autoreverses: false)
                               .delay(Double(index) * delayBetweenRings),
                           value: animate
                       )
               }
           }
           .onAppear {
               self.animate = true
           }
       }
}

struct CustomSpinner2: View {
    @State private var animate = false
     private let numberOfBars = 5
     private let barWidth: CGFloat = 6
     private let barHeight: CGFloat = 20
     private let animationDuration: Double = 0.6
     private let delayBetweenBars: Double = 0.2

     var body: some View {
         HStack(alignment: .bottom, spacing: barWidth * 2) {
             ForEach(0..<numberOfBars, id: \.self) { index in
                 Rectangle()
                     .fill(Color.blue)
                     .frame(width: barWidth, height: animate ? barHeight : barHeight / 2)
                     .animation(
                         Animation.easeInOut(duration: animationDuration)
                             .repeatForever(autoreverses: true)
                             .delay(Double(index) * delayBetweenBars),
                         value: animate
                     )
             }
         }
         .onAppear {
             self.animate = true
         }
     }
}

struct CustomSpinner3: View {
    @State private var isAnimating = false
       private let arcCount = 12
       private let arcWidth: CGFloat = 4
       private let arcLength: CGFloat = 20
       private let animationDuration: Double = 1.0
       private let delayBetweenArcs: Double = 0.05

       var body: some View {
           ZStack {
               ForEach(0..<arcCount, id: \.self) { index in
                   Circle()
                       .trim(from: 0.0, to: CGFloat(arcLength) / 360)
                       .stroke(Color.blue.opacity(0.8), lineWidth: arcWidth)
                       .frame(width: 50, height: 50)
                       .rotationEffect(Angle(degrees: Double(index) * (360.0 / Double(arcCount))))
                       .opacity(isAnimating ? 1.0 : 0.3)
                       .animation(
                           Animation.easeInOut(duration: animationDuration)
                               .repeatForever(autoreverses: false)
                               .delay(Double(index) * delayBetweenArcs),
                           value: isAnimating
                       )
               }
           }
           .onAppear {
               self.isAnimating = true
           }
       }
}

struct CustomSpinner4: View {
    @State private var isAnimating = false
       private let dotCount = 7
       private let dotSize: CGFloat = 10
       private let waveHeight: CGFloat = 20
       private let animationDuration: Double = 1.0
       private let delayBetweenDots: Double = 0.1

       var body: some View {
           HStack(spacing: dotSize) {
               ForEach(0..<dotCount, id: \.self) { index in
                   Circle()
                       .fill(Color.green)
                       .frame(width: dotSize, height: dotSize)
                       .offset(y: isAnimating ? -waveHeight : 0)
                       .animation(
                           Animation.easeInOut(duration: animationDuration)
                               .repeatForever(autoreverses: true)
                               .delay(Double(index) * delayBetweenDots),
                           value: isAnimating
                       )
               }
           }
           .onAppear {
               self.isAnimating = true
           }
       }
}

struct CustomSpinner5: View {
    @State private var activeIndex = 0          // 現在アクティブな文字のインデックス
    @State private var isUp = false             // 文字が上がっているかどうか
    @State private var imageScaled = false      // ライム画像がスケールアップしているかどうか
    @State private var limeSpring = false       // ライム画像のスプリングアニメーション用フラグ
    
    private let text = "Loading…"                 // 表示するテキスト
    private let waveHeight: CGFloat = 10         // 文字が上がる高さ
    private let animationDuration: Double = 0.2   // アニメーションの持続時間（秒）
    private let delayBetweenLetters: Double = 0.05 // 文字間の遅延時間（秒）
    
    var body: some View {
        VStack(spacing: 8) { // 画像と文字間のスペースを調整
            // ライムの画像
            Image("ライム")
                .resizable()
                .frame(width: 80, height: 80)
                .scaleEffect(imageScaled ? 1.0 : 0.5) // 初期ポップイン用のスケール効果
                .scaleEffect(limeSpring ? 1.2 : 1.0)    // スプリングアニメーション用のスケール効果
                .animation(
                    .spring(response: 0.5, dampingFraction: 0.6, blendDuration: 0),
                    value: imageScaled
                )
                .animation(
                    .spring(response: 0.3, dampingFraction: 0.5, blendDuration: 0),
                    value: limeSpring
                )
            
            // "Loading…" の文字
            HStack(spacing: 5) {
                ForEach(Array(text.enumerated()), id: \.offset) { index, character in
                    Text(String(character))
                        .font(.system(size: 26, weight: .bold))
                        .foregroundColor(Color(hue: 0.369, saturation: 0.703, brightness: 0.487))
                        .offset(y: (index == activeIndex && isUp) ? -waveHeight : 0) // アクティブな文字のみオフセットを適用
                        .animation(
                            Animation.easeInOut(duration: animationDuration),
                            value: isUp
                        )
                }
            }
        }
        .onAppear {
            startImageAndSequentialAnimation() // ビューが表示されたときにアニメーションを開始
        }
    }
    
    /// 画像のポップインと文字の順次アニメーションを開始する関数
    func startImageAndSequentialAnimation() {
        Task {
            // ライムの画像をポップインさせる
            withAnimation {
                imageScaled = true
            }
            // ポップインアニメーションの完了を待機（アニメーション時間 + マージン）
            try? await Task.sleep(nanoseconds: UInt64(0.5 * 1_000_000_000)) // 0.5秒待機
            
            // 文字の順次アニメーションを開始
            startSequentialAnimation()
        }
    }
    
    /// 文字の順次アニメーションを開始する関数
    func startSequentialAnimation() {
        Task {
            while true {
                // 現在の文字を上昇させる
                withAnimation {
                    isUp = true
                }
                // アニメーションの上昇部分を待機
                try? await Task.sleep(nanoseconds: UInt64(animationDuration * 1_000_000_000)) // 0.2秒
                
                // 現在の文字を下降させる
                withAnimation {
                    isUp = false
                }
                // アニメーションの下降部分を待機
                try? await Task.sleep(nanoseconds: UInt64(animationDuration * 1_000_000_000)) // 0.2秒
                
                // 「g」のアニメーションが完了した場合、ライム画像をスプリングさせる
                if activeIndex == text.count - 1 { // 最後の文字（"g"）のインデックス
                    withAnimation {
                        limeSpring = true
                    }
                    // スプリングアニメーションの完了を待機
                    try? await Task.sleep(nanoseconds: UInt64(0.3 * 1_000_000_000)) // 0.3秒待機
                    
                    // スプリングアニメーションをリセット
                    withAnimation {
                        limeSpring = false
                    }
                }
                
                // 次の文字に移行
                activeIndex = (activeIndex + 1) % text.count
                
                // 文字間の遅延を追加
                try? await Task.sleep(nanoseconds: UInt64(delayBetweenLetters * 1_000_000_000)) // 0.05秒
            }
        }
    }
}

struct CustomSpinner: View {
    @State private var isAnimating = false
     private let segmentCount = 8
     private let ringSize: CGFloat = 60
     private let segmentWidth: CGFloat = 4
     private let segmentLength: CGFloat = 10
     private let animationDuration: Double = 1.5
     private let delayBetweenSegments: Double = 0.1

     var body: some View {
         ZStack {
             ForEach(0..<segmentCount, id: \.self) { index in
                 Capsule()
                     .fill(Color.purple)
                     .frame(width: segmentLength, height: segmentWidth)
                     .offset(y: -ringSize / 2)
                     .rotationEffect(Angle(degrees: isAnimating ? 360 : 0))
                     .opacity(isAnimating ? 1.0 : 0.3)
                     .animation(
                         Animation.linear(duration: animationDuration)
                             .repeatForever(autoreverses: false)
                             .delay(Double(index) * delayBetweenSegments),
                         value: isAnimating
                     )
             }
         }
         .frame(width: ringSize, height: ringSize)
         .onAppear {
             self.isAnimating = true
         }
     }
}

struct ActivityIndicator: View {
    @State private var isActive = false
    @State private var isAnimating = false

    var body: some View {
        ZStack {
            // グラデーション背景
//            LinearGradient(gradient: Gradient(colors: [Color.blue.opacity(0.6), Color.cyan.opacity(0.6)]),
//                           startPoint: .topLeading,
//                           endPoint: .bottomTrailing)
//                .edgesIgnoringSafeArea(.all)
//                .animation(.easeInOut(duration: 3).repeatForever(autoreverses: true), value: Color.blue.opacity(0.6))
//                .onAppear {
//                    self.isAnimating = true
//                }

            ZStack() {
                // カスタムスピナーとロゴ
                ZStack {
                    // カスタムスピナー
                    CustomSpinner5()
                }
                
//                // 波紋エフェクト
//                RippleEffect()
//                    .frame(width: 200, height: 200)
            }

            // パーティクルエフェクトを追加（オプション）
            ParticleEmitterView1()
                .blendMode(.screen)
                .edgesIgnoringSafeArea(.all)
        }
        .onAppear {
            // 3秒後にメインコンテンツに遷移
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                withAnimation {
                    self.isActive = true
                }
            }
        }
    }
}

struct ActivityIndicator_Previews: PreviewProvider {
    static var previews: some View {
        ActivityIndicator()
    }
}
