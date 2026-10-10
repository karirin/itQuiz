import SwiftUI

// MARK: - L3 画面内パーツ

/// カードの中で使うローディング。跳ねるスライム＋文言。
struct SlimeCardLoadingView: View {
    let message: String

    var body: some View {
        VStack(spacing: 10) {
            SlimeHopView(size: 64, height: 18)
            Text(message)
                .font(SlimeLoadingTheme.body(15))
                .foregroundStyle(SlimeLoadingTheme.ink)
                .multilineTextAlignment(.center)
        }
        .padding(.horizontal, 16)
        .frame(maxWidth: .infinity)
        .frame(height: 168)
        .background(SlimeLoadingTheme.surface, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(SlimeLoadingTheme.border, lineWidth: 1.5)
        )
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(message)
    }
}

/// 行の中で使うローディング。小さいスライム＋文言を横並び。
struct SlimeInlineLoadingView: View {
    let message: String

    var body: some View {
        HStack(spacing: 10) {
            SlimeBobView(size: 30, amplitude: 6, period: 0.6)
                .padding(.top, 6)
            Text(message)
                .font(SlimeLoadingTheme.body(14))
                .foregroundStyle(SlimeLoadingTheme.ink)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 8)
        .background(SlimeLoadingTheme.surface, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(message)
    }
}

/// リストの形を保ったまま読み込み中を示すスケルトン。
struct SlimeSkeletonList: View {
    var rows: Int = 3
    var accessibilityMessage: String = "読み込み中"

    var body: some View {
        VStack(spacing: 10) {
            ForEach(0..<max(rows, 0), id: \.self) { _ in
                SlimeSkeletonRow()
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(accessibilityMessage)
    }
}

private struct SlimeSkeletonRow: View {
    var body: some View {
        HStack(spacing: 12) {
            Circle()
                .frame(width: 44, height: 44)

            GeometryReader { geometry in
                VStack(alignment: .leading, spacing: 9) {
                    Capsule()
                        .frame(width: geometry.size.width * 0.6, height: 12)
                    Capsule()
                        .frame(width: geometry.size.width * 0.36, height: 10)
                }
                .frame(maxHeight: .infinity, alignment: .center)
            }
            .frame(height: 44)

            RoundedRectangle(cornerRadius: 7, style: .continuous)
                .frame(width: 44, height: 24)
        }
        .foregroundStyle(SlimeLoadingTheme.skeleton)
        .slimeShimmer()
        .padding(14)
        .background(Color.white, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(SlimeLoadingTheme.border, lineWidth: 1)
        )
    }
}

/// 左から右へ光が流れるシマー。形の部分だけが光る。
private struct SlimeShimmerModifier: ViewModifier {
    var period: Double = 1.4

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    func body(content: Content) -> some View {
        if reduceMotion {
            content
        } else {
            content.overlay(
                TimelineView(.animation) { context in
                    GeometryReader { geometry in
                        let width = geometry.size.width
                        let band = max(width * 0.45, 80)
                        let phase = slimeCyclePhase(context.date, period: period)
                        LinearGradient(
                            colors: [.white.opacity(0), .white.opacity(0.75), .white.opacity(0)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                        .frame(width: band)
                        .offset(x: -band + (width + band) * CGFloat(phase))
                    }
                }
                .mask(content)
                .allowsHitTesting(false)
            )
        }
    }
}

extension View {
    fileprivate func slimeShimmer() -> some View {
        modifier(SlimeShimmerModifier())
    }
}

// MARK: - ボタンの読み込み中表示

/// ボタンのラベルを白い「•」3つに置き換える。
/// 使い方：`Button { … } label: { Text("保存する").slimeLoading(isLoading: isSaving) }`
/// 押せないようにするのは呼び出し側で `.disabled(isSaving)` を付ける。
struct SlimeButtonLoadingModifier: ViewModifier {
    let isLoading: Bool
    var dotColor: Color = .white
    var message: String = "読み込み中"

    func body(content: Content) -> some View {
        content
            .opacity(isLoading ? 0 : 1)
            .accessibilityHidden(isLoading)
            .overlay {
                if isLoading {
                    SlimeBouncingDots(color: dotColor)
                        .accessibilityElement(children: .ignore)
                        .accessibilityLabel(message)
                }
            }
    }
}

extension View {
    func slimeLoading(isLoading: Bool, dotColor: Color = .white, message: String = "読み込み中") -> some View {
        modifier(SlimeButtonLoadingModifier(isLoading: isLoading, dotColor: dotColor, message: message))
    }
}

/// 0.15秒ずつずれて上下に跳ねる3つの点。
struct SlimeBouncingDots: View {
    var color: Color = .white
    var dotSize: CGFloat = 8
    var amplitude: CGFloat = 6
    var period: Double = 0.6

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        TimelineView(.animation(minimumInterval: nil, paused: reduceMotion)) { context in
            HStack(spacing: dotSize * 0.75) {
                ForEach(0..<3, id: \.self) { index in
                    Circle()
                        .fill(color)
                        .frame(width: dotSize, height: dotSize)
                        .offset(y: offset(index: index, date: context.date))
                }
            }
        }
        .frame(height: dotSize + amplitude * 2)
    }

    private func offset(index: Int, date: Date) -> CGFloat {
        guard !reduceMotion else { return 0 }
        let wave = slimeWave(slimeCyclePhase(date, period: period, delay: Double(index) * 0.15))
        return amplitude - amplitude * 2 * CGFloat(wave)
    }
}

// MARK: - Previews

#Preview("L3 カード") {
    SlimeCardLoadingView(message: "学習記録を読み込み中")
        .padding(20)
        .background(Color.white)
}

#Preview("L3 インライン") {
    SlimeInlineLoadingView(message: "今日の3問を準備中…")
        .padding(20)
}

#Preview("L3 スケルトン") {
    SlimeSkeletonList(rows: 4)
        .padding(16)
        .frame(maxHeight: .infinity, alignment: .top)
        .background(Color(red: 0.96, green: 0.96, blue: 0.98))
}

#Preview("L3 ボタン") {
    SlimeButtonLoadingPreview()
}

private struct SlimeButtonLoadingPreview: View {
    @State private var isLoading = true

    var body: some View {
        VStack(spacing: 16) {
            Button {
                isLoading.toggle()
            } label: {
                Text("保存する")
                    .font(SlimeLoadingTheme.body(16))
                    .foregroundStyle(.white)
                    .slimeLoading(isLoading: isLoading)
                    .frame(maxWidth: .infinity, minHeight: 48)
                    .background(SlimeLoadingTheme.button, in: Capsule())
            }
            .buttonStyle(.plain)

            Toggle("読み込み中", isOn: $isLoading)
        }
        .padding(24)
    }
}
