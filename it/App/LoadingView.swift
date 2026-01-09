//
//  TestView.swift
//  kyuyo
//
//  Created by Apple on 2024/08/30.
//

import SwiftUI

import SwiftUI
import UIKit

struct ModernLoadingView: View {
    @State private var isAnimating = false
    @State private var characterBounce = false
    @State private var textOpacity = 0.0
    @State private var dotIndex = 0
    
    let timer = Timer.publish(every: 0.4, on: .main, in: .common).autoconnect()
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                colors: [
                    Color(red: 0.08, green: 0.08, blue: 0.15),
                    Color(red: 0.12, green: 0.1, blue: 0.2)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            // Animated background particles
            ParticleSystemView()
            
            // Main content
            VStack(spacing: 40) {
                // Logo area with glow effect
                ZStack {
                    // Outer glow rings
                    ForEach(0..<3) { i in
                        Circle()
                            .stroke(
                                LinearGradient(
                                    colors: [
                                        Color.purple.opacity(0.3 - Double(i) * 0.1),
                                        Color.blue.opacity(0.2 - Double(i) * 0.05)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 2
                            )
                            .frame(width: 140 + CGFloat(i * 30), height: 140 + CGFloat(i * 30))
                            .scaleEffect(isAnimating ? 1.1 : 0.9)
                            .opacity(isAnimating ? 0.3 : 0.8)
                            .animation(
                                .easeInOut(duration: 1.5)
                                .repeatForever(autoreverses: true)
                                .delay(Double(i) * 0.2),
                                value: isAnimating
                            )
                    }
                    
                    // Character with bounce animation
                    Image("ライム")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 100, height: 100)
                        .shadow(color: Color.purple.opacity(0.5), radius: 20, x: 0, y: 10)
                        .offset(y: characterBounce ? -15 : 5)
                }
                
                // Loading text with animated dots
                HStack(spacing: 4) {
                    Text("Loading")
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                    
                    HStack(spacing: 4) {
                        ForEach(0..<3) { i in
                            Circle()
                                .fill(Color.white)
                                .frame(width: 8, height: 8)
                                .opacity(dotIndex >= i ? 1 : 0.3)
                        }
                    }
                }
                .opacity(textOpacity)
                
                // Progress indicator
                LoadingProgressBar()
                    .frame(width: 200)
                    .opacity(textOpacity)
            }
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true)) {
                characterBounce = true
            }
            withAnimation {
                isAnimating = true
            }
            withAnimation(.easeIn(duration: 0.5)) {
                textOpacity = 1.0
            }
        }
        .onReceive(timer) { _ in
            dotIndex = (dotIndex + 1) % 4
        }
    }
}

// MARK: - Loading Progress Bar
struct LoadingProgressBar: View {
    @State private var progress: CGFloat = 0
    @State private var shimmerOffset: CGFloat = -200
    
    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                // Background track
                Capsule()
                    .fill(Color.white.opacity(0.1))
                    .frame(height: 6)
                
                // Progress fill
                Capsule()
                    .fill(
                        LinearGradient(
                            colors: [Color.purple, Color.blue, Color.cyan],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: geo.size.width * progress, height: 6)
                
                // Shimmer effect
                Capsule()
                    .fill(
                        LinearGradient(
                            colors: [Color.clear, Color.white.opacity(0.5), Color.clear],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: 50, height: 6)
                    .offset(x: shimmerOffset)
                    .mask(
                        Capsule()
                            .frame(width: geo.size.width * progress, height: 6)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    )
            }
        }
        .frame(height: 6)
        .onAppear {
            withAnimation(.linear(duration: 2).repeatForever(autoreverses: false)) {
                shimmerOffset = 250
            }
            withAnimation(.easeInOut(duration: 2).repeatForever(autoreverses: true)) {
                progress = 0.8
            }
        }
    }
}

// MARK: - Particle System
struct ParticleSystemView: View {
    @State private var particles: [LoadingParticle] = []
    
    struct LoadingParticle: Identifiable {
        let id = UUID()
        var x: CGFloat
        var y: CGFloat
        var size: CGFloat
        var opacity: Double
        var color: Color
    }
    
