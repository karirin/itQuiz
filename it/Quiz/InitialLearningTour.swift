import SwiftUI

/// 画面をまたぐ初回操作案内。既存の Firebase tutorialNum とは独立して、オフラインでも進む。
final class InitialLearningTour: ObservableObject {
    static let shared = InitialLearningTour()
    static let completedKey = "onboarding.hasCompletedLearningTour"

    enum Exit { case home, continueLearning }
    @Published private(set) var progress = InitialLearningTourProgress()
    private(set) var exit: Exit = .home
    private(set) var pendingExit: Exit?

    var step: InitialLearningTourProgress.Step? { progress.step }
    var isActive: Bool { step != nil }
    var hasCompleted: Bool { UserDefaults.standard.bool(forKey: Self.completedKey) }
    var needsPresentation: Bool {
        let defaults = UserDefaults.standard
        return defaults.bool(forKey: "onboarding.offersInitialPractice")
            && defaults.bool(forKey: "growth.analytics.initialDiagnosticCompleted") && !hasCompleted
    }

    func start() {
        guard !hasCompleted else { return }
        exit = .home
        pendingExit = nil
        progress.start()
    }

    func advance(from step: InitialLearningTourProgress.Step) { progress.advance(from: step) }
    func revisit(_ step: InitialLearningTourProgress.Step) { progress.revisit(step) }
    func requestFinish(exit: Exit = .home) { pendingExit = exit }

    func restartAtHome() {
        guard isActive else { return }
        progress.finish()
        progress.start()
    }

    func finish(exit: Exit = .home) {
        guard isActive else { return }
        self.exit = pendingExit ?? exit
        pendingExit = nil
        UserDefaults.standard.set(true, forKey: Self.completedKey)
        progress.finish()
    }
}

enum LearningTourTarget: Hashable { case home, qualification, category, answers }

private struct LearningTourAnchors: PreferenceKey {
    static var defaultValue: [LearningTourTarget: Anchor<CGRect>] = [:]
    static func reduce(value: inout [LearningTourTarget: Anchor<CGRect>], nextValue: () -> [LearningTourTarget: Anchor<CGRect>]) {
        value.merge(nextValue()) { _, new in new }
    }
}

extension View {
    func learningTourTarget(_ target: LearningTourTarget) -> some View {
        anchorPreference(key: LearningTourAnchors.self, value: .bounds) { [target: $0] }
    }

    func learningTourOverlay(step: InitialLearningTourProgress.Step, target: LearningTourTarget? = nil,
                             onSkip: (() -> Void)? = nil, onContinue: (() -> Void)? = nil,
                             onHome: (() -> Void)? = nil) -> some View {
        modifier(LearningTourOverlayModifier(expectedStep: step, target: target,
                                             onSkip: onSkip, onContinue: onContinue, onHome: onHome))
    }
}

private struct LearningTourOverlayModifier: ViewModifier {
    let expectedStep: InitialLearningTourProgress.Step
    let target: LearningTourTarget?
    let onSkip: (() -> Void)?
    let onContinue: (() -> Void)?
    let onHome: (() -> Void)?
    @ObservedObject private var tour = InitialLearningTour.shared

    func body(content: Content) -> some View {
        content.overlayPreferenceValue(LearningTourAnchors.self) { anchors in
            GeometryReader { geometry in
                if tour.step == expectedStep {
                    if let target, let anchor = anchors[target] {
                        SageSpotlight(step: expectedStep, target: geometry[anchor],
                                      onSkip: skip, onContinue: onContinue, onHome: onHome)
                    } else if target == nil {
                        SageSpotlight(step: expectedStep, target: nil,
                                      onSkip: skip, onContinue: onContinue, onHome: onHome)
                    }
                }
            }
        }
    }

    private func skip() {
        if let onSkip { onSkip() } else { tour.finish() }
    }
}

private struct SpotlightOutside: Shape {
    let target: CGRect?
    func path(in rect: CGRect) -> Path {
        var path = Path(rect)
        if let target { path.addRoundedRect(in: target.insetBy(dx: -5, dy: -5), cornerSize: CGSize(width: 20, height: 20)) }
        return path
    }
}

private struct SageSpotlight: View {
    let step: InitialLearningTourProgress.Step
    let target: CGRect?
    let onSkip: () -> Void
    let onContinue: (() -> Void)?
    let onHome: (() -> Void)?
    @State private var cardHeight: CGFloat = 180

    private var number: Int {
        switch step {
        case .home: return 1
        case .qualification: return 2
        case .category: return 3
        case .questionIntroduction, .question: return 4
        case .explanation, .completion: return 5
        }
    }

