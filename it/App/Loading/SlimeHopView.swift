import SwiftUI

/// スライムがその場で跳ね続ける共通部品。
/// デプロイメントターゲットが iOS 16 のため keyframeAnimator は使わず、
/// TimelineView の時刻から1周期（0.9秒）内の姿勢を計算して描く。
struct SlimeHopView: View {
    /// スライム画像の一辺。
    let size: CGFloat
    /// 跳ねる高さ（最高点での上方向の移動量）。
    let height: CGFloat
    var period: Double = 0.9
    var imageName: String = SlimeLoadingTheme.slimeImageName
    var footAnchor: UnitPoint = SlimeLoadingTheme.footAnchor

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        TimelineView(.animation(minimumInterval: nil, paused: reduceMotion)) { context in
            let pose = reduceMotion
                ? SlimeHopPose.rest
                : SlimeHopPose.at(slimeCyclePhase(context.date, period: period))
            hop(pose)
        }
        // 跳ねる分の高さもレイアウトに含め、上の要素に重ならないようにする。
        .frame(width: size, height: size + height)
        .accessibilityHidden(true)
    }

    private func hop(_ pose: SlimeHopPose) -> some View {
        let feetY = height + size * footAnchor.y

        return ZStack(alignment: .top) {
            Ellipse()
                .fill(SlimeLoadingTheme.ink.opacity(0.16))
                .frame(width: size * 0.62, height: size * 0.11)
                .scaleEffect(1 - 0.4 * pose.lift)
                .opacity(1 - 0.5 * pose.lift)
                .position(x: size / 2, y: feetY)

            Image(imageName)
                .resizable()
                .scaledToFit()
                .frame(width: size, height: size)
                .scaleEffect(x: pose.scaleX, y: pose.scaleY, anchor: footAnchor)
                .offset(y: height - height * pose.lift)
        }
        .frame(width: size, height: size + height, alignment: .top)
    }
}

/// 跳ねる1周期のある瞬間の姿勢。
struct SlimeHopPose {
    var scaleX: CGFloat
    var scaleY: CGFloat
    /// 0 = 接地、1 = 最高点。
    var lift: CGFloat

    static let rest = SlimeHopPose(scaleX: 1, scaleY: 1, lift: 0)

    /// 伸び縮みのキーフレーム（周期に対する位置, scaleX, scaleY）。
    private static let scaleKeyframes: [(time: Double, x: CGFloat, y: CGFloat)] = [
        (0, 1.15, 0.85),     // つぶれ
        (0.15, 0.92, 1.1),   // 伸び
        (0.5, 0.98, 1.03),   // 最高点
        (0.85, 0.95, 1.06),  // 着地前
        (1, 1.15, 0.85)      // つぶれに戻る
    ]

    static func at(_ phase: Double) -> SlimeHopPose {
        var scaleX: CGFloat = 1
        var scaleY: CGFloat = 1
        for (from, to) in zip(scaleKeyframes, scaleKeyframes.dropFirst()) where phase <= to.time {
            let progress = (phase - from.time) / (to.time - from.time)
            let eased = CGFloat(progress * progress * (3 - 2 * progress))
            scaleX = from.x + (to.x - from.x) * eased
            scaleY = from.y + (to.y - from.y) * eased
            break
        }

        // 上りは減速、下りは加速する放物線。
        let lift: Double
        if phase < 0.5 {
            let progress = phase / 0.5
            lift = 1 - (1 - progress) * (1 - progress)
        } else {
            let progress = (phase - 0.5) / 0.5
            lift = 1 - progress * progress
        }

        return SlimeHopPose(scaleX: scaleX, scaleY: scaleY, lift: CGFloat(lift))
    }
}

/// 小さなスライムが上下にふわふわ往復する部品（インライン表示・進捗バー用）。
struct SlimeBobView: View {
    let size: CGFloat
    var amplitude: CGFloat = 6
    var period: Double = 0.6

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        TimelineView(.animation(minimumInterval: nil, paused: reduceMotion)) { context in
            let wave = reduceMotion ? 0 : slimeWave(slimeCyclePhase(context.date, period: period))
            Image(SlimeLoadingTheme.slimeImageName)
                .resizable()
                .scaledToFit()
                .frame(width: size, height: size)
                .offset(y: -amplitude * CGFloat(wave))
        }
        .frame(width: size, height: size)
        .accessibilityHidden(true)
    }
}

#Preview("SlimeHopView") {
    HStack(alignment: .bottom, spacing: 32) {
        SlimeHopView(size: 160, height: 46)
        SlimeHopView(size: 64, height: 18)
        SlimeBobView(size: 30)
    }
    .padding(32)
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(SlimeLoadingTheme.background)
}