    var body: some View {
        GeometryReader { geo in
            ForEach(particles) { particle in
                Circle()
                    .fill(particle.color)
                    .frame(width: particle.size, height: particle.size)
                    .opacity(particle.opacity)
                    .position(x: particle.x * geo.size.width, y: particle.y * geo.size.height)
                    .blur(radius: particle.size / 4)
            }
        }
        .onAppear {
            particles = (0..<20).map { _ in
                LoadingParticle(
                    x: CGFloat.random(in: 0...1),
                    y: CGFloat.random(in: 0...1),
                    size: CGFloat.random(in: 4...12),
                    opacity: Double.random(in: 0.1...0.4),
                    color: [Color.purple, Color.blue, Color.cyan].randomElement()!
                )
            }
        }
    }
}

// MARK: - Modern Splash Screen
struct ModernSplashScreen: View {
    @State private var logoScale: CGFloat = 0.5
    @State private var logoOpacity: Double = 0
    @State private var titleOpacity: Double = 0
    @State private var titleOffset: CGFloat = 30
    @State private var ringRotation: Double = 0
    @State private var showParticles = false
    
    var body: some View {
        ZStack {
            // Animated gradient background
            AnimatedGradientBackground()
            
            // Floating particles (appear after logo animation)
            if showParticles {
                SplashParticleView()
            }
            
            VStack(spacing: 30) {
                // Logo with animated rings
                ZStack {
                    // Outer decorative ring
                    Circle()
                        .stroke(
                            AngularGradient(
                                colors: [.purple, .blue, .cyan, .purple],
                                center: .center
                            ),
                            lineWidth: 3
                        )
                        .frame(width: 150, height: 150)
                        .rotationEffect(.degrees(ringRotation))
                        .opacity(logoOpacity * 0.5)
                    
                    // Inner glow
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [Color.purple.opacity(0.3), Color.clear],
                                center: .center,
                                startRadius: 0,
                                endRadius: 60
                            )
                        )
                        .frame(width: 140, height: 140)
                        .scaleEffect(logoScale)
                    
                    // Logo
                    Image("ロゴ")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 100, height: 100)
                        .cornerRadius(24)
                        .shadow(color: Color.purple.opacity(0.5), radius: 20, x: 0, y: 10)
                        .scaleEffect(logoScale)
                        .opacity(logoOpacity)
                }
                
                // Title
                VStack(spacing: 8) {
                    Image("ITクエスト文字")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 200, height: 50)
                        .opacity(titleOpacity)
                        .offset(y: titleOffset)
                    
                    Text("クイズで楽しく学ぼう")
                        .font(.system(size: 16, weight: .medium, design: .rounded))
                        .foregroundColor(.white.opacity(0.6))
                        .opacity(titleOpacity)
                        .offset(y: titleOffset)
                }
            }
        }
        .onAppear {
            startAnimations()
        }
    }
    
    private func startAnimations() {
        // Logo scale and opacity
        withAnimation(.spring(response: 0.8, dampingFraction: 0.6).delay(0.2)) {
            logoScale = 1.0
            logoOpacity = 1.0
        }
        
        // Ring rotation
        withAnimation(.linear(duration: 20).repeatForever(autoreverses: false)) {
            ringRotation = 360
        }
        
        // Title animation
        withAnimation(.easeOut(duration: 0.6).delay(0.6)) {
            titleOpacity = 1.0
            titleOffset = 0
        }
        
        // Show particles
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            withAnimation {
                showParticles = true
            }
        }
    }
}

// MARK: - Animated Gradient Background
struct AnimatedGradientBackground: View {
    @State private var animateGradient = false
    
    var body: some View {
        LinearGradient(
            colors: animateGradient ?
                [Color(red: 0.1, green: 0.08, blue: 0.2), Color(red: 0.15, green: 0.1, blue: 0.25)] :
                [Color(red: 0.08, green: 0.08, blue: 0.15), Color(red: 0.1, green: 0.08, blue: 0.2)],
            startPoint: animateGradient ? .topLeading : .bottomTrailing,
            endPoint: animateGradient ? .bottomTrailing : .topLeading
        )
        .ignoresSafeArea()
        .onAppear {
            withAnimation(.easeInOut(duration: 4).repeatForever(autoreverses: true)) {
                animateGradient.toggle()
            }
        }
    }
}

