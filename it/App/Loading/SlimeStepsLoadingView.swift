import SwiftUI

/// L2：ステップ付きの進捗ローディング。
/// `currentIndex` は実行中のステップ番号（それより前は完了）。`steps.count` 以上で全完了。
struct SlimeStepsLoadingView: View {
    let steps: [String]
    let currentIndex: Int

    private var progress: CGFloat {
        guard !steps.isEmpty else { return 0 }
        return CGFloat(min(max(currentIndex, 0), steps.count)) / CGFloat(steps.count)
    }

    private var completedCount: Int {
        min(max(currentIndex, 0), steps.count)
    }

    var body: some View {
        ZStack {
            SlimeLoadingTheme.background.ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer(minLength: 24)

                VStack(spacing: 8) {
                    Text("冒険の準備中")
                        .font(SlimeLoadingTheme.heading(30))
                        .foregroundStyle(SlimeLoadingTheme.ink)
                        .accessibilityAddTraits(.isHeader)
                    Text("少しだけ待っててね")
                        .font(SlimeLoadingTheme.body(15, weight: .medium))
                        .foregroundStyle(SlimeLoadingTheme.subInk)
                }

                SlimeProgressTrack(progress: progress)
                    .padding(.top, 48)
                    .accessibilityElement(children: .ignore)
                    .accessibilityLabel("準備の進み具合")
                    .accessibilityValue("\(steps.count)個中\(completedCount)個完了")

                VStack(alignment: .leading, spacing: 14) {
                    ForEach(Array(steps.enumerated()), id: \.offset) { offset, title in
                        SlimeStepRow(title: title, state: state(for: offset))
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.top, 36)

                Spacer(minLength: 24)
                Spacer(minLength: 0)
            }
            .padding(.horizontal, 32)
        }
    }

    private func state(for index: Int) -> SlimeStepState {
        if index < currentIndex { return .done }
        if index == currentIndex { return .active }
        return .pending
    }
}

enum SlimeStepState {
    case done, active, pending

    var accessibilityText: String {
        switch self {
        case .done: return "完了"
        case .active: return "実行中"
        case .pending: return "待機中"
        }
    }
}

/// 進捗バー。塗りの右端に小さく跳ねるスライムが乗り、右端に旗が立つ。
private struct SlimeProgressTrack: View {
    let progress: CGFloat

    private let barHeight: CGFloat = 14
    private let slimeSize: CGFloat = 64
    private let hopHeight: CGFloat = 12

    var body: some View {
        GeometryReader { geometry in
            let width = geometry.size.width
            let barTop = geometry.size.height - barHeight
            let slimeFrameHeight = slimeSize + hopHeight
            // 足元（画像の82%の高さ）がバーの上端に乗るように置く。
            let slimeTop = barTop - (hopHeight + slimeSize * SlimeLoadingTheme.footAnchor.y)
            let slimeX = min(max(width * progress, slimeSize / 2), width - slimeSize / 2)

            ZStack(alignment: .topLeading) {
                Capsule()
                    .fill(SlimeLoadingTheme.border)
                    .frame(width: width, height: barHeight)
                    .offset(y: barTop)

                Capsule()
                    .fill(SlimeLoadingTheme.accent)
                    .frame(width: width * progress, height: barHeight)
                    .offset(y: barTop)

                Image(systemName: "flag.fill")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundStyle(SlimeLoadingTheme.flag)
                    .frame(width: 26, height: 26)
                    .offset(x: width - 24, y: barTop - 28)
                    .accessibilityHidden(true)

                SlimeHopView(size: slimeSize, height: hopHeight)
                    .frame(width: slimeSize, height: slimeFrameHeight)
                    .offset(x: slimeX - slimeSize / 2, y: slimeTop)
            }
        }
        .frame(height: 96)
        .animation(.spring(response: 0.6, dampingFraction: 0.8), value: progress)
    }
}

/// ステップ一覧の1行。
private struct SlimeStepRow: View {
    let title: String
    let state: SlimeStepState

    var body: some View {
        HStack(spacing: 12) {
            SlimeStepIndicator(state: state)
            Text(title)
                .font(SlimeLoadingTheme.body(15, weight: state == .active ? .bold : .medium))
                .foregroundStyle(state == .pending ? SlimeLoadingTheme.subInk.opacity(0.6) : SlimeLoadingTheme.ink)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(title)
        .accessibilityValue(state.accessibilityText)
    }
}

private struct SlimeStepIndicator: View {
    let state: SlimeStepState

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private let side: CGFloat = 24

    var body: some View {
        ZStack {
            switch state {
            case .done:
                ZStack {
                    Circle().fill(SlimeLoadingTheme.accent)
                    Image(systemName: "checkmark")
                        .font(.system(size: 12, weight: .heavy))
                        .foregroundStyle(.white)
                }
                // チェックが付く瞬間に 1.2 → 1 で軽く弾ませる。
                .transition(reduceMotion ? .opacity : .scale(scale: 1.2).combined(with: .opacity))
            case .active:
                SlimeSpinningRing(lineWidth: 3)
                    .transition(.opacity)
            case .pending:
                Circle()
                    .stroke(SlimeLoadingTheme.pending, lineWidth: 3)
                    .transition(.opacity)
            }
        }
        .frame(width: side, height: side)
        .animation(.spring(response: 0.35, dampingFraction: 0.5), value: state)
        .accessibilityHidden(true)
    }
}

/// 実行中を示す回るリング。
private struct SlimeSpinningRing: View {
    var lineWidth: CGFloat
    var period: Double = 0.9

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        ZStack {
            Circle()
                .stroke(SlimeLoadingTheme.border, lineWidth: lineWidth)
            TimelineView(.animation(minimumInterval: nil, paused: reduceMotion)) { context in
                let angle = reduceMotion ? 0 : slimeCyclePhase(context.date, period: period) * 360
                Circle()
                    .trim(from: 0, to: 0.7)
                    .stroke(SlimeLoadingTheme.accent, style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
                    .rotationEffect(.degrees(angle - 90))
            }
        }
        .padding(lineWidth / 2)
    }
}

// MARK: - Previews

#Preview("L2 進捗") {
    SlimeStepsLoadingPreview()
}

/// 1.4秒ごとにステップを進める Preview 用ラッパー。
struct SlimeStepsLoadingPreview: View {
    static let sampleSteps = ["問題データを読み込み", "学習記録を同期", "今日の3問を準備"]

    @State private var currentIndex = 0

    var body: some View {
        SlimeStepsLoadingView(steps: Self.sampleSteps, currentIndex: currentIndex)
            .task {
                while !Task.isCancelled {
                    try? await Task.sleep(nanoseconds: 1_400_000_000)
                    currentIndex = currentIndex >= Self.sampleSteps.count ? 0 : currentIndex + 1
                }
            }
    }
}
