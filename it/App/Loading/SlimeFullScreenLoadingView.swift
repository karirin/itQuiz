import SwiftUI

/// L1：全画面のローディング。跳ねるスライム＋文言＋IT豆知識カード。
struct SlimeFullScreenLoadingView: View {
    var message: String = "よみこみ中"

    var body: some View {
        ZStack {
            SlimeLoadingTheme.background.ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer(minLength: 24)

                VStack(spacing: 20) {
                    SlimeHopView(size: 160, height: 46)
                    SlimeLoadingMessage(message: message)
                }

                Spacer(minLength: 24)

                SlimeTipCard()
                    .padding(.horizontal, 24)
                    .padding(.bottom, 64)
            }
        }
    }
}

/// 「よみこみ中...」の文言。点は3つが0.2秒ずつずれて明滅する。
struct SlimeLoadingMessage: View {
    let message: String
    var font: Font = SlimeLoadingTheme.body(17)

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        HStack(spacing: 0) {
            Text(message)
            TimelineView(.animation(minimumInterval: nil, paused: reduceMotion)) { context in
                HStack(spacing: 0) {
                    ForEach(0..<3, id: \.self) { index in
                        Text(".")
                            .opacity(dotOpacity(index: index, date: context.date))
                    }
                }
            }
        }
        .font(font)
        .foregroundStyle(SlimeLoadingTheme.ink)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(message)
    }

    private func dotOpacity(index: Int, date: Date) -> Double {
        guard !reduceMotion else { return 1 }
        let wave = slimeWave(slimeCyclePhase(date, period: 1.2, delay: Double(index) * 0.2))
        return 0.25 + 0.75 * wave
    }
}

/// 下部の「IT豆知識」カード。4秒ごとに豆知識を切り替える。
struct SlimeTipCard: View {
    @State private var tips = SlimeLoadingTips.pick()
    @State private var index = 0

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 6) {
                Image(systemName: "lightbulb")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundStyle(SlimeLoadingTheme.flag)
                    .accessibilityHidden(true)
                Text("IT豆知識")
                    .font(SlimeLoadingTheme.heading(14))
                    .foregroundStyle(SlimeLoadingTheme.ink)
                    .accessibilityAddTraits(.isHeader)
            }

            ZStack(alignment: .topLeading) {
                Text(tips[index])
                    .font(SlimeLoadingTheme.body(14, weight: .medium))
                    .foregroundStyle(SlimeLoadingTheme.subInk)
                    .lineSpacing(4)
                    .lineLimit(3)
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .id(index)
                    .transition(tipTransition)
            }
            .frame(minHeight: 66, alignment: .topLeading)

            HStack(spacing: 6) {
                ForEach(tips.indices, id: \.self) { dot in
                    Capsule()
                        .fill(dot == index ? SlimeLoadingTheme.accent : SlimeLoadingTheme.border)
                        .frame(width: dot == index ? 18 : 6, height: 6)
                }
            }
            .frame(maxWidth: .infinity)
            .accessibilityHidden(true)
        }
        .padding(18)
        .background(Color.white, in: RoundedRectangle(cornerRadius: 22, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .stroke(SlimeLoadingTheme.border, lineWidth: 2)
        )
        .accessibilityElement(children: .combine)
        .task {
            guard tips.count > 1 else { return }
            while !Task.isCancelled {
                try? await Task.sleep(nanoseconds: 4_000_000_000)
                guard !Task.isCancelled else { return }
                withAnimation(.easeInOut(duration: 0.35)) {
                    index = (index + 1) % tips.count
                }
            }
        }
    }

    private var tipTransition: AnyTransition {
        if reduceMotion {
            return .opacity
        }
        return .asymmetric(
            insertion: .opacity.combined(with: .offset(y: 6)),
            removal: .opacity
        )
    }
}

/// ローディング中に出す豆知識。既存の問題の解説文から短いものを選ぶ。
enum SlimeLoadingTips {
    static let fallback = [
        "1バイトは8ビット。0と1の組み合わせで256通りを表せるよ。",
        "HTTPSの「S」はSecure（セキュア）の頭文字。通信が暗号化されているしるし。",
        "「バグ」の語源には、コンピュータに入りこんだ蛾（ガ）の逸話が残っているよ。"
    ]

    /// 解説文の最初の1文のうち、カードに収まる長さのもの。
    private static let pool: [String] = {
        var seen = Set<String>()
        return ITPassportQuestionBank.all.compactMap { question in
            let trimmed = question.explanation.trimmingCharacters(in: .whitespacesAndNewlines)
            guard let sentence = trimmed.split(separator: "。").first else { return nil }
            let tip = sentence.trimmingCharacters(in: .whitespacesAndNewlines) + "。"
            guard (16...72).contains(tip.count), seen.insert(tip).inserted else { return nil }
            return tip
        }
    }()

    static func pick(count: Int = 5) -> [String] {
        guard !pool.isEmpty else { return fallback }
        return Array(pool.shuffled().prefix(count))
    }
}

#Preview("L1 全画面") {
    SlimeFullScreenLoadingView()
}

#Preview("L1 豆知識カード") {
    SlimeTipCard()
        .padding(24)
        .frame(maxHeight: .infinity)
        .background(SlimeLoadingTheme.background)
}
