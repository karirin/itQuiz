import SwiftUI

private enum CourseStyle {
    static let blue = Color(red: 0.12, green: 0.32, blue: 0.62)
    static let teal = Color(red: 0.05, green: 0.48, blue: 0.43)
    static let background = Color(.systemGroupedBackground)
}

struct WeaknessCourseEntryCard: View {
    @ObservedObject private var store = WeaknessCourseStore.shared
    @ObservedObject private var auth = AuthManager.shared
    @EnvironmentObject private var appState: AppState
    @EnvironmentObject private var connectivity: ConnectivityMonitor
    @Environment(\.scenePhase) private var scenePhase
    @State private var showingCourses = false
    @State private var reviewDueCount = 0
    @State private var reviewUserID: String?
    @State private var requestID = UUID()

    var body: some View {
        Button { showingCourses = true } label: {
            HStack(spacing: 12) {
                Image(systemName: "checkmark.seal.fill")
                    .font(.system(size: 28)).foregroundStyle(CourseStyle.teal)
                VStack(alignment: .leading, spacing: 4) {
                    Text("苦手克服")
                        .font(.subheadline.weight(.bold))
                    Text(subtitle).font(.caption).foregroundStyle(.secondary)
                }
                Spacer(minLength: 0)
                Image(systemName: "chevron.right").font(.caption.bold())
            }
            .foregroundStyle(Color.primary)
            .padding(16)
            .background(Color(.systemBackground), in: RoundedRectangle(cornerRadius: 18))
            .overlay(RoundedRectangle(cornerRadius: 18).stroke(CourseStyle.teal.opacity(0.22)))
        }
        .buttonStyle(.plain)
        .accessibilityIdentifier("courses.entry")
        .fullScreenCover(isPresented: $showingCourses, onDismiss: prepare) {
            QuizIncorrectAnswerListView(isPresenting: $showingCourses, courseStore: store)
        }
        .task(id: auth.currentUserId) { prepare() }
        .onChange(of: scenePhase) { if $0 == .active { prepare() } }
        .onChange(of: connectivity.isConnected) { _ in prepare() }
    }

    private var subtitle: String {
        guard store.userID == auth.currentUserId else { return "問題の解き直し・説明・類題をひとつに" }
        let due = store.recommendedTopics.filter { store.state.cloud.progress[$0.id]?.isDue(at: Date()) == true }.count
        let questions = reviewUserID == auth.currentUserId ? reviewDueCount : 0
        if questions > 0 || due > 0 {
            return "今日の解き直し \(questions)問 · おさらい \(due)テーマ"
        }
        if store.recommendedTopics.count > 0 { return "解き直しと、苦手\(store.recommendedTopics.count)テーマの練習へ" }
        return appState.isSubscribed ? "ITパスポートの10テーマを練習できます" : "1テーマを、後日のおさらいまで無料で体験"
    }

    private func prepare() {
        let request = UUID()
        requestID = request
        reviewUserID = nil
        reviewDueCount = 0
        store.configure(userID: auth.currentUserId)
        if let userID = auth.currentUserId {
            LocalIncorrectAnswerStore.migrateSchedules(userId: userID)
            reviewUserID = userID
            reviewDueCount = ReviewScheduleService.localSummary(userId: userID).dueCount
            store.importQuestions(LocalIncorrectAnswerStore.questions(userId: userID, category: .itPassport))
            if connectivity.isConnected {
                ReviewScheduleService.fetchSummary(userId: userID) { summary in
                    guard requestID == request, auth.currentUserId == userID else { return }
                    reviewUserID = userID
                    reviewDueCount = summary.dueCount
                }
            }
        }
    }
}

struct WeaknessCourseFlow: View {
    let topic: WeaknessCourseTopic
    @ObservedObject var store: WeaknessCourseStore
    let onNextTopic: (WeaknessCourseTopic) -> Void
    @EnvironmentObject private var appState: AppState
    @Environment(\.dismiss) private var dismiss
    @State private var completion: CourseCompletion?
    @State private var sessionID: String?
    @State private var paywallTopic: WeaknessCourseTopic?
    @State private var purchasedTopic: WeaknessCourseTopic?
    @State private var startingUserID: String?

