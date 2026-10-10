import SwiftUI

/// 起動スプラッシュ：マスコットのスライムが落ちてきて弾み、ロゴが1文字ずつポップする演出。
/// デプロイメントターゲットが iOS 16 のため keyframeAnimator は使わず、
/// 時刻付きのキューを Task.sleep で待ちながら順に withAnimation で再生する。
struct SlimeBounceSplashView: View {
    private enum Palette {
        static let background = Color(hex: "EAF7F1")
        static let ink = Color(hex: "1F5E4A")
        static let ripple = Color(hex: "5BBF9A")
        static let sparkleGreen = Color(hex: "2F9E78")
        static let sparkleGold = Color(hex: "F2B33D")
    }

    private enum LetterPhase {
        case hidden, overshoot, settled
    }

    private enum SparklePhase {
        case hidden, shown, gone
    }

    private struct SparkleSpec {
        /// スライム中心からの位置（スライム幅に対する比率）。
        let offset: CGPoint
        let size: CGFloat
        let color: Color
    }

    private struct Cue {
        let time: Double
        let animation: Animation?
        let change: () -> Void
    }

    private struct Layout {
        let size: CGSize

        /// iPhone SE など縦の短い端末。
        var isCompact: Bool { size.height < 700 }
        var slimeWidth: CGFloat { min(isCompact ? 160 : 200, size.width * 0.55) }
        /// 幅200ptを基準にした縮尺。影・波紋・キラキラの大きさに掛ける。
        var unit: CGFloat { slimeWidth / 200 }
        var slimeCenter: CGPoint { CGPoint(x: size.width / 2, y: size.height * 0.44) }
        /// 画像内の足元（拡大縮小の基準点と同じ高さ）。
        var feetY: CGFloat { slimeCenter.y + slimeWidth * (SlimeBounceSplashView.slimeAnchor.y - 0.5) }
        var logoFontSize: CGFloat { min(isCompact ? 44 : 52, (size.width - 48) / 6.2) }
    }

    private static let slimeAnchor = UnitPoint(x: 0.5, y: 0.82)
    private static let logoLetters = Array("ITクエスト").map(String.init)
    private static let sparkles: [SparkleSpec] = [
        SparkleSpec(offset: CGPoint(x: -0.58, y: -0.30), size: 22, color: Palette.sparkleGreen),
        SparkleSpec(offset: CGPoint(x: 0.60, y: -0.40), size: 26, color: Palette.sparkleGold),
        SparkleSpec(offset: CGPoint(x: -0.62, y: 0.18), size: 18, color: Palette.sparkleGold),
        SparkleSpec(offset: CGPoint(x: 0.58, y: 0.10), size: 20, color: Palette.sparkleGreen)
    ]

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    @State private var slimeOffsetY: CGFloat = -560
    @State private var slimeScale = CGSize(width: 0.92, height: 1.12)
    @State private var shadowScale: CGFloat = 0.3
    @State private var shadowOpacity: Double = 0
    @State private var rippleScale: CGFloat = 0.5
    @State private var rippleOpacity: Double = 0
    @State private var sparklePhases = Array(repeating: SparklePhase.hidden, count: sparkles.count)
    @State private var letterPhases = Array(repeating: LetterPhase.hidden, count: logoLetters.count)
    @State private var subtitleVisible = false
    @State private var isBreathing = false
    @State private var dotsBouncing = false

    var body: some View {
        GeometryReader { geometry in
            let layout = Layout(size: geometry.size)

            ZStack {
                Palette.background

                landingRipple(layout)
                groundShadow(layout)

                ForEach(Self.sparkles.indices, id: \.self) { index in
                    sparkle(Self.sparkles[index], phase: sparklePhases[index], layout: layout)
                }

                slime(layout)

                VStack(spacing: layout.isCompact ? 8 : 12) {
                    logo(layout)
                    subtitle
                }
                .padding(.top, layout.feetY + (layout.isCompact ? 14 : 20))
                .frame(width: layout.size.width, height: layout.size.height, alignment: .top)

                loadingDots
                    .position(x: layout.size.width / 2, y: layout.size.height - 96)
            }
            .frame(width: layout.size.width, height: layout.size.height)
            .clipped()
        }
        .ignoresSafeArea()
        .background(Palette.background.ignoresSafeArea())
        .onAppear {
            if reduceMotion {
                showFinalState()
            }
        }
        .task {
            await playIntro()
        }
    }

    // MARK: - Parts