    private var message: String {
        switch step {
        case .home: return "3問の学習を終えたのう。続いて、学習モードの使い方を案内しよう。『学習モード』を選ぶとよい。"
        case .qualification: return "ここで学ぶ資格を選べるのじゃ。今回は『ITパスポート』を選ぶとよい。"
        case .category: return "学びたい分野を選べるのじゃ。まずは『基礎理解』から、1問解いてみるとしよう。"
        case .questionIntroduction, .question: return "問題を読み、正解と思う選択肢を選ぶとよい。答えたあとは解説で確認できるのじゃ。"
        case .explanation: return "解説で、答えの理由を確かめるとよい。"
        case .completion: return "操作の案内は以上じゃ。次からは、学びたい資格や分野を選んで取り組むとよい。"
        }
    }

    var body: some View {
        GeometryReader { geometry in
            let outside = SpotlightOutside(target: target)
            ZStack(alignment: .top) {
                outside.fill(.black.opacity(0.58), style: FillStyle(eoFill: true))
                    .contentShape(outside, eoFill: true)
                    .onTapGesture { }
                if let target {
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(.white, lineWidth: 3)
                        .frame(width: target.width + 10, height: target.height + 10)
                        .position(x: target.midX, y: target.midY)
                        .allowsHitTesting(false)
                }
                HStack {
                    Text("操作の案内 \(number) / 5")
                        .accessibilityIdentifier("learningTour.step.\(step.rawValue)")
                    Spacer()
                    Button("スキップ", action: onSkip)
                        .frame(minHeight: 44)
                        .accessibilityIdentifier("learningTour.skip")
                }
                .font(.subheadline.weight(.semibold)).foregroundStyle(.white)
                .padding(.horizontal, 24).padding(.top, max(geometry.safeAreaInsets.top, 12))

                VStack(spacing: 12) {
                    RecoveryCompanion(message: message)
                    if step == .questionIntroduction {
                        Button("問題を解く", action: onContinue ?? {})
                            .buttonStyle(RecoveryPrimaryButtonStyle(tint: .theme))
                            .accessibilityIdentifier("learningTour.answer")
                    } else if step == .completion {
                        Button("学習を続ける", action: onContinue ?? {})
                            .buttonStyle(RecoveryPrimaryButtonStyle(tint: .theme))
                            .accessibilityIdentifier("learningTour.continue")
                        Button("ホームへ戻る", action: onHome ?? onSkip)
                            .buttonStyle(RecoveryOutlineButtonStyle(tint: .review))
                            .accessibilityIdentifier("learningTour.home")
                    } else {
                        Text("光っている項目をタップしてください")
                            .font(.caption).foregroundStyle(.white)
                    }
                }
                .frame(width: min(geometry.size.width - 32, 440))
                .background(GeometryReader { card in
                    Color.clear.onAppear { cardHeight = card.size.height }
                        .onChange(of: card.size.height) { cardHeight = $0 }
                })
                .position(x: geometry.size.width / 2, y: cardCenter(in: geometry.size))
            }
        }
    }

    private func cardCenter(in size: CGSize) -> CGFloat {
        guard let target else { return size.height / 2 }
        let above = target.minY - cardHeight / 2 - 18
        let below = target.maxY + cardHeight / 2 + 18
        return above - cardHeight / 2 >= 68 ? above : min(below, size.height - cardHeight / 2 - 20)
    }
}

#if DEBUG
/// 進捗や学習記録を書き換えず、実際の選択肢とスポットライトを確認する。
struct LearningTourAnswersPreview: View {
    @State private var hasStarted = false
    @State private var selected: Int?
    private let question = QuizQuestion(
        id: "learning-tour-answers-preview",
        question: "コンピュータの主記憶装置として使用される、電源が切れるとデータが失われるメモリは何か？",
        choices: ["ROM", "SSD", "HDD", "RAM"],
        correctAnswerIndex: 3,
        explanation: "RAMは、作業中のデータを一時的に保存するメモリです。"
    )

    var body: some View {
        ZStack {
            ReviewGardenBackground()
            InitialPracticeQuestionView(
                question: question, questionIndex: 0, questionCount: 1,
                selectedAnswerIndex: selected, hasAnswered: selected != nil,
                answersDisabled: !hasStarted || selected != nil,
                preservesDisabledAnswerAppearance: !hasStarted,
                onAnswer: { selected = $0 }, onUnknown: {}, onExit: {}
            )
        }
        .overlayPreferenceValue(LearningTourAnchors.self) { anchors in
            GeometryReader { geometry in
                if !hasStarted, let anchor = anchors[.answers] {
                    SageSpotlight(step: .questionIntroduction, target: geometry[anchor],
                                  onSkip: { hasStarted = true }, onContinue: { hasStarted = true }, onHome: nil)
                }
            }
        }
        .preferredColorScheme(.light)
    }
}
#endif
