import SwiftUI

/// 復習画面の修行庭園。端末の現地時刻で背景を選ぶ。
enum ReviewGardenPeriod {
    case morning, day, dusk, night

    init(hour: Int) {
        switch hour {
        case 5..<11: self = .morning
        case 11..<17: self = .day
        case 17..<20: self = .dusk
        default: self = .night
        }
    }

    var backgroundImageName: String {
        switch self {
        case .morning: return "ReviewGardenMorningBackground"
        case .day: return "ReviewGardenDayBackground"
        case .dusk: return "ReviewGardenDuskBackground"
        case .night: return "ReviewGardenNightBackground"
        }
    }
}


enum ReviewUnansweredReason: String {
    case unknown = "わからない"
    case timedOut = "時間切れ"

    var systemImage: String {
        self == .unknown ? "questionmark.circle.fill" : "timer"
    }
}

#if DEBUG
/// Firebaseのテストデータ投入なしで、通常の復習フローを確認する。
struct ReviewExercisePreview: View {
    @State private var isPresenting = true
    @StateObject private var interstitial = Interstitial()

    private let questions = [
        QuizQuestion(
            id: "review-ui-preview-1",
            question: "バックアップを取る主な目的はどれ？",
            choices: ["失ったデータを復元する", "画面を明るくする", "通信速度を上げる", "文字を大きくする"],
            correctAnswerIndex: 0,
            explanation: "別の場所にデータのコピーを保存し、故障や誤操作で失ったデータを復元できるようにします。"
        ),
        QuizQuestion(
            id: "review-ui-preview-2",
            question: "RAMの主な役割はどれ？",
            choices: ["画像を印刷する", "作業中のデータを一時的に保存する", "電源を供給する", "通信を暗号化する"],
            correctAnswerIndex: 1,
            explanation: "RAMは、プログラムの実行に必要なデータを一時的に置く作業場所です。電源を切ると内容は失われます。"
        ),
        QuizQuestion(
            id: "review-ui-preview-3",
            question: "アカウントを安全に管理する方法はどれ？",
            choices: ["パスワードを使い回す", "誕生日を使う", "サービスごとに異なるパスワードを使う", "友達と共有する"],
            correctAnswerIndex: 2,
            explanation: "異なるパスワードを使うことで、一つのサービスで情報が漏れても、別のサービスへの不正アクセスを防ぎやすくなります。"
        )
    ]

    var body: some View {
        QuizView(
            quizzes: questions,
            quizLevel: .incorrectAnswer,
            authManager: AuthManager.shared,
            audioManager: AudioManager.shared,
            isPresenting: $isPresenting,
            interstitial: interstitial
        )
    }
}
#endif

/// 今回の出題数を母数にする。正解数や保存済みの誤答数には依存しない。
struct ReviewQuestionProgressView: View {
    let questionIndex: Int
    let questionCount: Int

    private var questionNumber: Int {
        min(max(questionIndex + 1, 0), questionCount)
    }

    var body: some View {
        HStack(spacing: 16) {
            Text("\(questionNumber) / \(questionCount)問")
                .font(.system(size: 20, weight: .bold))
                .monospacedDigit()
                .fixedSize()
            ProgressView(value: Double(questionNumber), total: Double(max(questionCount, 1)))
                .tint(Color("loading"))
                .accessibilityHidden(true)
        }
        .foregroundColor(Color("fontGray"))
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color.white.opacity(0.94), in: RoundedRectangle(cornerRadius: 14))
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("問題の進捗")
        .accessibilityValue("全\(questionCount)問中\(questionNumber)問目")
        .accessibilityIdentifier("review.questionProgress")
    }
}

/// 未回答でも正解と解説を表示し、明示的に進むまで同じ問題を保持する。
struct ReviewUnansweredExplanationView: View {
    let reason: ReviewUnansweredReason
    let question: QuizQuestion
    let questionIndex: Int
    let questionCount: Int
    let isLastQuestion: Bool
    let onContinue: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            ReviewQuestionProgressView(questionIndex: questionIndex, questionCount: questionCount)

            Label(reason.rawValue, systemImage: reason.systemImage)
                .font(.title2.bold())
                .foregroundColor(.orange)

            Text("未習得として復習に残ります")
                .font(.subheadline)
                .foregroundColor(.secondary)

            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    explanationSection("問題", text: question.question)
                    explanationSection(
                        "正解",
                        text: question.choices.indices.contains(question.correctAnswerIndex)
                            ? question.choices[question.correctAnswerIndex] : ""
                    )
                    explanationSection("解説", text: question.explanation)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }

            Button(action: onContinue) {
                Text(isLastQuestion ? "結果を見る" : "次の問題へ")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color("loading"), in: RoundedRectangle(cornerRadius: 14))
            }
            .buttonStyle(.plain)
            .accessibilityIdentifier("review.explanation.continue")
        }
        .padding(20)
        .background(Color(.systemBackground), in: RoundedRectangle(cornerRadius: 24))
        .padding(20)
        .frame(maxWidth: 620)
        .accessibilityAddTraits(.isModal)
    }

    private func explanationSection(_ title: String, text: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)
            Text(text)
                .font(.body)
                .fixedSize(horizontal: false, vertical: true)
                .lineSpacing(4)
        }
        .foregroundColor(.primary)
    }
}

