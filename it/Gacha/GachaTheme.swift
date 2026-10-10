//
//  GachaTheme.swift
//  it
//
//  ガチャ画面共通のデザイントークン（漆黒×金 ＋ Dela Gothic One）。
//  色・フォント・金ボタン・装飾パーツをここに集約し、各ガチャから共通利用する。
//

import SwiftUI
import UIKit

// MARK: - Color Tokens
enum GachaTheme {
    static let background = Color(hex: "0B0A12")
    static let surface = Color(hex: "16131F")
    static let heroTop = Color(hex: "241A35")
    static let heroBottom = Color(hex: "120E1C")
    static let gold = Color(hex: "E2B64A")
    static let goldLight = Color(hex: "F6DF9A")
    static let goldHighlight = Color(hex: "FFF6DA")
    static let text = Color(hex: "F4EEDC")
    static let textMuted = Color(hex: "B3AA92")
    static let line = gold.opacity(0.35)
    static let glow = gold.opacity(0.22)
    static let tagText = Color(hex: "0B0A12")

    /// チップ・カプセル以外の角丸はすべてこの値に揃える。
    static let cornerRadius: CGFloat = 6

    // 金ボタン
    static let goldButtonTop = Color(hex: "FBE8A6")
    static let goldButtonBottom = Color(hex: "B98A24")
    static let goldButtonText = Color(hex: "2A1C04")
    static let goldButtonOutline = Color(hex: "6B4A0E")

    static var goldButtonGradient: LinearGradient {
        LinearGradient(
            stops: [
                .init(color: goldButtonTop, location: 0),
                .init(color: gold, location: 0.48),
                .init(color: goldButtonBottom, location: 1)
            ],
            startPoint: .top,
            endPoint: .bottom
        )
    }

    /// 押せない状態の金ボタン（同じ明暗構成のグレー）。
    static var disabledButtonGradient: LinearGradient {
        LinearGradient(
            stops: [
                .init(color: Color(hex: "8A877F"), location: 0),
                .init(color: Color(hex: "5E5B55"), location: 0.48),
                .init(color: Color(hex: "403E3A"), location: 1)
            ],
            startPoint: .top,
            endPoint: .bottom
        )
    }

