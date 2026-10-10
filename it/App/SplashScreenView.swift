import SwiftUI

private struct SplashFullBleedImage: View {
    let name: String
    let size: CGSize

    var body: some View {
        Image(name)
            .resizable()
            .scaledToFill()
            .frame(width: size.width, height: size.height)
            .clipped()
            .accessibilityHidden(true)
    }
}

/// ロゴ文字の外側に重ねる発光・影の一層分。
struct SplashLogoGlow {
    let color: Color
    let radius: CGFloat
    var y: CGFloat = 0
}

/// スプラッシュ中央の「ITクエスト」文字の見た目パターン。
/// 塗り・縁取り・発光の組み合わせだけが異なる。
enum SplashLogoStyle: String, CaseIterable, Identifiable {
    case goldenNavy
    case cleanWhite
    case treasureBronze
    case magicGlow
    case emeraldQuest
    case sunsetJourney

    static let defaultStyle: SplashLogoStyle = .cleanWhite

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .goldenNavy: return "ゴールド × ネイビー縁取り"
        case .cleanWhite: return "クリーン白抜き"
        case .treasureBronze: return "秘宝ブロンズ"
        case .magicGlow: return "魔法の輝き"
        case .emeraldQuest: return "エメラルドクエスト"
        case .sunsetJourney: return "夕焼けの旅路"
        }
    }

    var spec: String {
        switch self {
        case .goldenNavy: return "クリーム→ゴールドのグラデ / 濃紺の縁取り / 白の外側グロー"
        case .cleanWhite: return "純白フラット / スカイブルーの縁取り / 下方向の影のみ"
        case .treasureBronze: return "生成り→銅色のグラデ / 焦げ茶の縁取り / 硬めの影"
        case .magicGlow: return "白に近い水色フラット / 縁取りなし / シアン〜青の三段グロー"
        case .emeraldQuest: return "白→ミントのグラデ / 深緑の縁取り / 白の外側グロー"
        case .sunsetJourney: return "桃→橙→赤のグラデ / 深紫の縁取り / オレンジの外側グロー"
        }
    }

    /// 文字本体の塗り。
    var fill: AnyShapeStyle {
        switch self {
        case .goldenNavy:
            return AnyShapeStyle(verticalGradient(["fffce6", "ffd652"]))
        case .cleanWhite:
            return AnyShapeStyle(Color.white)
        case .treasureBronze:
            return AnyShapeStyle(verticalGradient(["ffe9bd", "d98a3d", "a85a1e"]))
        case .magicGlow:
            return AnyShapeStyle(Color(hex: "f4fdff"))
        case .emeraldQuest:
            return AnyShapeStyle(verticalGradient(["f4fff9", "bfe9d3"]))
        case .sunsetJourney:
            return AnyShapeStyle(verticalGradient(["ffd9a0", "ff7a45", "ff4d6d"]))
        }
    }

    /// 縁取りの色と太さ。nil なら縁取りなし。
    var outline: (color: Color, width: CGFloat)? {
        switch self {
        case .goldenNavy: return (Color(hex: "0a2966"), 2.6)
        case .cleanWhite: return (Color(hex: "0f5fae"), 2.0)
        case .treasureBronze: return (Color(hex: "4a2410"), 2.6)
        case .magicGlow: return nil
        case .emeraldQuest: return (Color(hex: "0d5a3d"), 2.6)
        case .sunsetJourney: return (Color(hex: "3d1250"), 2.6)
        }
    }

    /// 内側から外側へ順に重ねる発光・影。
    var glows: [SplashLogoGlow] {
        switch self {
        case .goldenNavy:
            return [
                SplashLogoGlow(color: .white.opacity(0.9), radius: 5),
                SplashLogoGlow(color: .blue.opacity(0.28), radius: 12, y: 5)
            ]
        case .cleanWhite:
            return [SplashLogoGlow(color: Color(hex: "09264a").opacity(0.35), radius: 5, y: 4)]
        case .treasureBronze:
            return [SplashLogoGlow(color: .black.opacity(0.3), radius: 3, y: 3)]
        case .magicGlow:
            return [
                SplashLogoGlow(color: Color(hex: "bdf1ff"), radius: 4),
                SplashLogoGlow(color: Color(hex: "6fd8ff").opacity(0.9), radius: 10),
                SplashLogoGlow(color: Color(hex: "2fb6ff").opacity(0.8), radius: 20),
                SplashLogoGlow(color: Color(hex: "062d4f").opacity(0.4), radius: 3, y: 3)
            ]
        case .emeraldQuest:
            return [SplashLogoGlow(color: .white.opacity(0.55), radius: 6)]
        case .sunsetJourney:
            return [SplashLogoGlow(color: Color(hex: "ff8c5a").opacity(0.6), radius: 9)]
        }
    }

    private func verticalGradient(_ hexes: [String]) -> LinearGradient {
        LinearGradient(colors: hexes.map { Color(hex: $0) }, startPoint: .top, endPoint: .bottom)
    }
}