    private var progress: CourseProgress? { store.state.cloud.progress[topic.id] }
    private var session: CourseSession? {
        guard let active = store.state.activeSession, active.id == sessionID else { return nil }
        return active
    }
    private var isExercising: Bool { completion == nil && canContinueSession && session?.currentQuestion != nil }
    private var canAccess: Bool { store.state.cloud.canAccess(topic.id, subscribed: appState.isSubscribed) }
    private var canContinueSession: Bool { appState.isSubscribed || store.state.cloud.freeClaim?.topicID == topic.id }
    private var nextTopics: [WeaknessCourseTopic] { Array(store.recommendedTopics.filter { $0.id != topic.id }.prefix(3)) }

    var body: some View {
        NavigationStack {
            Group {
                if completion == nil, canContinueSession, let session, let question = session.currentQuestion {
                    CourseQuestionContent(session: session, question: question,
                        onAnswer: { store.answer($0, sessionID: session.id) },
                        onExit: { dismiss() },
                        onContinue: {
                            completion = store.advance(sessionID: session.id)
                            if let completion, let userID = store.userID {
                                ReviewDailyActivityLog.record(ReviewDailyActivity(
                                    kind: completion.kind == .practice ? .themePractice : .themeCheckup,
                                    topicID: completion.topicID, answeredCount: completion.questionCount,
                                    correctCount: completion.correctCount,
                                    masteredCount: completion.progress.stage == .mastered ? 1 : 0,
                                    completedAt: Date(),
                                    checkupNumber: completion.kind == .confirmation ? session.confirmedCountAtStart + 1 : nil),
                                    userID: userID)
                            }
                        })
                    .id(question.id)
                } else if let completion {
                    ThemeSessionResultScreen(
                        completion: completion, topic: topic,
                        relatedTopics: nextTopics.map { ($0, !store.state.cloud.canAccess($0.id, subscribed: appState.isSubscribed)) },
                        isFreeTheme: !appState.isSubscribed && store.state.cloud.freeClaim?.topicID == topic.id,
                        onRetry: { self.completion = nil; sessionID = nil },
                        onClose: { dismiss() },
                        onSelectTopic: { next in
                            if store.state.cloud.canAccess(next.id, subscribed: appState.isSubscribed) {
                                onNextTopic(next); dismiss()
                            } else { openPaywall(next) }
                        })
                } else {
                    ThemeIntroductionContent(
                        topic: topic, progress: progress, canAccess: canAccess,
                        hasActiveSession: store.state.activeSession?.topicID == topic.id,
                        subscribed: appState.isSubscribed,
                        freeClaimTopicID: store.state.cloud.freeClaim?.topicID,
                        subscriptionResolved: appState.hasResolvedSubscriptionState,
                        startTitle: startTitle,
                        onStart: start,
                        onUnlock: { openPaywall(topic) },
                        onClose: { dismiss() })
                }
            }
            .navigationTitle(topic.title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar(isExercising ? .hidden : .visible, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    if !isExercising {
                        Button("閉じる") { dismiss() }
                    }
                }
            }
            .sheet(item: $paywallTopic, onDismiss: resumeAfterPurchase) { selected in
                PreView(audioManager: AudioManager.shared,
                        source: .course(topicID: selected.id, title: selected.title,
                                        remainingCount: store.recommendedTopics.contains(where: { $0.id == selected.id })
                                            ? store.recommendedTopics.count : 0)) {
                    purchasedTopic = selected
                }
            }
            .onAppear {
                if startingUserID == nil {
                    startingUserID = store.userID
                    AuthManager.shared.fetchUserFlag()
                }
            }
            .onChange(of: store.userID) { if $0 != startingUserID { dismiss() } }
        }
        .tint(CourseStyle.blue)
    }

    private var startTitle: String {
        if store.state.activeSession?.topicID == topic.id { return "続きから練習する" }
        if progress?.isDue(at: Date()) == true { return "おさらいを始める" }
        return !appState.isSubscribed && store.state.cloud.freeClaim == nil ? "このテーマを無料で始める" : "3問を練習する"
    }

    private func start() {
        guard appState.hasResolvedSubscriptionState else { return }
        if let session = store.begin(topic: topic, subscribed: appState.isSubscribed) {
            completion = nil
            sessionID = session.id
        }
    }

    private func openPaywall(_ selected: WeaknessCourseTopic) {
        CourseAnalytics.log("course_upgrade_tap", topicID: selected.id)
        // Remember the intended course for both a purchase and a successful restore.
        purchasedTopic = selected
        paywallTopic = selected
    }