    private func slime(_ layout: Layout) -> some View {
        Image("SplashCompanionSlime")
            .resizable()
            .scaledToFit()
            .frame(width: layout.slimeWidth, height: layout.slimeWidth)
            .scaleEffect(x: slimeScale.width, y: slimeScale.height, anchor: Self.slimeAnchor)
            .scaleEffect(x: isBreathing ? 1.04 : 1, y: isBreathing ? 0.96 : 1, anchor: Self.slimeAnchor)
            .offset(y: slimeOffsetY)
            .position(layout.slimeCenter)
            .accessibilityHidden(true)
    }

    private func groundShadow(_ layout: Layout) -> some View {
        Ellipse()
            .fill(Palette.ink.opacity(0.18))
            .frame(width: 140 * layout.unit, height: 24 * layout.unit)
            .scaleEffect(shadowScale)
            .opacity(shadowOpacity)
            .position(x: layout.slimeCenter.x, y: layout.feetY)
            .accessibilityHidden(true)
    }

    private func landingRipple(_ layout: Layout) -> some View {
        Ellipse()
            .stroke(Palette.ripple, lineWidth: 3)
            .frame(width: 200 * layout.unit, height: 60 * layout.unit)
            .scaleEffect(rippleScale)
            .opacity(rippleOpacity)
            .position(x: layout.slimeCenter.x, y: layout.feetY)
            .accessibilityHidden(true)
    }

    private func sparkle(_ spec: SparkleSpec, phase: SparklePhase, layout: Layout) -> some View {
        let side = spec.size * layout.unit
        let scale: CGFloat
        switch phase {
        case .hidden: scale = 0.2
        case .shown: scale = 1.2
        case .gone: scale = 0.9
        }

        return SparkleCross()
            .stroke(spec.color, style: StrokeStyle(lineWidth: 2.4, lineCap: .round))
            .frame(width: side, height: side)
            .scaleEffect(scale)
            .rotationEffect(.degrees(phase == .hidden ? 0 : 45))
            .opacity(phase == .shown ? 1 : 0)
            .position(
                x: layout.slimeCenter.x + spec.offset.x * layout.slimeWidth,
                y: layout.slimeCenter.y + spec.offset.y * layout.slimeWidth
            )
            .accessibilityHidden(true)
    }

