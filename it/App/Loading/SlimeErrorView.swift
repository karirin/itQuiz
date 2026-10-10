import SwiftUI

/// L4：読み込みに失敗したときの表示。つぶれたスライムが汗をかき、再試行ボタンを出す。
struct SlimeErrorView: View {
    var title: String = "つながりませんでした"
    var message: String = "電波のよいところで、もう一度ためしてね。"
    var buttonTitle: String = "もう一度ためす"
    let retry: () -> Void

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private let slimeSize: CGFloat = 140

    var body: some View {
        VStack(spacing: 0) {
            Spacer(minLength: 24)

            TimelineView(.animation(minimumInterval: nil, paused: reduceMotion)) { context in
                illustration(date: context.date)
            }
            .accessibilityHidden(true)

            VStack(spacing: 10) {
                Text(title)
                    .font(SlimeLoadingTheme.heading(26))
                    .foregroundStyle(SlimeLoadingTheme.ink)
                    .multilineTextAlignment(.center)
                    .accessibilityAddTraits(.isHeader)
                Text(message)
                    .font(SlimeLoadingTheme.body(15, weight: .medium))
                    .foregroundStyle(SlimeLoadingTheme.subInk)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(.top, 20)

            Button(action: retry) {
                Text(buttonTitle)
                    .font(SlimeLoadingTheme.body(17))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 54)
                    .background(
                        RoundedRectangle(cornerRadius: 27, style: .continuous)
                            .fill(SlimeLoadingTheme.button)
                            .shadow(color: SlimeLoadingTheme.ink.opacity(0.35), radius: 0, x: 0, y: 4)
                    )
            }
            .buttonStyle(.plain)
            .padding(.top, 32)

            Spacer(minLength: 24)
        }
        .padding(.horizontal, 32)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(SlimeLoadingTheme.background)
    }

    private func illustration(date: Date) -> some View {
        // つぶれた形でゆっくり伸び縮み（2.6秒周期）。
        let squash = reduceMotion ? 0.5 : slimeWave(slimeCyclePhase(date, period: 2.6))
        let scaleX = 1.14 + 0.06 * CGFloat(squash)
        let scaleY = 0.84 - 0.06 * CGFloat(squash)

        // アイコンは左右に ±6度ゆれる。
        let tilt = reduceMotion ? 0 : sin(slimeCyclePhase(date, period: 2.2) * 2 * .pi) * 6

        // 汗のしずくは右上から落ちてフェードする。
        let sweatPhase = reduceMotion ? 0.0 : slimeCyclePhase(date, period: 1.6)
        let fall = CGFloat(min(sweatPhase / 0.8, 1))
        let sweatOpacity = reduceMotion ? 1 : max(0, 1 - sweatPhase / 0.8)

        let feetY = slimeSize * SlimeLoadingTheme.footAnchor.y

        return VStack(spacing: 14) {
            Image(systemName: "wifi.slash")
                .font(.system(size: 30, weight: .bold))
                .foregroundStyle(SlimeLoadingTheme.subInk)
                .rotationEffect(.degrees(tilt))

            ZStack(alignment: .top) {
                Ellipse()
                    .fill(SlimeLoadingTheme.ink.opacity(0.16))
                    .frame(width: slimeSize * 0.78, height: slimeSize * 0.12)
                    .scaleEffect(x: scaleX, y: 1)
                    .position(x: slimeSize / 2, y: feetY)

                Image(SlimeLoadingTheme.slimeImageName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: slimeSize, height: slimeSize)
                    .scaleEffect(x: scaleX, y: scaleY, anchor: SlimeLoadingTheme.footAnchor)

                Image(systemName: "drop.fill")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(SlimeLoadingTheme.sweat)
                    .opacity(sweatOpacity)
                    .position(x: slimeSize * 0.86, y: slimeSize * 0.34 + 22 * fall)
            }
            .frame(width: slimeSize, height: slimeSize)
        }
    }
}

#Preview("L4 エラー") {
    SlimeErrorView(retry: {})
}

#Preview("L4 エラー（カード内）") {
    ScrollView {
        SlimeErrorView(title: "学習記録を読み込めませんでした",
                       message: "通信状況を確認して、もう一度お試しください。",
                       retry: {})
            .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
            .padding(20)
    }
}