struct SplashLogoText: View {
    let style: SplashLogoStyle
    let maxWidth: CGFloat
    var fontSize: CGFloat = 48

    var body: some View {
        applyGlows(to: layeredLabel)
            .frame(maxWidth: maxWidth)
    }

    private var layeredLabel: some View {
        ZStack {
            if let outline = style.outline {
                let offsets = strokeOffsets(width: outline.width * fontSize / 48)
                ForEach(0..<offsets.count, id: \.self) { index in
                    label
                        .foregroundStyle(outline.color)
                        .offset(offsets[index])
                }
            }

            label
                .foregroundStyle(style.fill)
        }
    }

    private var label: some View {
        Text("ITクエスト")
            .font(.system(size: fontSize, weight: .heavy, design: .rounded))
            .tracking(fontSize / 32)
            .lineLimit(1)
            .minimumScaleFactor(0.4)
    }

    private func strokeOffsets(width: CGFloat) -> [CGSize] {
        let diagonal = width * 0.72
        return [
            CGSize(width: width, height: 0), CGSize(width: -width, height: 0),
            CGSize(width: 0, height: width), CGSize(width: 0, height: -width),
            CGSize(width: diagonal, height: diagonal), CGSize(width: -diagonal, height: -diagonal),
            CGSize(width: diagonal, height: -diagonal), CGSize(width: -diagonal, height: diagonal)
        ]
    }

    /// 層数がパターンごとに違うため、内側から順に shadow を重ねていく。
    private func applyGlows<V: View>(to view: V) -> AnyView {
        let scale = fontSize / 48
        return style.glows.reduce(AnyView(view)) { accumulated, glow in
            AnyView(accumulated.shadow(color: glow.color, radius: glow.radius * scale, x: 0, y: glow.y * scale))
        }
    }
}

private struct SplashCompanionLayer: View {
    let imageName: String
    let canvasSize: CGSize
    let widthRatio: CGFloat
    let maximumWidth: CGFloat
    let position: CGPoint
    let entryOffset: CGSize
    let entryRotation: Double
    let delay: Double
    let floatDistance: CGFloat
    let floatDuration: Double
    let isPresented: Bool
    let isFloating: Bool

    private var imageWidth: CGFloat {
        min(canvasSize.width * widthRatio, maximumWidth)
    }

    var body: some View {
        Image(imageName)
            .resizable()
            .scaledToFit()
            .frame(width: imageWidth)
            .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 7)
            .scaleEffect(isPresented ? 1 : 0.54)
            .rotationEffect(.degrees(isPresented ? 0 : entryRotation))
            .opacity(isPresented ? 1 : 0)
            .offset(
                x: isPresented ? 0 : entryOffset.width,
                y: isPresented ? 0 : entryOffset.height
            )
            .animation(
                .spring(response: 0.64, dampingFraction: 0.68)
                    .delay(delay),
                value: isPresented
            )
            .position(
                x: canvasSize.width * position.x,
                y: canvasSize.height * position.y
            )
            .offset(y: isFloating ? -floatDistance : floatDistance * 0.35)
            .animation(
                .easeInOut(duration: floatDuration)
                    .repeatForever(autoreverses: true)
                    .delay(delay * 0.35),
                value: isFloating
            )
            .accessibilityHidden(true)
    }
}