    /// 結果カードの枠。
    static var cardFrameGradient: LinearGradient {
        LinearGradient(
            stops: [
                .init(color: goldButtonTop, location: 0),
                .init(color: goldButtonBottom, location: 0.4),
                .init(color: goldButtonTop, location: 0.6),
                .init(color: Color(hex: "8C5F10"), location: 1)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    /// 結果カードの内側。
    static func cardInnerGradient(radius: CGFloat) -> RadialGradient {
        RadialGradient(
            colors: [Color(hex: "3A2A57"), heroBottom],
            center: .center,
            startRadius: 0,
            endRadius: radius
        )
    }

    static var heroGradient: LinearGradient {
        LinearGradient(colors: [heroTop, heroBottom], startPoint: .topLeading, endPoint: .bottomTrailing)
    }
}

// MARK: - Lineup
/// 各ガチャの表示情報。一覧とガチャ画面の両方から参照する。
struct GachaLineupEntry {
    let title: String
    let description: String
    let cost: Int
    /// 一覧で見せるテーマ別のおとも。高レアの排出キャラはここに指定しない。
    let mascotImageName: String
    /// 既存の各ガチャのテーマ色（サムネのグローに使う）。
    let themeColors: [Color]
    let mode: GachaMode
}

extension GachaTheme {
    static let lineup: [GachaLineupEntry] = [
        GachaLineupEntry(title: "レギュラーガチャ", description: "基本のガチャ！毎日挑戦しよう", cost: 300,
                         mascotImageName: "ネッキー",
                         themeColors: [Color(hex: "4ECDC4"), Color(hex: "44A08D")], mode: .normal),
        GachaLineupEntry(title: "幸福ガチャ", description: "幸運のキャラが手に入るかも？", cost: 600,
                         mascotImageName: "幸福のパンダ",
                         themeColors: [Color(hex: "FF6B6B"), Color(hex: "C94B4B")], mode: .rare),
        GachaLineupEntry(title: "メカガチャ", description: "最新メカキャラが登場！", cost: 600,
                         mascotImageName: "メカマウス",
                         themeColors: [Color(hex: "667eea"), Color(hex: "764ba2")], mode: .meka),
        GachaLineupEntry(title: "神ガチャ", description: "最強の神キャラが降臨！", cost: 1000,
                         mascotImageName: "神龍子",
                         themeColors: [Color(hex: "FFD700"), Color(hex: "FF6347")], mode: .god),
        GachaLineupEntry(title: "四聖獣ガチャ", description: "五行を統べる四聖獣が集結！", cost: 1000,
                         mascotImageName: "朱雀の雛 スザク丸",
                         themeColors: [Color(hex: "2E8B57"), Color(hex: "1B4D3E")], mode: .guardian),
        GachaLineupEntry(title: "深海ガチャ", description: "まだ見ぬ海の底で、伝説が目を覚ます。", cost: 1500,
                         mascotImageName: "灯クラゲ ルミ",
                         themeColors: [Color(hex: "36CDE6"), Color(hex: "153C75")], mode: .deepSea)
    ]

    /// lineup と同じ並びの一覧用マスコット画像名。
    static let mascotImageNames: [String] = lineup.map(\.mascotImageName)

    /// 一覧の先頭に PICK UP として出すガチャ（lineup の添字）。ここだけ変えれば切り替わる。
    static let pickupIndex = 5

    static func lineupEntry(title: String) -> GachaLineupEntry? {
        lineup.first { $0.title == title }
    }
}

// MARK: - Fonts
enum GachaFont {
    static let displayName = "DelaGothicOne-Regular"
    static let labelName = "Cinzel-Bold"

    private static let hasDisplay = UIFont(name: displayName, size: 12) != nil
    private static let hasLabel = UIFont(name: labelName, size: 12) != nil

    /// 見出し用の極太ゴシック。ウェイトは Regular のみなので .bold() / .fontWeight を付けないこと。
    static func display(_ size: CGFloat, relativeTo style: Font.TextStyle = .title2) -> Font {
        hasDisplay
            ? .custom(displayName, size: size, relativeTo: style)
            : .system(size: size, weight: .heavy)
    }

    /// 英字ラベル専用（PICK UP / NEW など）。
    static func label(_ size: CGFloat, relativeTo style: Font.TextStyle = .caption) -> Font {
        hasLabel
            ? .custom(labelName, size: size, relativeTo: style)
            : .system(size: size, weight: .bold, design: .serif)
    }

    /// 見出しの標準字間（サイズ×0.06）。
    static func tracking(_ size: CGFloat) -> CGFloat { size * 0.06 }

    #if DEBUG
    /// 登録フォント名の確認用。
    static func logRegisteredFonts() {
        for family in UIFont.familyNames where family.contains("Dela") || family.contains("Cinzel") {
            print("[GachaFont] \(family): \(UIFont.fontNames(forFamilyName: family))")
        }
    }
    #endif
}

// MARK: - Summon Hint
/// 召喚演出でひびから漏れる光の段階。
enum GachaSummonHint: Int, CaseIterable {
    case none
    case blue
    case purple
    case gold
    case rainbow

    var color: Color? {
        switch self {
        case .none: return nil
        case .blue: return Color(hex: "3B82F6")
        case .purple: return Color(hex: "A855F7")
        case .gold: return Color(hex: "F5C542")
        case .rainbow: return Color(hex: "F5C542")
        }
    }

    /// 青から順に、最終段階まで上がっていく途中経過。
    var stages: [GachaSummonHint] {
        GachaSummonHint.allCases.filter { $0 != .none && $0.rawValue <= rawValue }
    }
}

extension GachaRarity {
    /// 召喚演出の予告色。レア度→光の色の対応はここだけで管理する。
    var summonHint: GachaSummonHint {
        switch self {
        case .normal:
            return .none
        case .rare, .Rrare, .mekaRare, .godRare, .guardianRare, .deepSeaRare:
            return .blue
        case .superRare, .RsuperRare, .mekaSuperRare, .godSuperRare, .guardianSuperRare, .deepSeaSuperRare:
            return .purple
        case .ultraRare, .RultraRare, .mekaUltraRare, .godUltraRare, .guardianUltraRare, .deepSeaUltraRare,
             .legendRare, .mekaLegendRare, .godLegendRare, .guardianLegendRare, .deepSeaLegendRare:
            return .gold
        case .godMythicRare, .guardianUltimateRare, .deepSeaUltimateRare:
            return .rainbow
        }
    }

    var summonHintColor: Color? { summonHint.color }
}

// MARK: - Coin Icon
struct GachaCoinIcon: View {
    var size: CGFloat = 20

    var body: some View {
        if UIImage(named: "コイン") != nil {
            Image("コイン")
                .resizable()
                .scaledToFit()
                .frame(width: size, height: size)
                .accessibilityHidden(true)
        } else {
            Circle()
                .fill(
                    RadialGradient(
                        colors: [Color(hex: "FFF1B8"), GachaTheme.gold, Color(hex: "8C5F10")],
                        center: UnitPoint(x: 0.35, y: 0.3),
                        startRadius: 0,
                        endRadius: size * 0.6
                    )
                )
                .frame(width: size, height: size)
                .accessibilityHidden(true)
        }
    }
}

// MARK: - Header Parts
struct GachaBackPill: View {
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 14, weight: .semibold))
                Text("戻る")
                    .font(.system(size: 15, weight: .semibold))
            }
            .foregroundColor(GachaTheme.text)
            .padding(.horizontal, 16)
            .frame(minHeight: 44)
            .background(
                Capsule()
                    .fill(Color.white.opacity(0.06))
                    .overlay(Capsule().stroke(GachaTheme.line, lineWidth: 1))
            )
            .contentShape(Capsule())
        }
        .buttonStyle(ScaleButtonStyle())
        .accessibilityLabel("戻る")
    }
}

