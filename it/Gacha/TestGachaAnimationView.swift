//
//  TestGachaAnimationView.swift
//  it
//
//  Created by Apple on 2025/12/14.
//

import SwiftUI

struct TestGachaAnimationView: View {
    let rarity: TestRarity?
    let onFinished: () -> Void
    
    @State private var scale: CGFloat = 0.5
    @State private var rotation: Double = 0
    @State private var opacity: Double = 0
    @State private var showRays: Bool = false
    @State private var particleOpacity: Double = 0
    
    var body: some View {
        ZStack {
            // 背景グラデーション（レアリティに応じた色）
            LinearGradient(
                gradient: Gradient(colors: rarity?.gradientColors ?? [.gray, .gray]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            // 放射状の光線エフェクト
            if showRays {
                ForEach(0..<12) { index in
                    Rectangle()
                        .fill(
                            LinearGradient(
                                colors: [.white.opacity(0.8), .white.opacity(0)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: 400, height: 8)
                        .offset(x: 200)
                        .rotationEffect(.degrees(Double(index) * 30 + rotation))
                        .opacity(opacity)
                }
            }
            
            // パーティクル効果
            ForEach(0..<30, id: \.self) { index in
                Circle()
                    .fill(Color.white)
                    .frame(width: CGFloat.random(in: 4...12))
                    .position(
                        x: CGFloat.random(in: 0...UIScreen.main.bounds.width),
                        y: CGFloat.random(in: 0...UIScreen.main.bounds.height)
                    )
                    .opacity(particleOpacity)
            }
            
            // 中央の卵または宝箱アイコン
            ZStack {
                // 外側の輝き
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                .white.opacity(0.6),
                                .white.opacity(0.3),
                                .clear
                            ],
                            center: .center,
                            startRadius: 50,
                            endRadius: 150
                        )
                    )
                    .frame(width: 300, height: 300)
                    .scaleEffect(scale)
                    .opacity(opacity)
                
                // 卵またはアイコン
                Image(systemName: "sparkles")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 120, height: 120)
                    .foregroundColor(.white)
                    .scaleEffect(scale)
                    .rotationEffect(.degrees(rotation))
                    .opacity(opacity)
            }
            
            // レアリティテキスト
            VStack {
                Spacer()
                Text(rarity?.displayString ?? "")
                    .font(.system(size: 48, weight: .bold))
                    .foregroundColor(.white)
                    .shadow(color: .black.opacity(0.5), radius: 10)
                    .scaleEffect(scale)
                    .opacity(opacity)
                    .padding(.bottom, 100)
            }
        }
        .onAppear {
            startAnimation()
        }
    }
    
    private func startAnimation() {
        // フェーズ1: フェードイン + スケールアップ (0-0.5秒)
        withAnimation(.easeOut(duration: 0.5)) {
            opacity = 1.0
            scale = 1.0
        }
        
        // フェーズ2: 光線表示 (0.3秒後)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            showRays = true
            withAnimation(.linear(duration: 2.0).repeatForever(autoreverses: false)) {
                rotation = 360
            }
        }
        
        // フェーズ3: パーティクル表示 (0.5秒後)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            withAnimation(.easeIn(duration: 0.3)) {
                particleOpacity = 0.8
            }
        }
        
        // フェーズ4: パルスエフェクト (1秒後)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            withAnimation(.easeInOut(duration: 0.3).repeatCount(3, autoreverses: true)) {
                scale = 1.1
            }
        }
        
        // アニメーション終了 (2.5秒後)
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
            withAnimation(.easeOut(duration: 0.3)) {
                opacity = 0
                scale = 1.2
            }
            
            // 完全に消えてから結果画面へ
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                onFinished()
            }
        }
    }
}
