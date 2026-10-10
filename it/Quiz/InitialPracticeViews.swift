import SwiftUI

private enum FirstLearningStyle {
    static let ink = Color(hex: "23364D")
    static let blue = Color(hex: "477BE8")
    static let green = Color(hex: "287C64")
    static let background = LinearGradient(
        colors: [Color(hex: "EEF4FF"), Color(hex: "FAF8F2")],
        startPoint: .top, endPoint: .bottom
    )
}

struct InitialPracticeQuestionView: View {
    let question: QuizQuestion
    let questionIndex: Int
    let questionCount: Int
    let selectedAnswerIndex: Int?
    var hasAnswered = false
    let answersDisabled: Bool
    var preservesDisabledAnswerAppearance = false
    let onAnswer: (Int) -> Void
    let onUnknown: () -> Void
    let onExit: () -> Void
    @State private var remainingSeconds = 0

    var body: some View {
        ReviewExerciseContent(
            question: question,
            questionIndex: questionIndex,
            questionCount: questionCount,
            selectedAnswerIndex: selectedAnswerIndex,
            hasAnswered: hasAnswered,
            answersDisabled: answersDisabled,
            preservesDisabledAnswerAppearance: preservesDisabledAnswerAppearance,
            showsTimer: false,
            remainingSeconds: $remainingSeconds,
            leadingButtonSymbol: "house.fill",
            leadingButtonLabel: "いったんホームへ",
            leadingButtonIdentifier: "onboarding.pausePractice",
            onSettings: onExit,
            onAnswer: onAnswer,
            onUnknown: onUnknown
        )
    }
}

struct InitialPracticeExplanationCard: View {
    let question: QuizQuestion
    let selectedAnswerIndex: Int?
    let isLastQuestion: Bool
    var isLearningTour = false
    let onContinue: () -> Void

    private var isCorrect: Bool { selectedAnswerIndex == question.correctAnswerIndex }

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color.black.opacity(0.45).ignoresSafeArea()
                VStack(spacing: 0) {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 18) {
                            if isLearningTour {
                                RecoveryCompanion(message: "解説で、答えの理由を確かめるとよい。読み終えたら『案内を終える』を選ぶのじゃ。")
                            }
                            Label(isCorrect ? "正解" : "解説で確認", systemImage: isCorrect ? "checkmark.circle.fill" : "lightbulb.fill")
                                .font(.title2.bold()).foregroundStyle(FirstLearningStyle.green)
                            Text(question.choices[question.correctAnswerIndex])
                                .font(.headline).foregroundStyle(FirstLearningStyle.ink)
                                .padding(16).frame(maxWidth: .infinity, alignment: .leading)
                                .background(FirstLearningStyle.green.opacity(0.08), in: RoundedRectangle(cornerRadius: 16))
                            Text(question.explanation)
                                .font(.system(size: 16)).foregroundStyle(FirstLearningStyle.ink)
                                .lineSpacing(5).fixedSize(horizontal: false, vertical: true)
                        }
                        .padding(24)
                    }
                    Button(isLearningTour ? "案内を終える" : (isLastQuestion ? "今日の学びを確認する" : "次の問題へ"), action: onContinue)
                        .buttonStyle(FirstLearningButtonStyle())
                        .padding(.horizontal, 24).padding(.bottom, 24)
                        .accessibilityIdentifier("onboarding.continueExplanation")
                }
                .frame(maxWidth: 500, maxHeight: min(650, geometry.size.height - 32))
                .background(.white, in: RoundedRectangle(cornerRadius: 28))
                .padding(.horizontal, 18)
                .accessibilityAddTraits(.isModal)
            }
        }
    }
}

struct InitialPracticeCompletionView: View {
    let correctCount: Int
    let questionCount: Int
    let plan: InitialLearningPlan
    let onContinue: () -> Void
    var continueTitle = "ホームの使い方を見る"

    var body: some View {
        ZStack {
            FirstLearningStyle.background.ignoresSafeArea()
            ScrollView {
                VStack(spacing: 14) {
                    Text("DAY 1  ·  今日の学習は完了")
                        .font(.caption.bold()).tracking(1)
                        .foregroundStyle(FirstLearningStyle.green)
                        .padding(.horizontal, 16).padding(.vertical, 9)
                        .background(FirstLearningStyle.green.opacity(0.08), in: Capsule())

                    ZStack(alignment: .bottomTrailing) {
                        Circle().fill(.white.opacity(0.75)).frame(width: 88, height: 88)
                        Image("ネッキー").resizable().scaledToFit().frame(width: 82, height: 88)
                        Image(systemName: "checkmark.seal.fill").font(.system(size: 26))
                            .foregroundStyle(FirstLearningStyle.green).background(.white, in: Circle())
                    }
                    .accessibilityHidden(true)

                    VStack(spacing: 8) {
                        Text("はじめの一歩、できました")
                            .font(.system(size: 27, weight: .bold)).foregroundStyle(FirstLearningStyle.ink)
                        Text("\(questionCount)問を最後まで学びました。")
                            .font(.subheadline).foregroundStyle(.secondary)
                    }
                    .multilineTextAlignment(.center)

                    VStack(alignment: .leading, spacing: 14) {
                        HStack {
                            Label("今日、触れたこと", systemImage: "book.closed.fill")
                            Spacer()
                            Text("正解 \(correctCount) / \(questionCount)").foregroundStyle(.secondary)
                        }.font(.subheadline.bold())
                        ForEach(InitialPracticeContent.learningTopics, id: \.self) { topic in
                            Label(topic, systemImage: "checkmark.circle.fill")
                                .font(.subheadline).foregroundStyle(FirstLearningStyle.green)
                        }
                    }
                    .padding(20).frame(maxWidth: .infinity, alignment: .leading)
                    .background(.white, in: RoundedRectangle(cornerRadius: 22))

                    FirstLearningNextDayCard(plan: plan)

                }
                .padding(20).frame(maxWidth: 560).frame(maxWidth: .infinity)
            }
            .safeAreaInset(edge: .bottom, spacing: 0) {
                VStack(spacing: 8) {
                    Button(continueTitle, action: onContinue)
                        .buttonStyle(FirstLearningButtonStyle())
                        .accessibilityIdentifier("onboarding.finishPractice")
                    Text("今日はここまででも大丈夫。少しずつ続けよう。")
                        .font(.caption).foregroundStyle(.secondary)
                }
                .padding(.horizontal, 24).padding(.vertical, 12)
                .frame(maxWidth: 560).frame(maxWidth: .infinity)
                .background(Color(hex: "FAF8F2"))
            }
        }
    }
}