struct GachaCoinPill: View {
    let amount: Int?
    var action: (() -> Void)? = nil

    var body: some View {
        if let action {
            Button(action: action) { content }
                .buttonStyle(ScaleButtonStyle())
                .accessibilityLabel("コインを追加")
                .accessibilityValue(amountText)
        } else {
            content
                .accessibilityElement(children: .ignore)
                .accessibilityLabel("保有コイン数")
                .accessibilityValue(amountText)
        }
    }

    private var amountText: String {
        amount.map { "\($0)コイン" } ?? "読み込み中"
    }

    private var content: some View {
        HStack(spacing: 8) {
            GachaCoinIcon(size: 22)

            Group {
                if let amount {
                    Text(amount.formatted())
                        .contentTransition(.numericText())
                } else {
                    ProgressView()
                        .tint(GachaTheme.goldLight)
                        .scaleEffect(0.8)
                }
            }
            .font(.system(size: 16, weight: .bold))
            .monospacedDigit()
            .foregroundColor(GachaTheme.text)
            .lineLimit(1)
            .frame(minWidth: 36)

            if action != nil {
                Image(systemName: "plus")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(GachaTheme.gold)
            }
        }
        .padding(.leading, 8)
        .padding(.trailing, 14)
        .frame(minHeight: 44)
        .background(
            Capsule()
                .fill(Color.black.opacity(0.4))
                .overlay(Capsule().stroke(GachaTheme.gold.opacity(0.5), lineWidth: 1))
        )
        .contentShape(Capsule())
    }
}