/// 初回学習・復習・苦手克服で共有する問題レイアウト。回答の保存は呼び出し元が担当する。
struct ReviewExerciseContent: View {
    let question: QuizQuestion
    let questionIndex: Int
    let questionCount: Int
    let selectedAnswerIndex: Int?
    let hasAnswered: Bool
    let answersDisabled: Bool
    var preservesDisabledAnswerAppearance = false
    var showsTimer = true
    @Binding var remainingSeconds: Int
    var isFinalStage = false
    var attackImpact: QuizAttackImpact? = nil
    var comboCount = 0
    var comboPulse = false
    var showsMonsterDown = false
    var leadingButtonSymbol = "gearshape.fill"
    var leadingButtonLabel = "設定"
    var leadingButtonIdentifier = "review.settings"
    let onSettings: () -> Void
    let onAnswer: (Int) -> Void
    let onUnknown: () -> Void

    var body: some View {
        GeometryReader { geometry in
            let layout = QuizBattleLayoutMetrics(
                availableHeight: geometry.size.height, isPad: isIPad(), reservedFooterHeight: 64
            )
            VStack(spacing: 8) {
                HStack {
                    Button(action: onSettings) {
                        Image(systemName: leadingButtonSymbol)
                            .font(.system(size: 22, weight: .semibold))
                            .foregroundColor(Color("fontGray"))
                            .frame(width: 52, height: 52)
                            .background(Color.white, in: Circle())
                            .shadow(color: .black.opacity(0.15), radius: 8, x: 0, y: 4)
                    }
                    .accessibilityLabel(leadingButtonLabel)
                    .accessibilityIdentifier(leadingButtonIdentifier)
                    Spacer()
                    if showsTimer {
                        TimerView(remainingSeconds: $remainingSeconds, totalSeconds: question.recommendedTimeLimit)
                    }
                }
                .padding(.horizontal, 16)
                .fixedSize(horizontal: false, vertical: true)
                VStack(spacing: 8) {
                    Spacer(minLength: 0)
                    if isFinalStage { ReviewFinalStageBadge() }
                    QuestionCardView(
                        question: question.question, selectedAnswerIndex: selectedAnswerIndex,
                        correctAnswerIndex: question.correctAnswerIndex,
                        maximumHeight: layout.questionMaximumHeight
                    )
                    .padding(.horizontal, 16)
                    .accessibilityIdentifier("review.question")
                    Spacer(minLength: 0)
                    ZStack {
                        QuizMonsterImpactView(
                            imageName: "ReviewWhiteBeardMonster", width: layout.monsterSize,
                            impact: attackImpact
                        )
                        if showsMonsterDown {
                            Image("倒す").resizable().scaledToFit().frame(height: 80)
                        }
                        if comboCount >= 2 {
                            MonsterComboBadgeView(
                                comboCount: comboCount,
                                multiplier: MonsterComboSystem.multiplier(for: comboCount),
                                isPulsing: comboPulse
                            )
                            .scaleEffect(min(1, layout.monsterSize / 72))
                            .offset(x: isSmallDevice() ? 65 : 90)
                            .transition(.scale.combined(with: .opacity))
                            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: comboCount)
                        }
                    }
                    .frame(height: layout.monsterSize)
                    ReviewQuestionProgressView(questionIndex: questionIndex, questionCount: questionCount)
                        .padding(.horizontal, 16)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                QuizAnswerScrollView(questionIndex: questionIndex) {
                    AnswerSelectionView(
                        choices: question.choices,
                        correctAnswerIndex: hasAnswered ? question.correctAnswerIndex : nil,
                        preservesDisabledAppearance: preservesDisabledAnswerAppearance,
                        action: onAnswer
                    )
                    .id(questionIndex)
                    .disabled(answersDisabled)
                    .shadow(radius: 1)
                }
                .frame(height: layout.answerHeight)
                .learningTourTarget(.answers)
                .padding(.bottom, 8)
                Button(action: onUnknown) {
                    Label("わからない・解説を見る", systemImage: "questionmark.circle")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(Color("fontGray"))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(Color.white.opacity(0.94), in: RoundedRectangle(cornerRadius: 14))
                }
                .buttonStyle(.plain)
                .disabled(answersDisabled)
                .accessibilityIdentifier("review.dontKnow")
                .accessibilityHint("未習得として記録し、この問題の正解と解説を表示します")
                .padding(.horizontal, 16)
                .padding(.bottom, 8)
            }
        }
    }
}

struct ReviewGardenBackground: View {
    var body: some View {
        TimelineView(.periodic(from: .now, by: 60)) { context in
            let hour = Calendar.current.component(.hour, from: context.date)
            Image(ReviewGardenPeriod(hour: hour).backgroundImageName)
                .resizable()
                .ignoresSafeArea()
        }
    }
}