struct SplashScreenView: View {
    // RootViewとの互換性を保つ。現在の演出（スライム・バウンス）では使わない。
    let party: [String]
    /// 個別のプレビューでロゴの表示パターンを指定するための値。
    let logoStyleOverride: SplashLogoStyle?

    init(party: [String] = [], logoStyleOverride: SplashLogoStyle? = nil) {
        self.party = party
        self.logoStyleOverride = logoStyleOverride
    }

    var body: some View {
        SlimeBounceSplashView()
    }
}

/// 以前の起動演出（背景画像＋仲間5体が飛び込む）。
struct LegacyAdventureSplashView: View {
    // 専用イラスト5体を表示する。
    let party: [String]
    /// 個別のプレビューでロゴの表示パターンを指定するための値。
    let logoStyleOverride: SplashLogoStyle?

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var backgroundAppeared = false
    @State private var magicAppeared = false
    @State private var companionsAppeared = false
    @State private var heroAppeared = false
    @State private var foregroundAppeared = false
    @State private var logoAppeared = false
    @State private var ambientMotion = false

    init(party: [String] = [], logoStyleOverride: SplashLogoStyle? = nil) {
        self.party = party
        self.logoStyleOverride = logoStyleOverride
    }

    private var logoStyle: SplashLogoStyle {
        logoStyleOverride ?? .cleanWhite
    }