/// 見出し左右の金の横線。
struct GachaGoldRule: View {
    var width: CGFloat = 18
    var fadeToTrailing: Bool? = nil

    var body: some View {
        Rectangle()
            .fill(
                LinearGradient(
                    colors: fadeColors,
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .frame(width: width, height: 1)
            .accessibilityHidden(true)
    }

    private var fadeColors: [Color] {
        switch fadeToTrailing {
        case .some(true): return [GachaTheme.gold, GachaTheme.gold.opacity(0)]
        case .some(false): return [GachaTheme.gold.opacity(0), GachaTheme.gold]
        case .none: return [GachaTheme.gold, GachaTheme.gold]
        }
    }
}

/// 金地に黒文字のタグ（PICK UP / NEW / レア度）。
struct GachaTag: View {
    let text: String
    var useLabelFont: Bool = true
    var size: CGFloat = 11

    var body: some View {
        Text(text)
            .font(useLabelFont ? GachaFont.label(size) : .system(size: size, weight: .bold))
            .tracking(useLabelFont ? size * 0.2 : 0.5)
            .foregroundColor(GachaTheme.tagText)
            .lineLimit(1)
            .padding(.horizontal, 7)
            .padding(.vertical, 3)
            .background(RoundedRectangle(cornerRadius: 2).fill(GachaTheme.gold))
    }
}

// MARK: - Gold Button
/// 金ボタンの見た目（グラデ・内側ハイライト/シャドウ・外周線・グロー・光沢）。
struct GachaGoldButtonBackground: View {
    var isEnabled: Bool = true
    var showsShine: Bool = true
    var shinePeriod: Double = 2.8

    var body: some View {
        let shape = RoundedRectangle(cornerRadius: GachaTheme.cornerRadius)

        shape
            .fill(isEnabled ? GachaTheme.goldButtonGradient : GachaTheme.disabledButtonGradient)
            // 上端 1pt の白ハイライト
            .overlay(alignment: .top) {
                Rectangle()
                    .fill(Color.white.opacity(0.7))
                    .frame(height: 1)
                    .padding(.horizontal, 2)
                    .padding(.top, 1)
            }
            // 下端 3pt の内側シャドウ
            .overlay(alignment: .bottom) {
                Rectangle()
                    .fill(Color.black.opacity(0.25))
                    .frame(height: 3)
            }
            .overlay {
                if isEnabled && showsShine {
                    GachaShineSweep(period: shinePeriod, intensity: 0.55)
                }
            }
            .clipShape(shape)
            .overlay(shape.stroke(isEnabled ? GachaTheme.goldButtonOutline : Color.black.opacity(0.5), lineWidth: 1))
            .shadow(color: isEnabled ? GachaTheme.glow : .clear, radius: 26, x: 0, y: 10)
    }
}

// MARK: - Shine
/// 斜めに流れる光沢。Reduce Motion のときは表示しない。
struct GachaShineSweep: View {
    var period: Double = 2.8
    var intensity: Double = 0.4

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var phase: CGFloat = 0

    var body: some View {
        GeometryReader { proxy in
            let width = proxy.size.width
            let band = max(width * 0.35, 60)

            if !reduceMotion {
                LinearGradient(
                    colors: [.clear, Color.white.opacity(intensity), .clear],
                    startPoint: .leading,
                    endPoint: .trailing
                )
                .frame(width: band, height: proxy.size.height * 2)
                .rotationEffect(.degrees(20))
                // 移動距離の後半は画面外にいるので、そのぶんが「間」になる。
                .offset(x: -band * 1.5 + phase * (width * 2 + band * 2), y: -proxy.size.height / 2)
                .onAppear {
                    phase = 0
                    withAnimation(.linear(duration: period).repeatForever(autoreverses: false)) {
                        phase = 1
                    }
                }
            }
        }
        .allowsHitTesting(false)
        .accessibilityHidden(true)
    }
}

// MARK: - Corner Brackets
/// 四隅の L 字装飾。
struct GachaCornerBrackets: Shape {
    var length: CGFloat = 14

    func path(in rect: CGRect) -> Path {
        var path = Path()
        let l = length
        // 左上
        path.move(to: CGPoint(x: rect.minX, y: rect.minY + l))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.minX + l, y: rect.minY))
        // 右上
        path.move(to: CGPoint(x: rect.maxX - l, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY + l))
        // 右下
        path.move(to: CGPoint(x: rect.maxX, y: rect.maxY - l))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.maxX - l, y: rect.maxY))
        // 左下
        path.move(to: CGPoint(x: rect.minX + l, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY - l))
        return path
    }
}

