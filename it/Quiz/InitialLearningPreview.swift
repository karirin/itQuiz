#if DEBUG
import SwiftUI

/// 本番と同じ画面部品を使う、記録・通知を送信しない操作プレビュー。
struct InitialLearningPreview: View {
    let onClose: (() -> Void)?
    @State private var phase: Int
    @State private var index = 0
    @State private var selected: Int?
    @State private var correctCount: Int
    @State private var showsExplanation = false
    @State private var hour = 20
    @State private var phaseAfterNameRegistration = 4
    init(startsAtResult: Bool = false, onClose: (() -> Void)? = nil) {
        self.onClose = onClose
        _phase = State(initialValue: startsAtResult ? 2 : 0)
        _correctCount = State(initialValue: startsAtResult ? 2 : 0)
    }

    private func restart() {
        index = 0
        correctCount = 0
        selected = nil
        showsExplanation = false
        hour = 20
        phaseAfterNameRegistration = 4
        phase = 0
    }

    private var plan: InitialLearningPlan {
        InitialLearningPlan(completedAt: Date(), incorrectCount: 3 - correctCount)
    }

    var body: some View {
        ZStack {
            Color(hex: "EEF4FF").ignoresSafeArea()
            switch phase {
            case 0:
                TutorialModalView(onStartPractice: { phase = 1 }, onSkip: {
                    phaseAfterNameRegistration = 5
                    phase = 3
                }, recordsAnalytics: false)
            case 1:
                ReviewGardenBackground()
                InitialPracticeQuestionView(
                    question: InitialPracticeContent.questions[index], questionIndex: index,
                    questionCount: 3, selectedAnswerIndex: selected, hasAnswered: showsExplanation,
                    answersDisabled: showsExplanation,
                    onAnswer: { answer in
                        guard !showsExplanation else { return }
                        selected = answer
                        if answer == InitialPracticeContent.questions[index].correctAnswerIndex { correctCount += 1 }
                        showsExplanation = true
                    }, onUnknown: {
                        guard !showsExplanation else { return }
                        selected = nil
                        showsExplanation = true
                    }, onExit: { phase = 5 }
                )
                if showsExplanation {
                    InitialPracticeExplanationCard(
                        question: InitialPracticeContent.questions[index], selectedAnswerIndex: selected,
                        isLastQuestion: index == 2,
                        onContinue: {
                            showsExplanation = false
                            selected = nil
                            if index == 2 { phase = 2 } else { index += 1 }
                        }
                    )
                }
            case 2:
                InitialPracticeCompletionView(correctCount: correctCount, questionCount: 3,
                    plan: plan, onContinue: { phase = 3 }, continueTitle: "次へ進む")
            case 3:
                ChangeNameView(
                    isPresented: Binding(get: { phase == 3 }, set: { if !$0 { phase = phaseAfterNameRegistration } }),
                    isReturnBtn: .constant(true), tutorialNum: .constant(0), authManager: AuthManager.shared,
                    isInitialRegistration: true,
                    saveName: { _, completion in completion(true) }
                )
            case 4:
                FirstLearningReminderCard(plan: plan, hour: $hour, isRequesting: false,
                    canEnableNotifications: true, errorMessage: nil,
                    onEnable: { phase = 5 }, onSkip: { phase = 5 })
            default:
                VStack(spacing: 22) {
                    Image("ネッキー").resizable().scaledToFit().frame(height: 150)
                    Text("今日はここまで。\n明日も少しずつ学ぼう！").font(.title2.bold()).multilineTextAlignment(.center)
                    Text("確認用プレビュー：学習記録・通知は送信しません").font(.footnote).foregroundStyle(.secondary)
                    Button("最初からもう一度", action: restart)
                        .buttonStyle(FirstLearningButtonStyle())
                        .accessibilityIdentifier("onboarding.preview.restartFromEnd")
                }.padding(24)
            }
        }
        .safeAreaInset(edge: .top, spacing: 0) {
            if let onClose {
                HStack {
                    Button("最初から", action: restart)
                        .accessibilityIdentifier("onboarding.preview.restart")
                    Spacer()
                    Text("初回体験の確認").font(.subheadline.bold())
                    Spacer()
                    Button("閉じる", action: onClose)
                        .accessibilityIdentifier("onboarding.preview.close")
                }
                .font(.subheadline)
                .padding(.horizontal, 20).frame(minHeight: 48)
                .background(Color(hex: "EEF4FF"))
            }
        }
        .safeAreaInset(edge: .bottom, spacing: 0) {
            Text("初回学習の操作プレビュー")
                .font(.system(size: 10)).foregroundStyle(.secondary)
                .frame(maxWidth: .infinity).padding(.vertical, 3)
                .background(Color(hex: "EEF4FF"))
        }
        .preferredColorScheme(.light)
    }
}
#endif
