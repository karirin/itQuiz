import SwiftUI

/// スライム系ローディング（起動スプラッシュと同じ世界観）で共有する色・フォント・定数。
enum SlimeLoadingTheme {
    // MARK: Colors

    /// 画面の背景（ミント）。
    static let background = Color(hex: "EAF7F1")
    /// 本文・見出しの文字。
    static let ink = Color(hex: "1F5E4A")
    /// 補助の文字。
    static let subInk = Color(hex: "46705F")
    /// 枠線。
    static let border = Color(hex: "CBEBDD")
    /// 薄い面（カードの地など）。
    static let surface = Color(hex: "F2FAF6")
    /// ボタン（白文字）。
    static let button = Color(hex: "1F7A5C")
    /// 進捗の塗り・完了チェック。
    static let accent = Color(hex: "2F9E78")
    /// ゴールの旗。
    static let flag = Color(hex: "F2B33D")
    /// スケルトンの面。
    static let skeleton = Color(hex: "E3F3EC")
    /// 汗のしずく。
    static let sweat = Color(hex: "7CC8F0")
    /// まだのステップのリング。
    static let pending = Color(hex: "C4D6CE")

    // MARK: Slime

    /// 起動スプラッシュと同じマスコット画像。
    static let slimeImageName = "SplashCompanionSlime"
    /// 拡大縮小の基準点（画像内の足元）。
    static let footAnchor = UnitPoint(x: 0.5, y: 0.82)

    // MARK: Fonts

    /// 見出し用（Dela Gothic One）。
    static func heading(_ size: CGFloat) -> Font {
        .custom("DelaGothicOne-Regular", size: size)
    }

    /// 本文用（SF Rounded）。
    static func body(_ size: CGFloat, weight: Font.Weight = .bold) -> Font {
        .system(size: size, weight: weight, design: .rounded)
    }
}

/// 0...1 を往復する滑らかな波（0 → 1 → 0）。`phase` は周期に対する位置。
func slimeWave(_ phase: Double) -> Double {
    0.5 - 0.5 * cos(phase * 2 * .pi)
}

/// `TimelineView` の時刻から、指定した周期内での位置（0..<1）を返す。
func slimeCyclePhase(_ date: Date, period: Double, delay: Double = 0) -> Double {
    let time = date.timeIntervalSinceReferenceDate - delay
    let phase = time.truncatingRemainder(dividingBy: period) / period
    return phase < 0 ? phase + 1 : phase
}