// MARK: - Background Parts
/// 金の放射グロー。
struct GachaRadialGlow: View {
    var color: Color = GachaTheme.gold
    var opacity: Double = 0.22
    var radius: CGFloat = 260

    var body: some View {
        // 親のレイアウト幅を押し広げないよう、可変サイズの透明ビューに重ねて描く
        Color.clear
            .overlay(
                RadialGradient(
                    colors: [color.opacity(opacity), color.opacity(0)],
                    center: .center,
                    startRadius: 0,
                    endRadius: radius
                )
                .frame(width: radius * 2, height: radius * 2)
            )
            .allowsHitTesting(false)
            .accessibilityHidden(true)
    }
}

/// 135° の極細斜線パターン。
struct GachaDiagonalPattern: View {
    var spacing: CGFloat = 14
    var opacity: Double = 0.035

    var body: some View {
        Canvas { context, size in
            var path = Path()
            var x: CGFloat = -size.height
            while x < size.width {
                path.move(to: CGPoint(x: x, y: size.height))
                path.addLine(to: CGPoint(x: x + size.height, y: 0))
                x += spacing
            }
            context.stroke(path, with: .color(GachaTheme.gold.opacity(opacity)), lineWidth: 1)
        }
        .allowsHitTesting(false)
        .accessibilityHidden(true)
    }
}

/// 中心から放射状に伸びる金の細い光線（線 6° ／ すき間 12° の繰り返し）。
struct GachaSunburst: View {
    var rayDegrees: Double = 6
    var gapDegrees: Double = 12
    var color: Color = GachaTheme.goldLight
    var opacity: Double = 0.13

    var body: some View {
        Canvas { context, size in
            let center = CGPoint(x: size.width / 2, y: size.height / 2)
            let radius = hypot(size.width, size.height)
            var path = Path()
            var angle: Double = 0
            while angle < 360 {
                path.move(to: center)
                path.addArc(
                    center: center,
                    radius: radius,
                    startAngle: .degrees(angle),
                    endAngle: .degrees(angle + rayDegrees),
                    clockwise: false
                )
                path.closeSubpath()
                angle += rayDegrees + gapDegrees
            }
            context.fill(path, with: .color(color.opacity(opacity)))
        }
        .allowsHitTesting(false)
        .accessibilityHidden(true)
    }
}

// MARK: - Summoning Circle
/// 正三角形（上向き/下向き）。2つ重ねて六芒星にする。
struct GachaTriangle: Shape {
    var pointingUp: Bool = true

    func path(in rect: CGRect) -> Path {
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let radius = min(rect.width, rect.height) / 2
        var path = Path()
        for i in 0..<3 {
            let base: Double = pointingUp ? -90 : 90
            let angle = (base + Double(i) * 120) * .pi / 180
            let point = CGPoint(x: center.x + radius * cos(angle), y: center.y + radius * sin(angle))
            if i == 0 { path.move(to: point) } else { path.addLine(to: point) }
        }
        path.closeSubpath()
        return path
    }
}

/// 金の召喚陣（基準サイズ 300pt。r150 細線・r142 点線・r118 細線・r110 一点鎖線＋六芒星）。
struct GachaSummoningCircle: View {
    var size: CGFloat = 300
    var isAnimated: Bool = true
    var color: Color = GachaTheme.gold

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var spin = false