    private func logo(_ layout: Layout) -> some View {
        HStack(spacing: 1) {
            ForEach(Self.logoLetters.indices, id: \.self) { index in
                let phase = letterPhases[index]

                Text(Self.logoLetters[index])
                    .font(.custom("DelaGothicOne-Regular", fixedSize: layout.logoFontSize))
                    .foregroundStyle(Palette.ink)
                    .shadow(color: Palette.ink.opacity(0.18), radius: 0, x: 0, y: 4)
                    .scaleEffect(phase == .hidden ? 0.5 : (phase == .overshoot ? 1.15 : 1))
                    .offset(y: phase == .hidden ? 24 : (phase == .overshoot ? -10 : 0))
                    .opacity(phase == .hidden ? 0 : 1)
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("ITクエスト")
        .accessibilityAddTraits(.isHeader)
    }

    private var subtitle: some View {
        Text("IT資格を、ぼうけんで。")
            .font(.system(size: 16, weight: .bold, design: .rounded))
            .tracking(2)
            .foregroundStyle(Palette.ink)
            .offset(y: subtitleVisible ? 0 : 8)
            .opacity(subtitleVisible ? 1 : 0)
    }

    private var loadingDots: some View {
        HStack(spacing: 10) {
            ForEach(0..<3, id: \.self) { index in
                Circle()
                    .fill(Palette.ripple)
                    .frame(width: 10, height: 10)
                    .offset(y: dotsBouncing ? -10 : 0)
                    .animation(
                        dotsBouncing
                            ? .easeInOut(duration: 0.5)
                                .repeatForever(autoreverses: true)
                                .delay(Double(index) * 0.15)
                            : nil,
                        value: dotsBouncing
                    )
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("読み込み中")
    }

    // MARK: - Timeline

    @MainActor
    private func playIntro() async {
        guard !reduceMotion else { return }

        dotsBouncing = true
        let start = ContinuousClock.now
        for cue in introCues() {
            try? await Task.sleep(until: start + .seconds(cue.time), clock: .continuous)
            guard !Task.isCancelled else { return }
            withAnimation(cue.animation) {
                cue.change()
            }
        }
    }

    private func introCues() -> [Cue] {
        var cues: [Cue] = [
            // 0.0–0.8s 落下。縦長のまま加速して落ちる。
            Cue(time: 0, animation: .easeIn(duration: 0.8)) {
                slimeOffsetY = 0
                shadowScale = 0.85
                shadowOpacity = 0.6
            },
            // 0.8s 着地。つぶれて影が濃くなり、波紋が広がる。
            Cue(time: 0.8, animation: .easeOut(duration: 0.1)) {
                slimeScale = CGSize(width: 1.28, height: 0.68)
                shadowScale = 1.15
                shadowOpacity = 1
            },
            Cue(time: 0.8, animation: .linear(duration: 0.05)) {
                rippleOpacity = 0.9
            },
            Cue(time: 0.85, animation: .easeOut(duration: 0.75)) {
                rippleScale = 1.9
                rippleOpacity = 0
            },
            // 0.92–1.2s 大きく跳ねる。
            Cue(time: 0.92, animation: .easeOut(duration: 0.28)) {
                slimeOffsetY = -70
                slimeScale = CGSize(width: 0.9, height: 1.12)
                shadowScale = 0.7
                shadowOpacity = 0.55
            },
            Cue(time: 1.2, animation: .easeIn(duration: 0.2)) {
                slimeOffsetY = 0
                slimeScale = CGSize(width: 0.96, height: 1.05)
                shadowScale = 1
                shadowOpacity = 1
            },
            // 1.4s 2回目の着地。
            Cue(time: 1.4, animation: .easeOut(duration: 0.08)) {
                slimeScale = CGSize(width: 1.12, height: 0.88)
                shadowScale = 1.08
            },
            // 1.48–1.62s 小さく跳ねる。
            Cue(time: 1.48, animation: .easeOut(duration: 0.14)) {
                slimeOffsetY = -18
                slimeScale = CGSize(width: 0.97, height: 1.04)
                shadowScale = 0.9
                shadowOpacity = 0.85
            },
            Cue(time: 1.62, animation: .easeIn(duration: 0.12)) {
                slimeOffsetY = 0
                shadowScale = 1
                shadowOpacity = 1
            },
            // 1.74s〜 元の形に落ち着く。
            Cue(time: 1.74, animation: .spring(response: 0.3, dampingFraction: 0.6)) {
                slimeScale = CGSize(width: 1, height: 1)
            },
            // 1.8–2.2s サブコピー。
            Cue(time: 1.8, animation: .easeOut(duration: 0.4)) {
                subtitleVisible = true
            },
            // 2.2s〜 待機ループ（息をする）。
            Cue(time: 2.2, animation: .easeInOut(duration: 1.25).repeatForever(autoreverses: true)) {
                isBreathing = true
            }
        ]

        // 0.85s〜 キラキラを0.12秒ずつずらして出し、すぐ消す。
        for index in Self.sparkles.indices {
            let appear = 0.85 + Double(index) * 0.12
            cues.append(Cue(time: appear, animation: .easeOut(duration: 0.3)) {
                sparklePhases[index] = .shown
            })
            cues.append(Cue(time: appear + 0.3, animation: .easeIn(duration: 0.35)) {
                sparklePhases[index] = .gone
            })
        }

        // 1.0s〜 ロゴを1文字ずつ0.07秒ずらしてポップイン。
        for index in Self.logoLetters.indices {
            let pop = 1.0 + Double(index) * 0.07
            cues.append(Cue(time: pop, animation: .easeOut(duration: 0.16)) {
                letterPhases[index] = .overshoot
            })
            cues.append(Cue(time: pop + 0.16, animation: .spring(response: 0.35, dampingFraction: 0.55)) {
                letterPhases[index] = .settled
            })
        }

        return cues.sorted { $0.time < $1.time }
    }

    /// 視差効果を減らす設定のときに使う最終状態（待機ループなし）。
    private func showFinalState() {
        slimeOffsetY = 0
        slimeScale = CGSize(width: 1, height: 1)
        shadowScale = 1
        shadowOpacity = 1
        rippleOpacity = 0
        sparklePhases = sparklePhases.map { _ in .gone }
        letterPhases = letterPhases.map { _ in .settled }
        subtitleVisible = true
    }
}

/// キラキラ用の細い十字。
private struct SparkleCross: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.midX, y: rect.maxY))
        path.move(to: CGPoint(x: rect.minX, y: rect.midY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.midY))
        return path
    }
}

#Preview("iPhone SE") {
    SlimeBounceSplashView()
        .previewDevice("iPhone SE (3rd generation)")
}

#Preview("iPhone 15 Pro") {
    SlimeBounceSplashView()
        .previewDevice("iPhone 15 Pro")
}
