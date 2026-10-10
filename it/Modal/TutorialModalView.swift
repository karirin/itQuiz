import SwiftUI

/// 最初の学習に必要なことだけを伝える。名前登録は体験後に案内する。
struct TutorialModalView: View {
    let onStartPractice: () -> Void
    let onSkip: () -> Void
    var recordsAnalytics = true
    @State private var hasChosenAction = false

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color.black.opacity(0.55)
                    .ignoresSafeArea()

                VStack(spacing: 0) {
                    ScrollView {
                        VStack(spacing: 20) {
                            welcomeArtwork

                            VStack(spacing: 10) {
                                Text("おともと一緒に、\nITの学習をはじめよう")
                                    .font(.title2.bold())
                                    .foregroundStyle(Color("fontGray"))
                                Text("ITパスポートの定番テーマを3問体験。\n時間制限なし。解説を読めば大丈夫です。")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }
                            .multilineTextAlignment(.center)
                            .fixedSize(horizontal: false, vertical: true)

                            VStack(alignment: .leading, spacing: 16) {
                                guideRow(icon: "hand.tap.fill", title: "答えを選んで、解説を読む", detail: "3問で操作に慣れていきましょう。")
                                guideRow(icon: "arrow.counterclockwise", title: "間違えた問題は、あとで復習", detail: "保存した問題は、ホームから復習できます。")
                                guideRow(icon: "sparkles", title: "学ぶほど、おともも成長", detail: "コインを集めて、新しいおともと出会えます。")
                            }
                            .padding(18)
                            .background(Color.blue.opacity(0.06), in: RoundedRectangle(cornerRadius: 18))
                        }
                        .padding(24)
                    }

                    VStack(spacing: 8) {
                        Button {
                            choose(onStartPractice)
                        } label: {
                            Label("まずは3問やってみる", systemImage: "arrow.right.circle.fill")
                                .font(.headline)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .foregroundStyle(.white)
                                .background(
                                    LinearGradient(colors: [Color(hex: "477BE8"), Color(hex: "7560CA")], startPoint: .leading, endPoint: .trailing),
                                    in: RoundedRectangle(cornerRadius: 16)
                                )
                        }
                        .accessibilityIdentifier("onboarding.startPractice")

                        Button {
                            choose(onSkip)
                        } label: {
                            Text("あとで試す・ホームを見る")
                                .font(.subheadline.weight(.semibold))
                                .frame(maxWidth: .infinity, minHeight: 44)
                        }
                        .accessibilityIdentifier("onboarding.skip")

                        Text("名前の登録はあとからできます")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                    .buttonStyle(.plain)
                    .disabled(hasChosenAction)
                    .padding(.horizontal, 24)
                    .padding(.bottom, 20)
                }
                .frame(maxWidth: 440)
                .frame(maxHeight: min(740, max(0, geometry.size.height - 32)))
                .background(Color(.systemBackground), in: RoundedRectangle(cornerRadius: 28))
                .clipShape(RoundedRectangle(cornerRadius: 28))
                .shadow(color: .black.opacity(0.2), radius: 24, y: 12)
                .padding(.horizontal, 16)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .onAppear { if recordsAnalytics { GrowthAnalytics.logOnboardingStart() } }
        .accessibilityAddTraits(.isModal)
    }

    private var welcomeArtwork: some View {
        WelcomeLimeAnimation()
            .frame(maxWidth: .infinity)
            .padding(.vertical, 10)
            .background(
                LinearGradient(colors: [Color.blue.opacity(0.12), Color.purple.opacity(0.07)], startPoint: .topLeading, endPoint: .bottomTrailing),
                in: RoundedRectangle(cornerRadius: 24)
            )
            .accessibilityHidden(true)
    }

    private func guideRow(icon: String, title: String, detail: String) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .font(.body.weight(.semibold))
                .foregroundStyle(.blue)
                .frame(width: 24)
                .accessibilityHidden(true)
            VStack(alignment: .leading, spacing: 4) {
                Text(title).font(.subheadline.bold())
                Text(detail).font(.footnote).foregroundStyle(.secondary)
            }
            .fixedSize(horizontal: false, vertical: true)
        }
    }

    private func choose(_ action: () -> Void) {
        guard !hasChosenAction else { return }
        hasChosenAction = true
        generateHapticFeedback()
        action()
    }
}