    private func resumeAfterPurchase() {
        guard let purchasedTopic else { return }
        self.purchasedTopic = nil
        guard appState.isSubscribed, store.userID == startingUserID else { return }
        if purchasedTopic.id == topic.id { start() }
        else { onNextTopic(purchasedTopic); dismiss() }
    }
}

private struct CourseQuestionContent: View {
    let session: CourseSession
    let question: CourseQuestion
    let onAnswer: (Int) -> Void
    let onExit: () -> Void
    let onContinue: () -> Void
    @ObservedObject private var audioManager = AudioManager.shared
    @ObservedObject private var authManager = AuthManager.shared
    @Environment(\.scenePhase) private var scenePhase
    @State private var remainingSeconds = 30
    @State private var showingSettings = false
    @State private var showingHelp = false
    @State private var showingExplanationAlert = false
    @State private var isExplanationOn = true
    @State private var unansweredReason: ReviewUnansweredReason = .unknown

    init(session: CourseSession, question: CourseQuestion,
         onAnswer: @escaping (Int) -> Void, onExit: @escaping () -> Void,
         onContinue: @escaping () -> Void) {
        self.session = session
        self.question = question
        self.onAnswer = onAnswer
        self.onExit = onExit
        self.onContinue = onContinue
        let quiz = QuizQuestion(id: question.id, question: question.prompt, choices: question.choices,
                                correctAnswerIndex: question.correctIndex, explanation: question.explanation)
        _remainingSeconds = State(initialValue: quiz.recommendedTimeLimit)
    }

    private var selected: Int? { session.answers[question.id] }
    private var timerRunning: Bool { selected == nil && !showingSettings && !showingHelp && scenePhase == .active }
    private var shouldAdvanceWithoutExplanation: Bool {
        selected.map { $0 >= 0 } == true && authManager.userFlag == 1
            && !showingExplanationAlert && scenePhase == .active
    }
    private var quizQuestion: QuizQuestion {
        QuizQuestion(id: question.id, question: question.prompt, choices: question.choices,
                     correctAnswerIndex: question.correctIndex, explanation: question.explanation)
    }

    var body: some View {
        ZStack {
            ReviewGardenBackground()
            ReviewExerciseContent(
                question: quizQuestion, questionIndex: session.questionIndex,
                questionCount: session.questions.count, selectedAnswerIndex: selected,
                hasAnswered: selected != nil, answersDisabled: selected != nil || showingSettings || showingHelp,
                remainingSeconds: $remainingSeconds,
                onSettings: {
                    generateHapticFeedback()
                    showingSettings = true
                    audioManager.playSound()
                },
                onAnswer: answer,
                onUnknown: {
                    unansweredReason = .unknown
                    onAnswer(-1)
                }
            )
            if let selected, selected == -1 || authManager.userFlag == 0 || showingExplanationAlert {
                Color.black.opacity(0.7).ignoresSafeArea()
                if selected == -1 {
                    ReviewUnansweredExplanationView(
                        reason: unansweredReason, question: quizQuestion,
                        questionIndex: session.questionIndex, questionCount: session.questions.count,
                        isLastQuestion: session.questionIndex + 1 == session.questions.count,
                        onContinue: onContinue
                    )
                } else {
                    ModalExplanationView(
                        isPresented: .constant(true), selectedAnswerIndex: .constant(selected),
                        showAlert: .constant(false), audioManager: audioManager,
                        question: question.prompt, userAnswer: question.choices[selected],
                        correctAnswer: question.choices[question.correctIndex], explanation: question.explanation,
                        currentQuizIndex: .constant(session.questionIndex), userFlag: $authManager.userFlag,
                        pauseTimer: {}, startTimer: {}, reviewQuestionCount: session.questions.count,
                        continueTitle: session.questionIndex + 1 == session.questions.count ? "結果を見る" : "次の問題へ",
                        onContinue: onContinue,
                        onHideExplanation: {
                            showingExplanationAlert = true
                        }
                    )
                }
            }
            if showingSettings {
                Color.black.opacity(0.7).ignoresSafeArea()
                ModalView(
                    isSoundOn: $isExplanationOn, isPresented: $showingSettings,
                    isPresenting: .constant(true), audioManager: audioManager,
                    showHomeModal: $showingSettings, tutorialNum: .constant(0),
                    pauseTimer: {}, resumeTimer: {}, userFlag: $authManager.userFlag,
                    exitTitle: "あとで続ける", onExit: onExit,
                    onHelp: { showingHelp = true }
                )
            }
        }
        .fontWeight(.bold)
        .alert("テーマの練習", isPresented: $showingHelp) {
            Button("クイズに戻る", role: .cancel) {}
        } message: {
            Text("選択肢をタップして回答します。わからないときや時間切れのときは、正解と解説を確認できます。設定の「あとで続ける」から退出すると、途中から再開できます。")
        }
        .alert("解説を非表示にしました", isPresented: $showingExplanationAlert) {
            Button("OK", action: onContinue)
        } message: {
            Text("設定画面で切り替える事ができます")
        }
        .task(id: shouldAdvanceWithoutExplanation) {
            guard shouldAdvanceWithoutExplanation else { return }
            // 回答保存後に進む。未回答の解説は表示設定によらず読めるようにする。
            do { try await Task.sleep(nanoseconds: 250_000_000) }
            catch { return }
            guard !Task.isCancelled, shouldAdvanceWithoutExplanation else { return }
            onContinue()
        }
        .task(id: timerRunning) {
            guard timerRunning else { return }
            // 解説、設定、バックグラウンド表示中はカウントを止める。退出時は自動キャンセル。
            while selected == nil {
                do { try await Task.sleep(nanoseconds: 1_000_000_000) }
                catch { return }
                guard !Task.isCancelled else { return }
                remainingSeconds = max(0, remainingSeconds - 1)
                if remainingSeconds == 0 {
                    unansweredReason = .timedOut
                    onAnswer(-1)
                    return
                }
            }
        }
    }