struct FirstLearningNextDayCard: View {
    let plan: InitialLearningPlan

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Label("DAY 2  ·  明日のおすすめ", systemImage: "sun.max.fill")
                .font(.caption.bold()).foregroundStyle(FirstLearningStyle.blue)
            Text(plan.nextLearningTitle).font(.headline).foregroundStyle(FirstLearningStyle.ink)
            Text(plan.nextLearningMessage).font(.subheadline).foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(20).frame(maxWidth: .infinity, alignment: .leading)
        .background(FirstLearningStyle.blue.opacity(0.07), in: RoundedRectangle(cornerRadius: 22))
    }
}

struct FirstLearningReminderCard: View {
    let plan: InitialLearningPlan
    @Binding var hour: Int
    let isRequesting: Bool
    let canEnableNotifications: Bool
    var errorMessage: String? = nil
    let onEnable: () -> Void
    let onSkip: () -> Void

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color.black.opacity(0.45).ignoresSafeArea()
                VStack(spacing: 0) {
                    ScrollView {
                        VStack(spacing: 18) {
                            Image(systemName: "sun.max.fill").font(.system(size: 32))
                                .foregroundStyle(Color(hex: "E4AA45"))
                                .frame(width: 70, height: 70)
                                .background(Color(hex: "FFF4D9"), in: Circle())
                            VStack(spacing: 8) {
                                Text("明日も、少しだけ。")
                                    .font(.system(size: 25, weight: .bold)).foregroundStyle(FirstLearningStyle.ink)
                                Text("学習しやすい時間に、\n明日のきっかけをお届けします。\nその後は火曜・金曜に、週2回のお誘いを。")
                                    .font(.subheadline).foregroundStyle(.secondary)
                            }.multilineTextAlignment(.center)
                            FirstLearningNextDayCard(plan: plan)
                            VStack(alignment: .leading, spacing: 10) {
                                Label("お知らせする時間", systemImage: "clock")
                                    .font(.subheadline.bold()).foregroundStyle(FirstLearningStyle.ink)
                                Picker("お知らせする時間", selection: $hour) {
                                    ForEach(6...23, id: \.self) { value in
                                        Text(String(format: "%02d:00", value)).tag(value)
                                    }
                                }
                                .pickerStyle(.wheel).frame(height: 105).clipped()
                                .accessibilityIdentifier("onboarding.reminderHour")
                                .disabled(isRequesting || !canEnableNotifications)
                            }
                            if let errorMessage {
                                Text(errorMessage).font(.footnote).foregroundStyle(.red)
                                    .fixedSize(horizontal: false, vertical: true)
                            } else if !canEnableNotifications {
                                Text("通知はオフになっています。あとからiPhoneの設定で許可できます。")
                                    .font(.footnote).foregroundStyle(.secondary)
                            }
                        }.padding(24)
                    }
                    VStack(spacing: 4) {
                        if canEnableNotifications {
                            Button(isRequesting ? "設定しています…" : "明日の\(String(format: "%02d:00", hour))にお知らせ", action: onEnable)
                                .buttonStyle(FirstLearningButtonStyle())
                                .disabled(isRequesting)
                                .accessibilityIdentifier("onboarding.allowReminder")
                        }
                        Button(canEnableNotifications ? "通知なしで続ける" : "ホームへ進む", action: onSkip)
                            .font(.subheadline.weight(.semibold)).foregroundStyle(.secondary)
                            .frame(maxWidth: .infinity, minHeight: 44).disabled(isRequesting)
                            .accessibilityIdentifier("onboarding.skipReminder")
                        Text("通知はあとから変更できます")
                            .font(.caption2).foregroundStyle(.secondary)
                    }
                    .padding(.horizontal, 24).padding(.bottom, 20)
                }
                .frame(maxWidth: 500, maxHeight: min(760, geometry.size.height - 24))
                .background(.white, in: RoundedRectangle(cornerRadius: 28))
                .padding(.horizontal, 18)
            }
        }
        .accessibilityAddTraits(.isModal)
    }
}

struct FirstLearningButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label.font(.system(size: 16, weight: .bold)).foregroundStyle(.white)
            .frame(maxWidth: .infinity, minHeight: 54)
            .padding(.horizontal, 12)
            .background(LinearGradient(colors: [FirstLearningStyle.blue, Color(hex: "6B69CE")], startPoint: .leading, endPoint: .trailing), in: RoundedRectangle(cornerRadius: 17))
            .opacity(configuration.isPressed ? 0.8 : 1)
    }
}

#Preview("初回の結果") {
    InitialPracticeCompletionView(correctCount: 2, questionCount: 3,
                                  plan: InitialLearningPlan(completedAt: Date(), incorrectCount: 1), onContinue: {})
}