/// 呼吸、浮遊、首かしげ、背伸び、小さなジャンプを休みながら繰り返す。
private struct WelcomeLimeAnimation: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var startedAt = Date()

    var body: some View {
        TimelineView(.animation(minimumInterval: 1.0 / 30, paused: reduceMotion)) { context in
            let time = max(0, context.date.timeIntervalSince(startedAt)).truncatingRemainder(dividingBy: 16)
            let pose = reduceMotion ? Pose.rest : Pose.at(time)

            ZStack(alignment: .top) {
                Ellipse()
                    .fill(SlimeLoadingTheme.ink.opacity(0.12))
                    .frame(width: 57, height: 9)
                    .scaleEffect(1 - pose.lift * 0.035)
                    .opacity(1 - pose.lift * 0.04)
                    .position(x: 46 + pose.sway * 0.4, y: 99.4)

                Image("ライム")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 92, height: 92)
                    .scaleEffect(x: pose.scaleX, y: pose.scaleY, anchor: UnitPoint(x: 0.5, y: 0.95))
                    .rotationEffect(.degrees(pose.rotation), anchor: UnitPoint(x: 0.5, y: 0.95))
                    .offset(x: pose.sway, y: 12 - pose.lift)
            }
            .frame(width: 92, height: 104, alignment: .top)
        }
        .frame(width: 92, height: 104)
        .accessibilityHidden(true)
    }

    private struct Pose {
        var scaleX: CGFloat = 1
        var scaleY: CGFloat = 1
        var lift: CGFloat = 0
        var sway: CGFloat = 0
        var rotation: Double = 0

        static let rest = Pose()

        static func at(_ time: Double) -> Pose {
            let breath = pulse(time, from: 0, to: 16)
            let float = pulse(time, from: 1, to: 5)
            let stretch = pulse(time, from: 10.8, to: 12.8)
            let hop = pulse(time, from: 14, to: 15.4)
            let squash = pulse(time, from: 13.5, to: 14)
                + pulse(time, from: 15.4, to: 16)
            let swayProgress = min(1, max(0, (time - 6) / 4))
            let sway = sin(swayProgress * 2 * .pi) * Double(pulse(time, from: 6, to: 10))

            return Pose(
                scaleX: 1 - breath * 0.008 - stretch * 0.035 - hop * 0.02 + squash * 0.045,
                scaleY: 1 + breath * 0.012 + stretch * 0.05 + hop * 0.025 - squash * 0.04,
                lift: float * 7 + hop * 9,
                sway: CGFloat(sway) * 3,
                rotation: sway * 4
            )
        }

        /// 両端の速度をゼロにし、動作と休みをなめらかにつなぐ。
        private static func pulse(_ time: Double, from start: Double, to end: Double) -> CGFloat {
            guard time > start, time < end else { return 0 }
            let wave = sin((time - start) / (end - start) * .pi)
            return CGFloat(wave * wave)
        }
    }
}

struct InitialPracticeHomeCard: View {
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: "book.closed.fill")
                    .font(.title2)
                    .foregroundStyle(.blue)
                VStack(alignment: .leading, spacing: 4) {
                    Text("はじめての3問").font(.headline)
                    Text("ITパスポートの問題で、学習を体験")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Spacer(minLength: 0)
                Image(systemName: "arrow.right.circle.fill")
                    .font(.title2)
                    .foregroundStyle(.blue)
            }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color(.systemBackground).opacity(0.96), in: RoundedRectangle(cornerRadius: 20))
        }
        .buttonStyle(.plain)
        .accessibilityIdentifier("home.initialPractice")
    }
}

func isSmallDevice() -> Bool {
    UIScreen.main.bounds.width < 390
}

#Preview {
    TutorialModalView(onStartPractice: {}, onSkip: {})
}