    var body: some View {
        GeometryReader { geometry in
            let size = geometry.size

            ZStack {
                Color(red: 0.12, green: 0.58, blue: 0.94)
                    .ignoresSafeArea()

                SplashFullBleedImage(name: "SplashAdventureBackground", size: size)
                    .scaleEffect(backgroundAppeared ? 1.025 : 1.1)
                    .offset(y: ambientMotion ? -3 : 3)
                    .opacity(backgroundAppeared ? 1 : 0.7)
                    .animation(.easeOut(duration: 1.25), value: backgroundAppeared)
                    .animation(
                        .easeInOut(duration: 5.5).repeatForever(autoreverses: true),
                        value: ambientMotion
                    )

                SplashFullBleedImage(name: "SplashMagicTrail", size: size)
                    .blendMode(.screen)
                    .scaleEffect(magicAppeared ? 1.02 : 0.78)
                    .rotationEffect(.degrees(ambientMotion ? 1.2 : -1.2))
                    .opacity(magicAppeared ? (ambientMotion ? 0.96 : 0.78) : 0)
                    .animation(.easeOut(duration: 1.05), value: magicAppeared)
                    .animation(
                        .easeInOut(duration: 3.4).repeatForever(autoreverses: true),
                        value: ambientMotion
                    )

                SplashCompanionLayer(
                    imageName: "SplashCompanionGolem",
                    canvasSize: size,
                    widthRatio: 0.48,
                    maximumWidth: 225,
                    position: CGPoint(x: 0.2, y: 0.24),
                    entryOffset: CGSize(width: -size.width * 0.55, height: -28),
                    entryRotation: -14,
                    delay: 0,
                    floatDistance: 7,
                    floatDuration: 1.9,
                    isPresented: companionsAppeared,
                    isFloating: ambientMotion
                )

                SplashCompanionLayer(
                    imageName: "SplashCompanionFlying",
                    canvasSize: size,
                    widthRatio: 0.7,
                    maximumWidth: 310,
                    position: CGPoint(x: 0.79, y: 0.34),
                    entryOffset: CGSize(width: size.width * 0.62, height: -34),
                    entryRotation: 18,
                    delay: 0.12,
                    floatDistance: 10,
                    floatDuration: 1.6,
                    isPresented: companionsAppeared,
                    isFloating: ambientMotion
                )

                SplashCompanionLayer(
                    imageName: "SplashCompanionFox",
                    canvasSize: size,
                    widthRatio: 0.56,
                    maximumWidth: 245,
                    position: CGPoint(x: 0.2, y: 0.7),
                    entryOffset: CGSize(width: -size.width * 0.5, height: 38),
                    entryRotation: -11,
                    delay: 0.2,
                    floatDistance: 4,
                    floatDuration: 2.1,
                    isPresented: companionsAppeared,
                    isFloating: ambientMotion
                )

                SplashCompanionLayer(
                    imageName: "SplashCompanionDragon",
                    canvasSize: size,
                    widthRatio: 0.58,
                    maximumWidth: 255,
                    position: CGPoint(x: 0.8, y: 0.7),
                    entryOffset: CGSize(width: size.width * 0.5, height: 36),
                    entryRotation: 11,
                    delay: 0.3,
                    floatDistance: 5,
                    floatDuration: 2,
                    isPresented: companionsAppeared,
                    isFloating: ambientMotion
                )

                SplashLogoText(style: logoStyle, maxWidth: min(size.width * 0.72, 320))
                    .scaleEffect(logoAppeared ? 1 : 0.72)
                    .opacity(logoAppeared ? 1 : 0)
                    .position(x: size.width * 0.5, y: size.height * 0.51)
                    .animation(
                        .spring(response: 0.65, dampingFraction: 0.7),
                        value: logoAppeared
                    )
                    .accessibilityLabel("ITクエスト")

                SplashCompanionLayer(
                    imageName: "SplashCompanionSlime",
                    canvasSize: size,
                    widthRatio: 0.9,
                    maximumWidth: 390,
                    position: CGPoint(x: 0.5, y: 0.83),
                    entryOffset: CGSize(width: 0, height: size.height * 0.28),
                    entryRotation: 0,
                    delay: 0,
                    floatDistance: 5,
                    floatDuration: 1.8,
                    isPresented: heroAppeared,
                    isFloating: ambientMotion
                )

                SplashFullBleedImage(name: "SplashAdventureForeground", size: size)
                    .scaleEffect(foregroundAppeared ? 1.015 : 1.08)
                    .offset(y: foregroundAppeared ? (ambientMotion ? 1 : 0) : 28)
                    .opacity(foregroundAppeared ? 1 : 0)
                    .animation(.easeOut(duration: 0.8), value: foregroundAppeared)
                    .animation(
                        .easeInOut(duration: 4.2).repeatForever(autoreverses: true),
                        value: ambientMotion
                    )
            }
            .frame(width: size.width, height: size.height)
            .clipped()
        }
        .ignoresSafeArea()
        .background(Color(red: 0.12, green: 0.58, blue: 0.94))
        .task {
            await startAnimation()
        }
    }

    @MainActor
    private func startAnimation() async {
        if reduceMotion {
            backgroundAppeared = true
            magicAppeared = true
            companionsAppeared = true
            heroAppeared = true
            foregroundAppeared = true
            logoAppeared = true
            return
        }

        backgroundAppeared = true
        try? await Task.sleep(nanoseconds: 160_000_000)
        guard !Task.isCancelled else { return }

        magicAppeared = true
        try? await Task.sleep(nanoseconds: 190_000_000)
        guard !Task.isCancelled else { return }

        companionsAppeared = true
        try? await Task.sleep(nanoseconds: 410_000_000)
        guard !Task.isCancelled else { return }

        heroAppeared = true
        foregroundAppeared = true
        try? await Task.sleep(nanoseconds: 250_000_000)
        guard !Task.isCancelled else { return }

        logoAppeared = true
        try? await Task.sleep(nanoseconds: 650_000_000)
        guard !Task.isCancelled else { return }

        ambientMotion = true
    }
}

struct LegacyAdventureSplashView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            LegacyAdventureSplashView()
                .previewDevice("iPhone SE (3rd generation)")
                .previewDisplayName("iPhone SE")

            LegacyAdventureSplashView()
                .previewDevice("iPhone 15 Pro")
                .previewDisplayName("iPhone 15 Pro")
        }
    }
}