    private func answer(_ index: Int) {
        guard selected == nil else { return }
        if index == question.correctIndex { audioManager.playCorrectSound() }
        else { audioManager.playUnCorrectSound() }
        onAnswer(index)
    }
}

#if DEBUG
/// The seven recovery-home states, plus the free limit together with a free theme.
enum ReviewHomePreviewScenario: String, CaseIterable {
    case reviewDue, continueTheme, firstRun, allClear, nothingToday, freeLimitWithTheme, freeLimit, themeCheckup, afterReview

    var title: String {
        switch self {
        case .reviewDue: return "① 解き直し＋おさらい"
        case .continueTheme: return "② 途中の練習"
        case .firstRun: return "③ 初回"
        case .allClear: return "④ 今日の学習が完了"
        case .nothingToday: return "⑤ 次の予定待ち"
        case .freeLimitWithTheme: return "⑥ 無料5問を使い切り＋おさらい"
        case .freeLimit: return "無料5問を使い切り（おさらいなし）"
        case .themeCheckup: return "おさらいのみ"
        case .afterReview: return "流れ4 解き直し後に戻る"
        }
    }

    /// `-WeaknessCoursePreview -ReviewHomeScenario allClear` selects a state in the simulator.
    static var launchArgument: Self {
        UserDefaults.standard.string(forKey: "ReviewHomeScenario").flatMap(Self.init(rawValue:)) ?? .reviewDue
    }
}

struct WeaknessCoursePreview: View {
    @StateObject private var store: WeaknessCourseStore
    @StateObject private var appState: AppState
    private let scenario: ReviewHomePreviewScenario

    init(scenario: ReviewHomePreviewScenario = .launchArgument,
         subscribed: Bool = ProcessInfo.processInfo.arguments.contains("-CoursePremiumPreview")) {
        self.scenario = scenario
        _store = StateObject(wrappedValue: WeaknessCourseStore.preview(scenario))
        _appState = StateObject(wrappedValue: {
            let state = AppState()
            state.isSubscribed = subscribed
            return state
        }())
    }

    var body: some View {
        if UserDefaults.standard.string(forKey: "ReviewHomeOpen") == "result" {
            ReviewSessionResultPreview()
        } else if UserDefaults.standard.string(forKey: "ReviewHomeOpen") == "themeResult" {
            ThemeSessionResultPreview()
        } else if UserDefaults.standard.string(forKey: "ReviewHomeOpen") == "themeIntro" {
            ThemeIntroductionPreview()
        } else {
            QuizIncorrectAnswerListView(isPresenting: .constant(true), courseStore: store,
                previewSnapshot: .scenario(scenario))
                .environmentObject(appState)
        }
    }
}
#endif
