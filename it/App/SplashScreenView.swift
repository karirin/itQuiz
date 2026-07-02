import SwiftUI
import UIKit
import Combine

// パーティクルエフェクト
struct ParticleEmitterView: UIViewRepresentable {
    func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: .zero)
        let emitter = CAEmitterLayer()
        emitter.emitterPosition = CGPoint(x: UIScreen.main.bounds.width / 2, y: UIScreen.main.bounds.height / 2)
        emitter.emitterShape = .circle
        emitter.emitterSize = CGSize(width: 100, height: 100)

        let cell = CAEmitterCell()
        cell.birthRate = 12
        cell.lifetime = 5.0
        cell.velocity = 80
        cell.velocityRange = 40
        cell.emissionRange = .pi * 2
        cell.scale = 0.05
        cell.scaleRange = 0.03
        cell.alphaSpeed = -0.2
        cell.contents = UIImage(systemName: "sparkle")?.cgImage
        cell.color = UIColor.white.cgColor

        emitter.emitterCells = [cell]
        view.layer.addSublayer(emitter)
        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {}
}

struct SplashScreenView: View {
    @State private var logoScale: CGFloat = 0.6
    @State private var logoOpacity = 0.0
    @State private var titleOpacity = 0.0
    @State private var titleOffset: CGFloat = 16
    @State private var glowPulse = false
    @State private var dotPhase = 0

    private let dotCount = 3
    private let dotTimer = Timer.publish(every: 0.35, on: .main, in: .common).autoconnect()

    var body: some View {
        ZStack {
            // ブランドグラデーション背景
            AppTheme.primaryGradient
                .ignoresSafeArea()

            // 装飾サークル
            GeometryReader { geo in
                Circle()
                    .fill(Color.white.opacity(0.08))
                    .frame(width: 280, height: 280)
                    .offset(x: -90, y: -60)

                Circle()
                    .fill(Color.white.opacity(0.06))
                    .frame(width: 220, height: 220)
                    .offset(x: geo.size.width - 110, y: geo.size.height - 240)
            }
            .ignoresSafeArea()

            VStack(spacing: 28) {
                // ロゴ
                ZStack {
                    // グロー
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [Color.white.opacity(0.35), Color.white.opacity(0)],
                                center: .center,
                                startRadius: 20,
                                endRadius: 110
                            )
                        )
                        .frame(width: 220, height: 220)
                        .scaleEffect(glowPulse ? 1.1 : 0.95)

                    Image("ロゴ")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 110, height: 110)
                        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 24, style: .continuous)
                                .stroke(Color.white.opacity(0.4), lineWidth: 1)
                        )
                        .shadow(color: Color.black.opacity(0.25), radius: 16, x: 0, y: 8)
                }
                .scaleEffect(logoScale)
                .opacity(logoOpacity)

                // タイトル
                Image("ITクエスト文字")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 190)
                    .opacity(titleOpacity)
                    .offset(y: titleOffset)

                // ローディングドット
                HStack(spacing: 8) {
                    ForEach(0..<dotCount, id: \.self) { index in
                        Circle()
                            .fill(Color.white)
                            .frame(width: 8, height: 8)
                            .opacity(dotPhase == index ? 1.0 : 0.35)
                            .scaleEffect(dotPhase == index ? 1.2 : 1.0)
                    }
                }
                .opacity(titleOpacity)
                .padding(.top, 8)
            }

            // パーティクル
            ParticleEmitterView()
                .blendMode(.screen)
                .ignoresSafeArea()
                .allowsHitTesting(false)
        }
        .onAppear {
            // ロゴのバウンス登場
            withAnimation(.interpolatingSpring(stiffness: 120, damping: 12).delay(0.1)) {
                logoScale = 1.0
                logoOpacity = 1.0
            }

            // グローのパルス
            withAnimation(.easeInOut(duration: 1.4).repeatForever(autoreverses: true)) {
                glowPulse = true
            }

            // タイトルのフェードイン
            withAnimation(.easeOut(duration: 0.6).delay(0.6)) {
                titleOpacity = 1.0
                titleOffset = 0
            }
        }
        .onReceive(dotTimer) { _ in
            withAnimation(.easeInOut(duration: 0.25)) {
                dotPhase = (dotPhase + 1) % dotCount
            }
        }
    }
}

struct SplashScreenView_Previews: PreviewProvider {
    static var previews: some View {
        SplashScreenView()
    }
}