// MARK: - Splash Particle View
struct SplashParticleView: View {
    @State private var particles: [SplashParticle] = []
    
    struct SplashParticle: Identifiable {
        let id = UUID()
        var startX: CGFloat
        var startY: CGFloat
        var endY: CGFloat
        var size: CGFloat
        var duration: Double
        var delay: Double
    }
    
    var body: some View {
        GeometryReader { geo in
            ForEach(particles) { particle in
                FloatingParticle(particle: particle, geo: geo)
            }
        }
        .onAppear {
            particles = (0..<15).map { _ in
                SplashParticle(
                    startX: CGFloat.random(in: 0...1),
                    startY: CGFloat.random(in: 0.8...1.2),
                    endY: CGFloat.random(in: -0.2...0.3),
                    size: CGFloat.random(in: 3...8),
                    duration: Double.random(in: 4...8),
                    delay: Double.random(in: 0...2)
                )
            }
        }
    }
}

struct FloatingParticle: View {
    let particle: SplashParticleView.SplashParticle
    let geo: GeometryProxy
    @State private var isFloating = false
    
    var body: some View {
        Circle()
            .fill(
                LinearGradient(
                    colors: [Color.purple.opacity(0.6), Color.cyan.opacity(0.4)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .frame(width: particle.size, height: particle.size)
            .position(
                x: particle.startX * geo.size.width,
                y: isFloating ? particle.endY * geo.size.height : particle.startY * geo.size.height
            )
            .blur(radius: 1)
            .onAppear {
                withAnimation(
                    .easeInOut(duration: particle.duration)
                    .repeatForever(autoreverses: true)
                    .delay(particle.delay)
                ) {
                    isFloating = true
                }
            }
    }
}

// MARK: - Circular Progress Indicator
struct CircularProgressIndicator: View {
    @State private var rotation: Double = 0
    let lineWidth: CGFloat
    let size: CGFloat
    
    init(size: CGFloat = 50, lineWidth: CGFloat = 4) {
        self.size = size
        self.lineWidth = lineWidth
    }
    
    var body: some View {
        ZStack {
            // Background circle
            Circle()
                .stroke(Color.white.opacity(0.1), lineWidth: lineWidth)
                .frame(width: size, height: size)
            
            // Animated arc
            Circle()
                .trim(from: 0, to: 0.7)
                .stroke(
                    AngularGradient(
                        colors: [Color.purple, Color.blue, Color.cyan, Color.purple],
                        center: .center
                    ),
                    style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                )
                .frame(width: size, height: size)
                .rotationEffect(.degrees(rotation))
        }
        .onAppear {
            withAnimation(.linear(duration: 1).repeatForever(autoreverses: false)) {
                rotation = 360
            }
        }
    }
}

// MARK: - Pulse Loading Indicator
struct PulseLoadingIndicator: View {
    @State private var isAnimating = false
    let color: Color
    let size: CGFloat
    
    init(color: Color = .purple, size: CGFloat = 60) {
        self.color = color
        self.size = size
    }
    
    var body: some View {
        ZStack {
            ForEach(0..<3) { i in
                Circle()
                    .stroke(color.opacity(0.5 - Double(i) * 0.15), lineWidth: 2)
                    .frame(width: size, height: size)
                    .scaleEffect(isAnimating ? 1.5 + CGFloat(i) * 0.3 : 1)
                    .opacity(isAnimating ? 0 : 1)
                    .animation(
                        .easeOut(duration: 1.5)
                        .repeatForever(autoreverses: false)
                        .delay(Double(i) * 0.3),
                        value: isAnimating
                    )
            }
            
            Circle()
                .fill(color)
                .frame(width: size * 0.3, height: size * 0.3)
        }
        .onAppear {
            isAnimating = true
        }
    }
}

struct LoadingViewUpdated_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ModernLoadingView()
                .previewDisplayName("Loading View")
            
            ModernSplashScreen()
                .previewDisplayName("Splash Screen")
        }
    }
}

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