    private var scale: CGFloat { size / 300 }

    var body: some View {
        let animate = isAnimated && !reduceMotion

        ZStack {
            Group {
                Circle()
                    .stroke(color.opacity(0.55), lineWidth: 1)
                    .frame(width: 300 * scale, height: 300 * scale)

                Circle()
                    .stroke(color.opacity(0.45), lineWidth: 1)
                    .frame(width: 236 * scale, height: 236 * scale)

                Circle()
                    .stroke(color.opacity(0.4), style: StrokeStyle(lineWidth: 1, dash: [10, 4, 2, 4]))
                    .frame(width: 220 * scale, height: 220 * scale)

                GachaTriangle(pointingUp: true)
                    .stroke(color.opacity(0.4), lineWidth: 1)
                    .frame(width: 236 * scale, height: 236 * scale)

                GachaTriangle(pointingUp: false)
                    .stroke(color.opacity(0.4), lineWidth: 1)
                    .frame(width: 236 * scale, height: 236 * scale)
            }
            .rotationEffect(.degrees(animate && spin ? 360 : 0))
            .animation(animate ? .linear(duration: 40).repeatForever(autoreverses: false) : .default, value: spin)

            // 内側の点線リングは逆回転
            Circle()
                .stroke(color.opacity(0.6), style: StrokeStyle(lineWidth: 1.5, lineCap: .round, dash: [0.5, 6]))
                .frame(width: 284 * scale, height: 284 * scale)
                .rotationEffect(.degrees(animate && spin ? -360 : 0))
                .animation(animate ? .linear(duration: 26).repeatForever(autoreverses: false) : .default, value: spin)
        }
        .frame(width: size, height: size)
        .onAppear { spin = true }
        .allowsHitTesting(false)
        .accessibilityHidden(true)
    }
}

// MARK: - Floating
/// ゆっくり上下させる。Reduce Motion のときは止める。
struct GachaFloatingModifier: ViewModifier {
    var amplitude: CGFloat = 6
    var period: Double = 4

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var up = false

    func body(content: Content) -> some View {
        content
            .offset(y: reduceMotion ? 0 : (up ? -amplitude : amplitude))
            .onAppear {
                guard !reduceMotion else { return }
                withAnimation(.easeInOut(duration: period / 2).repeatForever(autoreverses: true)) {
                    up = true
                }
            }
    }
}

extension View {
    func gachaFloating(amplitude: CGFloat = 6, period: Double = 4) -> some View {
        modifier(GachaFloatingModifier(amplitude: amplitude, period: period))
    }

    /// 金のテキストシャドウ付きの見出し。
    func gachaGoldTextGlow() -> some View {
        shadow(color: GachaTheme.gold.opacity(0.55), radius: 8, x: 0, y: 0)
            .shadow(color: Color.black.opacity(0.6), radius: 0, x: 0, y: 2)
    }
}

// MARK: - Previews
#Preview("Gacha theme parts") {
    ZStack {
        GachaTheme.background.ignoresSafeArea()
        VStack(spacing: 20) {
            HStack {
                GachaBackPill {}
                Spacer()
                GachaCoinPill(amount: 3200) {}
            }
            Text("神ガチャ")
                .font(GachaFont.display(32))
                .tracking(GachaFont.tracking(32))
                .foregroundColor(GachaTheme.goldHighlight)
                .gachaGoldTextGlow()
            GachaSummoningCircle(size: 220)
            HStack { GachaTag(text: "PICK UP"); GachaTag(text: "NEW"); GachaTag(text: "神レア", useLabelFont: false) }
            ZStack {
                GachaGoldButtonBackground()
                Text("召喚する")
                    .font(GachaFont.display(24))
                    .tracking(24 * 0.3)
                    .foregroundColor(GachaTheme.goldButtonText)
            }
            .frame(height: 68)
        }
        .padding(16)
    }
}
