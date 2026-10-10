//
//  QuizResultView.swift main
//  it
//
//  Created by hashimo ryoya on 2023/09/18.
//

import SwiftUI
import StoreKit

struct QuizResult {
    var question: String
    var userAnswer: String
    var correctAnswer: String
    var explanation: String
    var isCorrect: Bool
    var showExplanation: Bool = false
}

struct QuizTotal {
    var totalAnswers: Int
}

struct ResultReviewUpsellCard: View {
    let incorrectCount: Int
    let action: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 10) {
                Image(systemName: "arrow.counterclockwise.circle.fill")
                    .font(.title2)
                    .foregroundColor(.purple)

                VStack(alignment: .leading, spacing: 3) {
                    Text("間違えた問題を今すぐ復習")
                        .font(.headline)
                    Text("今回の誤答\(incorrectCount)問を、記憶が新しいうちに解き直せます")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }

            Button(action: action) {
                HStack(spacing: 8) {
                    Image(systemName: "crown.fill")
                    Text("復習機能を開く")
                        .fontWeight(.bold)
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 13)
                .background(
                    LinearGradient(
                        colors: [Color(hex: "7F5AF0"), Color(hex: "9B5DE5")],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(ResultPalette.card, in: RoundedRectangle(cornerRadius: 16))
    }
}

struct QuizResultView: View {
    let quizLevel: QuizLevel
    @State private var showModal = false
    @State private var adFlag = false
    @State private var showLevelUpModal = false
    @State private var showTittleModal = false
    @State private var showMemoView = false
    @State private var currentMemo = ""
    @State private var selectedQuestion = ""
    @ObservedObject var authManager: AuthManager
    @ObservedObject var audioManager = AudioManager.shared
    @State private var playerExperience: Int
    @State private var playerMoney: Int
    @State private var isContentView: Bool = false
    var elapsedTime: TimeInterval
    @State var results: [QuizResult]
    let quizBossLevel: QuizBossLevel
    @State private var isShow: Bool = true
    @State private var flag: Bool = false
    @State private var showSubFlag: Bool = false
    @State private var level3flag: Bool = false
    @State private var level5flag: Bool = false
    @State private var level10flag: Bool = false
    @State private var answer30flag: Bool = false
    @State private var answer50flag: Bool = false
    @State private var answer100flag: Bool = false
    @State private var goburinflag: Bool = false
    @State private var kaijyuflag: Bool = false
    @State private var shinjyuflag: Bool = false
    @EnvironmentObject var appState: AppState
    @EnvironmentObject private var connectivity: ConnectivityMonitor
    @Binding var isPresenting: Bool
    @Binding var navigateToQuizResultView: Bool
    @State private var isHidden = false
    @ObservedObject var interstitial: Interstitial
    @StateObject private var quizResultRewardAd = QuizResultRewardAd()
    @State private var hasClaimedRewardedCoinBonus = false
    @State private var showRewardedCoinAlert = false
    @State private var shouldRequestReviewAfterCelebration = false
    @State private var hasRecordedReviewCompletion = false
    @State private var hasShownExperienceModal = false
    @State private var isReviewRequestScheduled = false
    @Environment(\.requestReview) private var requestReview
    @Environment(\.presentationMode) var presentationMode
    private let adViewControllerRepresentable = AdViewControllerRepresentable()
    @State private var restart = false
    @State private var showingAllResults = false
    private let isCleared: Bool
    private let isFreeReviewPreview: Bool
    private let isInitialDiagnostic: Bool
    private let learningContext: LearningEntryContext?
    private let reviewResultContext: ReviewResultContext?
    @State private var reviewResult: ReviewSessionResult?
    @State private var reviewPaywallRequested = false
    @State private var isPresentingRemainingITReview = false
    @State private var hasLoggedReviewPreviewComplete = false
    @State private var hasRecordedAdLearningSet = false
    @State private var hasRequestedInterstitial = false
    @State private var isHandlingResultExit = false
    @State private var hasLoggedGrowthCompletion = false
    @State private var showAdFreeUpsellToast = false
    /// 通常結果の「時間」「平均」に使う解答時間。0 のときは表示しない
    private let sessionDuration: TimeInterval
    /// 「不正解を解き直す」で出題する問題（今回の不正解）
    private let retryQuestions: [QuizQuestion]
    /// 「別の問題で」。nil のときは別の問題に切り替えられない入口（日課・復習など）
    private let onStartNewSet: (() -> Void)?
    @State private var isPresentingMistakeRetry = false
    @State private var pendingMistakeRetryAfterPurchase = false
    @State private var shouldExitAfterMistakeRetry = false
    @State private var levelBeforeLevelUp: Int?

    init(results: [QuizResult], authManager: AuthManager, isPresenting: Binding<Bool>, navigateToQuizResultView: Binding<Bool>, playerExperience: Int, playerMoney: Int, elapsedTime: TimeInterval, quizBossLevel: QuizBossLevel, quizLevel: QuizLevel, interstitial: Interstitial, isCleared: Bool? = nil, isFreeReviewPreview: Bool = false, isInitialDiagnostic: Bool = false, learningContext: LearningEntryContext? = nil, reviewResultContext: ReviewResultContext? = nil, sessionDuration: TimeInterval = 0, retryQuestions: [QuizQuestion] = [], onStartNewSet: (() -> Void)? = nil) {
        _results = State(initialValue: results)
        self.authManager = authManager
        self.interstitial = interstitial
        _isPresenting = isPresenting
        _navigateToQuizResultView = navigateToQuizResultView
        _playerExperience = State(initialValue: playerExperience)
        _playerMoney = State(initialValue: playerMoney)
        self.elapsedTime = elapsedTime
        self.quizBossLevel = quizBossLevel
        self.quizLevel = quizLevel
        self.isCleared = isCleared ?? (playerExperience != 5)
        self.isFreeReviewPreview = isFreeReviewPreview
        self.isInitialDiagnostic = isInitialDiagnostic
        self.learningContext = learningContext
        self.reviewResultContext = reviewResultContext
        self.sessionDuration = sessionDuration
        self.retryQuestions = retryQuestions
        self.onStartNewSet = onStartNewSet
    }
    
    // 正解率を計算
    var correctAnswersCount: Int {
        results.filter { $0.isCorrect }.count
    }
    
    var accuracyPercentage: Double {
        guard !results.isEmpty else { return 0 }
        return Double(correctAnswersCount) / Double(results.count) * 100
    }
    
    var body: some View {
        ZStack {
            // グラデーション背景
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(.systemBackground),
                    Color(.systemGray6)
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            Group {
            if isInitialDiagnostic {
                InitialPracticeCompletionView(
                    correctCount: correctAnswersCount, questionCount: results.count,
                    plan: initialLearningPlan,
                    onContinue: { handleResultExit(action: "initial_practice_complete") },
                    continueTitle: UserDefaults.standard.bool(forKey: "onboarding.needsNameRegistration")
                        ? "次へ進む" : "ホームの使い方を見る"
                )
            } else if let reviewResultContext {
                // 苦手克服から始めた解き直しは、専用の結果画面を出す。表示以外の処理は共通。
                reviewResultScreen(reviewResultContext)
            } else {
                normalResultScreen
            }
            }
            .gesture(
                DragGesture()
                    .onEnded { value in
                        if value.translation.width > 80 {
                            handleResultExit(action: "swipe_back")
                        }
                    }
            )
            .background {
                if !isInitialDiagnostic && appState.shouldShowAds {
                    adViewControllerRepresentable
                        .frame(width: .zero, height: .zero)
                }
            }
            
            // モーダル類
            modalOverlays

            if showAdFreeUpsellToast {
                VStack {
                    Spacer()
                    AdFreeUpsellToast()
                        .padding(.horizontal, 20)
                        .padding(.bottom, 28)
                }
                .transition(.move(edge: .bottom).combined(with: .opacity))
                .zIndex(100)
            }
        }
        .fullScreenCover(isPresented: $showSubFlag, onDismiss: handleSubscriptionDismiss) {
            PreView(
                audioManager: audioManager,
                source: reviewPaywallRequested
                    ? .review(incorrectCount: reviewPaywallIncorrectCount)
                    : .result,
                onPurchaseSuccess: reviewPaywallRequested ? {} : nil
            )
        }
        .fullScreenCover(isPresented: $isPresentingRemainingITReview) {
            QuizITIncorrectAnswerListView(isPresenting: $isPresentingRemainingITReview)
        }
        .fullScreenCover(isPresented: $isPresentingMistakeRetry, onDismiss: handleMistakeRetryDismiss) {
            if let retryLevel = quizLevel.mistakeRetryLevel {
                QuizView(
                    quizzes: retryQuestions,
                    quizLevel: retryLevel,
                    authManager: authManager,
                    audioManager: audioManager,
                    isPresenting: mistakeRetryPresentation,
                    interstitial: interstitial
                )
            }
        }
        .onChange(of: authManager.didLevelUp) { newValue in
            if newValue && !isInitialDiagnostic {
                // 経験値の加算が終わる前に通知されるので、ここでの level は上がる前の値
                levelBeforeLevelUp = authManager.level
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    showLevelUpModal = true
                    audioManager.playLevelUpSound()
                }
            }
        }
        .onAppear {
            if let reviewResultContext, reviewResult == nil {
                reviewResult = reviewResultContext.load()
            }
            logGrowthCompletionIfNeeded()
            logReviewPreviewCompletionIfNeeded()
            prepareReviewRequestIfNeeded()
            prepareInterstitialOpportunity()
            if connectivity.isConnected {
                setupOnAppear()
            }
            if !isInitialDiagnostic && connectivity.isConnected && appState.shouldShowAds {
                quizResultRewardAd.preloadIfNeeded()
            }
            if reviewResultContext != nil || isInitialDiagnostic {
                // 専用の結果画面では獲得モーダルを出さない。レビュー依頼はそのまま判定する。
                hasShownExperienceModal = true
                scheduleReviewRequestIfNeeded()
            } else {
                // モーダルを少し遅れて表示
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    showModal = true
                }
            }
        }
        .onChange(of: showModal) { isShowing in
            if isShowing {
                hasShownExperienceModal = true
            } else if hasShownExperienceModal {
                scheduleReviewRequestIfNeeded()
            }
        }
        .onChange(of: canPresentReviewRequest) { canPresent in
            if canPresent && hasShownExperienceModal {
                scheduleReviewRequestIfNeeded()
            }
        }
        .alert("コイン獲得！", isPresented: $showRewardedCoinAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("追加で\(rewardedCoinBonusAmount)コインを獲得しました。")
        }
    }
    
    private var initialPracticeCompletionCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("はじめての3問、おつかれさま！", systemImage: "checkmark.seal.fill")
                .font(.headline)
                .foregroundStyle(.blue)
            Text(incorrectAnswersCount > 0
                 ? "間違えた問題は保存しました。ホームの「今日の復習」から、もう一度挑戦できます。"
                 : "3問とも正解です！ 次は「学習モード」で、資格や分野を選んでみましょう。")
                .font(.subheadline)
                .fixedSize(horizontal: false, vertical: true)
            Button {
                handleResultExit(action: "initial_practice_complete")
            } label: {
                Label("ホームで学習を続ける", systemImage: "house.fill")
                    .font(.subheadline.bold())
                    .frame(maxWidth: .infinity, minHeight: 44)
            }
            .buttonStyle(.borderedProminent)
            .accessibilityIdentifier("onboarding.finishPractice")
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.systemBackground), in: RoundedRectangle(cornerRadius: 20))
    }

    // MARK: - Normal Result (学習レポート)
    private var normalResultScreen: some View {
        VStack(spacing: 0) {
            resultNavigationBar
            ScrollView {
                if elapsedTime != 0 {
                    // タイムアタックは従来の表示のまま
                    VStack(spacing: 12) {
                        resultSummaryCard
                        resultSupplements
                    }
                    .padding(.horizontal)
                    .padding(.top, 8)
                    resultsContent
                        .padding(.bottom, 24)
                } else {
                    ResultReportContent(
                        results: results,
                        duration: sessionDuration,
                        experience: playerExperience * authManager.rewardFlag,
                        coins: playerMoney * authManager.rewardFlag
                    ) {
                        resultSupplements
                    }
                }
            }
        }
        .background(ResultPalette.screen.ignoresSafeArea())
        .safeAreaInset(edge: .bottom, spacing: 0) {
            resultActionBar
        }
        .toolbar(.hidden, for: .navigationBar)
    }

    private var resultNavigationBar: some View {
        ZStack {
            Text("\(quizLevel.reviewDisplayName)・結果")
                .font(.system(size: 17, weight: .bold, design: .rounded))
                .foregroundColor(ResultPalette.primaryText)
                .lineLimit(1)
                .minimumScaleFactor(0.75)
                .padding(.horizontal, 52)
                .accessibilityAddTraits(.isHeader)

            HStack {
                Button {
                    generateHapticFeedback()
                    handleResultExit(action: "back_button")
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(ResultPalette.primaryText)
                        .frame(width: 44, height: 44)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .accessibilityLabel("戻る")

                Spacer()

                ShareLink(item: "ITクエストで\(correctAnswersCount)/\(results.count)問正解！") {
                    Image(systemName: "square.and.arrow.up")
                        .font(.system(size: 17, weight: .bold))
                        .foregroundColor(ResultPalette.primaryText)
                        .frame(width: 44, height: 44)
                        .contentShape(Rectangle())
                }
                .accessibilityLabel("結果をシェア")
            }
        }
        .padding(.horizontal, 4)
        .padding(.vertical, 2)
    }

    /// 復習の課金導線・コイン2倍・プレミアム。目立ちすぎないよう白カードでまとめる
    @ViewBuilder
    private var resultSupplements: some View {
        if isFreeReviewPreview {
            reviewPreviewCompletionCard
        }
#if DEBUG
        if quizLevel.localReviewCategory == .itPassport && incorrectAnswersCount > 0 {
            WeaknessCourseEntryCard()
        }
#endif
        if shouldShowReviewUpsell {
            ResultReviewUpsellCard(
                incorrectCount: incorrectAnswersCount,
                action: handleReviewCardAction
            )
        }
        if !isInitialDiagnostic && appState.shouldShowAds {
            rewardedCoinBonusCard
            premiumPlanCard
        }
    }

    private var premiumPlanCard: some View {
        Button {
            generateHapticFeedback()
            showSubFlag = true
            audioManager.playSound()
        } label: {
            HStack(spacing: 12) {
                Image(systemName: "crown.fill")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(Color(hex: "B7791F"))
                    .frame(width: 36, height: 36)
                    .background(ResultPalette.coinBackground, in: RoundedRectangle(cornerRadius: 10))
                VStack(alignment: .leading, spacing: 2) {
                    Text("プレミアムプラン")
                        .font(.system(size: 14, weight: .heavy, design: .rounded))
                        .foregroundColor(ResultPalette.primaryText)
                    Text("広告なし・不正解の解き直しが使い放題")
                        .font(.system(size: 12, weight: .semibold, design: .rounded))
                        .foregroundColor(.secondary)
                }
                Spacer(minLength: 4)
                Image(systemName: "chevron.right")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(.secondary)
            }
            .padding(14)
            .frame(minHeight: 44)
            .background(ResultPalette.card, in: RoundedRectangle(cornerRadius: 16))
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel("プレミアムプランを見る")
    }

    // MARK: - Action Bar
    @ViewBuilder
    private var resultActionBar: some View {
        let home = ResultBarButton(title: "ホームへ") { handleResultExit(action: "home_button") }
        let newSet = onStartNewSet == nil ? nil : ResultBarButton(title: "別の問題で", subtitle: "新しい問題", action: handleStartNewSet)
        let retry = canRetryMistakes ? mistakeRetryButton : nil
        let exitHome: () -> Void = { handleResultExit(action: "home_link") }

        if isReviewQuiz {
            // 誤答復習の結果では「別の問題」は出さず、ホームと解き直しを並べる
            ResultActionBar(secondary: retry == nil ? nil : home, primary: retry ?? home, onHome: nil)
        } else if let retry {
            ResultActionBar(secondary: newSet ?? home, primary: retry, onHome: newSet == nil ? nil : exitHome)
        } else {
            ResultActionBar(secondary: nil, primary: newSet ?? home, onHome: newSet == nil ? nil : exitHome)
        }
    }

    private var mistakeRetryButton: ResultBarButton {
        let count = retryQuestions.count
        if appState.isSubscribed {
            let minutes = max(1, Int((Double(count * 20) / 60).rounded(.up)))
            return ResultBarButton(
                title: "不正解の\(count)問を解き直す",
                subtitle: "約\(minutes)分・記憶が新しいうちに",
                action: handleMistakeRetry
            )
        }
        return ResultBarButton(
            title: "不正解の\(count)問を解き直す",
            subtitle: "プレミアム限定",
            systemImage: "crown.fill",
            action: handleMistakeRetry
        )
    }

    private var canRetryMistakes: Bool {
        elapsedTime == 0 && !retryQuestions.isEmpty && quizLevel.mistakeRetryLevel != nil
    }

    /// 不正解の解き直しはプレミアム限定。無料ユーザーはプレミアムプランへ案内する
    private func handleMistakeRetry() {
        guard !isHandlingResultExit else { return }
        if appState.isSubscribed {
            audioManager.playSound()
            isPresentingMistakeRetry = true
        } else {
            pendingMistakeRetryAfterPurchase = true
            presentReviewPaywall()
        }
    }

    /// 解き直しを閉じたら（ホームへ・途中終了とも）、この結果画面も閉じてホームに戻る
    private var mistakeRetryPresentation: Binding<Bool> {
        Binding(
            get: { isPresentingMistakeRetry },
            set: { isPresented in
                if !isPresented { shouldExitAfterMistakeRetry = true }
                isPresentingMistakeRetry = isPresented
            }
        )
    }

    private func handleMistakeRetryDismiss() {
        guard shouldExitAfterMistakeRetry, !isHandlingResultExit else { return }
        shouldExitAfterMistakeRetry = false
        isHandlingResultExit = true
        shouldRequestReviewAfterCelebration = false
        // 効果音は解き直し側の終了時に鳴っているので、ここでは鳴らさない
        isPresenting = false
    }

    private func handleStartNewSet() {
        guard !isHandlingResultExit, let onStartNewSet else { return }
        isHandlingResultExit = true
        shouldRequestReviewAfterCelebration = false
        audioManager.playSound()
        onStartNewSet()
    }

    @ViewBuilder
    private func reviewResultScreen(_ context: ReviewResultContext) -> some View {
        if let reviewResult {
            ReviewSessionResultScreen(result: reviewResult) { action in
                context.finish(action)
                handleResultExit(action: "review_result")
            }
        } else {
            ProgressView().frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }

    // MARK: - Time Attack Summary Card
    private var resultSummaryCard: some View {
        // 通常結果は ResultScoreCard で表示する。ここはタイムアタック専用
        timeAttackSummary
        .frame(maxWidth: .infinity)
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
        )
    }

    private var remainingITReviewCount: Int {
        guard let userId = authManager.currentUserId else { return 0 }
        return LocalIncorrectAnswerStore.count(userId: userId, category: .itPassport)
    }

    private var incorrectAnswersCount: Int {
        results.filter { !$0.isCorrect }.count
    }

    private var isReviewQuiz: Bool {
        switch quizLevel {
        case .incorrectAnswer, .incorrectITAnswer, .incorrectInfoAnswer,
             .incorrectAppliedAnswer, .incorrectESAnswer, .incorrectITStrategyAnswer:
            return true
        default:
            return false
        }
    }

    private var shouldShowReviewUpsell: Bool {
        appState.shouldShowAds
        && !isFreeReviewPreview
        && !isInitialDiagnostic
        && !isReviewQuiz
        && incorrectAnswersCount > 0
    }

    private var reviewPaywallIncorrectCount: Int {
        if isFreeReviewPreview {
            return remainingITReviewCount
        }

        guard let userId = authManager.currentUserId else {
            return incorrectAnswersCount
        }
        return max(
            incorrectAnswersCount,
            LocalIncorrectAnswerStore.count(
                userId: userId,
                category: quizLevel.localReviewCategory
            )
        )
    }

    private var reviewPreviewCompletionCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 10) {
                Image(systemName: remainingITReviewCount > 0 ? "checkmark.circle.fill" : "sparkles")
                    .font(.title2)
                    .foregroundColor(remainingITReviewCount > 0 ? .green : .orange)

                VStack(alignment: .leading, spacing: 3) {
                    Text("今日の無料復習、おつかれさま！")
                        .font(.headline)
                    Text("今回、間違えた問題を\(results.count)問解き直しました")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }

            if remainingITReviewCount > 0 {
                Text("保存された問題はあと\(remainingITReviewCount)問。無料では1日5問、プレミアムでは続けて全問題を復習できます。")
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                Button(action: presentReviewPaywall) {
                    HStack(spacing: 8) {
                        Image(systemName: "crown.fill")
                        Text("残り\(remainingITReviewCount)問を解放")
                            .fontWeight(.bold)
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 13)
                    .background(
                        LinearGradient(
                            colors: [Color(hex: "f093fb"), Color(hex: "f5576c")],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
            } else {
                Text("保存されていた誤答をすべて解き直しました。次は通常問題で新しい問題に挑戦しましょう。")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(ResultPalette.card, in: RoundedRectangle(cornerRadius: 16))
    }

    private func presentReviewPaywall() {
        generateHapticFeedback()
        audioManager.playSound()
        reviewPaywallRequested = true
        showSubFlag = true
    }

    private func handleReviewCardAction() {
        if quizLevel.localReviewCategory == .itPassport && !appState.isSubscribed {
            generateHapticFeedback()
            audioManager.playSound()
            isPresentingRemainingITReview = true
        } else {
            presentReviewPaywall()
        }
    }

    private func handleSubscriptionDismiss() {
        guard reviewPaywallRequested else { return }
        let shouldResumeITReview = isFreeReviewPreview
        let shouldStartMistakeRetry = pendingMistakeRetryAfterPurchase
        reviewPaywallRequested = false
        pendingMistakeRetryAfterPurchase = false

        Task { @MainActor in
            await appState.refreshSubscriptionState()
            if shouldStartMistakeRetry && appState.isSubscribed && canRetryMistakes {
                // 購入したら、そのまま今回の不正解の解き直しを始める
                isPresentingMistakeRetry = true
                return
            }
            guard shouldResumeITReview,
                  appState.isSubscribed,
                  remainingITReviewCount > 0 else { return }
            isPresentingRemainingITReview = true
        }
    }

    private func logReviewPreviewCompletionIfNeeded() {
        guard isFreeReviewPreview, !hasLoggedReviewPreviewComplete else { return }
        hasLoggedReviewPreviewComplete = true
        ReviewAnalytics.logReviewPreviewComplete(
            answeredCount: results.count,
            correctCount: correctAnswersCount,
            remainingCount: remainingITReviewCount
        )
    }

    private var rewardedCoinBonusAmount: Int {
        playerMoney * authManager.rewardFlag
    }

    private var rewardedCoinBonusCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 12) {
                Image(systemName: "play.rectangle.fill")
                    .font(.system(size: 28))
                    .foregroundColor(.orange)

                VStack(alignment: .leading, spacing: 3) {
                    Text("広告を見てコイン2倍")
                        .font(.headline)
                    Text("今回の獲得コインと同額を追加します")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Spacer()

                Text("+\(rewardedCoinBonusAmount)")
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(.orange)
            }

            Button(action: handleRewardedCoinBonus) {
                HStack(spacing: 8) {
                    if quizResultRewardAd.isLoading {
                        ProgressView()
                            .tint(.white)
                    } else {
                        Image(systemName: hasClaimedRewardedCoinBonus ? "checkmark.circle.fill" : "play.fill")
                    }

                    Text(rewardedCoinBonusButtonTitle)
                        .fontWeight(.semibold)
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(hasClaimedRewardedCoinBonus ? Color.green : Color.orange)
                )
            }
            .disabled(
                hasClaimedRewardedCoinBonus
                || quizResultRewardAd.isPresenting
                || (!quizResultRewardAd.isLoaded && !quizResultRewardAd.loadFailed)
            )
        }
        .padding(16)
        .background(ResultPalette.card, in: RoundedRectangle(cornerRadius: 16))
    }

    private var rewardedCoinBonusButtonTitle: String {
        if hasClaimedRewardedCoinBonus {
            return "獲得済み"
        }
        if quizResultRewardAd.loadFailed {
            return "広告を再読み込み"
        }
        if quizResultRewardAd.isLoaded {
            return "広告を見て +\(rewardedCoinBonusAmount)コイン"
        }
        return "広告を準備中"
    }

    private func handleRewardedCoinBonus() {
        generateHapticFeedback()

        if quizResultRewardAd.loadFailed {
            quizResultRewardAd.preloadIfNeeded()
            return
        }

        quizResultRewardAd.present(from: adViewControllerRepresentable.viewController) {
            DispatchQueue.main.async {
                guard !self.hasClaimedRewardedCoinBonus else { return }

                self.hasClaimedRewardedCoinBonus = true
                self.authManager.addMoney(amount: self.rewardedCoinBonusAmount)
                self.showRewardedCoinAlert = true
            }
        }
    }
    
    private var timeAttackSummary: some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: "stopwatch.fill")
                    .font(.title2)
                    .foregroundColor(.orange)
                Text("タイムアタック結果")
                    .font(.title2)
                    .fontWeight(.semibold)
            }
            
            Text(formatDuration(elapsedTime))
                .font(.system(size: 48, weight: .bold, design: .rounded))
                .foregroundColor(.primary)
            
            HStack(spacing: 20) {
                resultActionButton(title: "解説を見る", systemImage: "book.fill") {
                    generateHapticFeedback()
                    withAnimation(.spring()) {
                        isHidden.toggle()
                    }
                }
                
                resultActionButton(title: "ランキング", systemImage: "chart.bar.fill") {
                    generateHapticFeedback()
                    // ランキング機能の実装
                }
            }
        }
    }
    
    // MARK: - Results Content
    private var resultsContent: some View {
        VStack {
            LazyVStack(spacing: 12) {
                ForEach(results.indices, id: \.self) { index in
                    resultCard(for: results[index], index: index)
                }
            }
            .padding(.horizontal)
            .padding(.top, 16)
        }
        .opacity(elapsedTime != 0 ? (isHidden ? 1 : 0) : 1)
    }
    
    private func resultCard(for result: QuizResult, index: Int) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            // ヘッダー
            HStack {
                // 正解/不正解アイコン
                Image(systemName: result.isCorrect ? "checkmark.circle.fill" : "xmark.circle.fill")
                    .font(.title2)
                    .foregroundColor(result.isCorrect ? .green : .red)
                
                Text("問題 \(index + 1)")
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Spacer()
                
                // 正解/不正解ラベル
                Text(result.isCorrect ? "正解" : "不正解")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(result.isCorrect ? Color.green.opacity(0.2) : Color.red.opacity(0.2))
                    )
                    .foregroundColor(result.isCorrect ? .green : .red)
            }
            
            // 問題文
            Text(result.question)
                .font(.body)
                .foregroundColor(.primary)
                .lineLimit(nil)
            
            // 回答部分
            VStack(alignment: .leading, spacing: 8) {
                answerRow(title: "あなたの回答", answer: result.userAnswer,
                         isCorrect: result.isCorrect, isUserAnswer: true)
                answerRow(title: "正解", answer: result.correctAnswer,
                         isCorrect: true, isUserAnswer: false)
            }
            
            // 解説
            if !result.explanation.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Image(systemName: "lightbulb.fill")
                            .font(.caption)
                            .foregroundColor(.orange)
                        Text("解説")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(.secondary)
                        Spacer()
                    }
                    
                    Text(result.explanation)
                        .font(.body)
                        .foregroundColor(.secondary)
                        .lineLimit(nil)
                }
                .padding(.top, 4)
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
        )
    }
    
    private func answerRow(title: String, answer: String, isCorrect: Bool, isUserAnswer: Bool) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
                .frame(width: 80, alignment: .leading)
            
            Text(answer)
                .font(.body)
                .foregroundColor(isUserAnswer ? (isCorrect ? .green : .red) : .primary)
                .fontWeight(isUserAnswer ? .medium : .regular)
                .lineLimit(nil)
            
            Spacer()
        }
    }
    
    // MARK: - Helper Views
    private func resultActionButton(title: String, systemImage: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: systemImage)
                    .font(.system(size: 14, weight: .medium))
                Text(title)
                    .font(.system(size: 14, weight: .medium))
            }
            .foregroundColor(.white)
            .padding(.vertical, 10)
            .padding(.horizontal, 16)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.accentColor)
            )
        }
    }
    
    // MARK: - Modal Overlays
    @ViewBuilder
    private var modalOverlays: some View {
        if showModal {
            ExperienceModalView(showModal: $showModal, addedExperience: playerExperience, addedMoney: playerMoney, isCleared: isCleared, authManager: authManager)
        }
        if showLevelUpModal {
            LevelUpModalView(showLevelUpModal: $showLevelUpModal, previousLevel: levelBeforeLevelUp, authManager: authManager)
        }
        if answer30flag {
            ModalTittleView(showLevelUpModal: $answer30flag, authManager: authManager, tittleNumber: .constant(30))
        }
        if answer50flag {
            ModalTittleView(showLevelUpModal: $answer50flag, authManager: authManager, tittleNumber: .constant(50))
        }
        if answer100flag {
            ModalTittleView(showLevelUpModal: $answer100flag, authManager: authManager, tittleNumber: .constant(100))
        }
        if level3flag {
            ModalTittleView(showLevelUpModal: $level3flag, authManager: authManager, tittleNumber: .constant(3))
        }
        if level5flag {
            ModalTittleView(showLevelUpModal: $level5flag, authManager: authManager, tittleNumber: .constant(5))
        }
        if level10flag {
            ModalTittleView(showLevelUpModal: $level10flag, authManager: authManager, tittleNumber: .constant(10))
        }
        if goburinflag {
            ModalTittleView(showLevelUpModal: $goburinflag, authManager: authManager, tittleNumber: .constant(44))
        }
        if kaijyuflag {
            ModalTittleView(showLevelUpModal: $kaijyuflag, authManager: authManager, tittleNumber: .constant(55))
        }
        if shinjyuflag {
            ModalTittleView(showLevelUpModal: $shinjyuflag, authManager: authManager, tittleNumber: .constant(66))
        }
        
        NavigationLink("", destination: ContentView().navigationBarBackButtonHidden(true), isActive: $isContentView)
    }
    
    // MARK: - Helper Functions
    func formatDuration(_ duration: TimeInterval) -> String {
        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = .positional
        formatter.allowedUnits = [.hour, .minute, .second]
        formatter.zeroFormattingBehavior = .pad
        return formatter.string(from: duration) ?? ""
    }

    private func prepareInterstitialOpportunity() {
        if !hasRecordedAdLearningSet {
            InterstitialOpportunityCoordinator.shared.recordLearningSetCompleted()
            hasRecordedAdLearningSet = true
        }

        guard !hasRequestedInterstitial else { return }
        hasRequestedInterstitial = true

        let coordinator = InterstitialOpportunityCoordinator.shared
        let eligibilityDecision = coordinator.decision(
            subscriptionStateResolved: appState.hasResolvedSubscriptionState,
            isSubscribed: appState.isSubscribed,
            isConnected: connectivity.isConnected,
            isAdReady: true,
            exclusionReason: interstitialExclusionReason
        )

        guard eligibilityDecision.shouldShow else {
            coordinator.recordOpportunity(
                eligibilityDecision,
                surface: "normal_result",
                action: "result_appear",
                didShow: false
            )
            return
        }

        interstitial.preloadIfNeeded { isLoaded in
            DispatchQueue.main.async {
                let decision = coordinator.decision(
                    subscriptionStateResolved: appState.hasResolvedSubscriptionState,
                    isSubscribed: appState.isSubscribed,
                    isConnected: connectivity.isConnected,
                    isAdReady: isLoaded && interstitial.isReady,
                    exclusionReason: interstitialExclusionReason
                )

                guard decision.shouldShow else {
                    coordinator.recordOpportunity(
                        decision,
                        surface: "normal_result",
                        action: "result_appear",
                        didShow: false
                    )
                    return
                }

                let didPresent = interstitial.presentInterstitial(
                    from: adViewControllerRepresentable.viewController
                ) { didShow in
                    DispatchQueue.main.async {
                        coordinator.recordOpportunity(
                            decision,
                            surface: "normal_result",
                            action: "result_appear",
                            didShow: didShow
                        )
                        if didShow {
                            showAdFreeMessage()
                        }
                    }
                }

                if !didPresent {
                    coordinator.recordOpportunity(
                        decision,
                        surface: "normal_result",
                        action: "result_appear",
                        didShow: false
                    )
                }
            }
        }
    }

    private func logGrowthCompletionIfNeeded() {
        guard !hasLoggedGrowthCompletion else { return }
        hasLoggedGrowthCompletion = true
        if isInitialDiagnostic {
            _ = InitialLearningPlanStore.recordCompletion(
                userID: authManager.currentUserId ?? InitialLearningPlanStore.localGuestID,
                incorrectCount: results.count - correctAnswersCount
            )
        }
        GrowthAnalytics.logLearningSetComplete(
            quizLevel: quizLevel,
            answeredCount: results.count,
            correctCount: correctAnswersCount,
            isInitialDiagnostic: isInitialDiagnostic,
            learningContext: learningContext
        )
    }

    private func handleResultExit(action _: String) {
        guard !isHandlingResultExit else { return }
        isHandlingResultExit = true
        shouldRequestReviewAfterCelebration = false
        finishResultExit()
    }

    private var initialLearningPlan: InitialLearningPlan {
        InitialLearningPlanStore.load(userID: authManager.currentUserId ?? InitialLearningPlanStore.localGuestID)
            ?? InitialLearningPlan(completedAt: Date(), incorrectCount: results.count - correctAnswersCount)
    }

    private var interstitialExclusionReason: String? {
        if isFreeReviewPreview {
            return "free_review_preview"
        }
        if isInitialDiagnostic {
            return "initial_diagnostic"
        }
        if showSubFlag {
            return "paywall_presented"
        }
        return learningContext?.interstitialExclusionReason
    }

    private func showAdFreeMessage() {
        withAnimation(.easeOut(duration: 0.2)) {
            showAdFreeUpsellToast = true
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.25) {
            withAnimation(.easeOut(duration: 0.2)) {
                showAdFreeUpsellToast = false
            }
        }
    }

    private func finishResultExit() {
        audioManager.playCancelSound()
        isPresenting = false
    }
    
    private func setupOnAppear() {
        guard connectivity.isConnected,
              authManager.currentUserId != nil else { return }

        authManager.fetchUserStory()
        
        // タイトル獲得処理
        if isCleared {
            checkBossTitles()
        }
        
        // レベルとタイトル処理
        authManager.fetchUserExperienceAndLevel()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            checkLevelTitles()
            checkAnswerTitles()
        }
    }

    private func prepareReviewRequestIfNeeded() {
        guard !isInitialDiagnostic, !hasRecordedReviewCompletion else { return }

        hasRecordedReviewCompletion = true
        shouldRequestReviewAfterCelebration = ReviewRequestManager.shared.recordQuizCompletion(
            satisfactionEvent: isCleared
        )
    }

    private func scheduleReviewRequestIfNeeded(attempt: Int = 0) {
        guard shouldRequestReviewAfterCelebration, !isReviewRequestScheduled else { return }

        isReviewRequestScheduled = true

        Task { @MainActor in
            try? await Task.sleep(nanoseconds: 2_000_000_000)
            self.isReviewRequestScheduled = false

            guard self.shouldRequestReviewAfterCelebration else { return }

            if self.canPresentReviewRequest {
                ReviewRequestManager.shared.markReviewRequested(source: .normalClear)
                self.shouldRequestReviewAfterCelebration = false
                self.requestReview()
            } else if attempt < 3 {
                self.scheduleReviewRequestIfNeeded(attempt: attempt + 1)
            }
        }
    }

    private var canPresentReviewRequest: Bool {
        !showModal
        && !showLevelUpModal
        && !showTittleModal
        && !showMemoView
        && !showSubFlag
        && !level3flag
        && !level5flag
        && !level10flag
        && !answer30flag
        && !answer50flag
        && !answer100flag
        && !goburinflag
        && !kaijyuflag
        && !shinjyuflag
        && !showRewardedCoinAlert
        && !quizResultRewardAd.isPresenting
        && !interstitial.isLoading
        && !interstitial.isPresenting
    }
    
    private func checkBossTitles() {
        if quizBossLevel == .goburin {
            authManager.checkTitles(userId: authManager.currentUserId!, title: "ゴブリン") { exists in
                if !exists {
                    goburinflag = true
                    authManager.saveTitleForUser(userId: authManager.currentUserId!, title: "ゴブリン")
                }
            }
        }
        if quizBossLevel == .kaijyu {
            authManager.checkTitles(userId: authManager.currentUserId!, title: "ガルーラ") { exists in
                if !exists {
                    kaijyuflag = true
                    authManager.saveTitleForUser(userId: authManager.currentUserId!, title: "ガルーラ")
                }
            }
        }
        if quizBossLevel == .shinjyu {
            authManager.checkTitles(userId: authManager.currentUserId!, title: "ルーン") { exists in
                if !exists {
                    shinjyuflag = true
                    authManager.saveTitleForUser(userId: authManager.currentUserId!, title: "ルーン")
                }
            }
        }
    }
    
    private func checkLevelTitles() {
        if authManager.level > 2 {
            authManager.checkTitles(userId: authManager.currentUserId!, title: "レベル３") { exists in
                if !exists {
                    level3flag = true
                    authManager.saveTitleForUser(userId: authManager.currentUserId!, title: "レベル３")
                }
            }
        }
        if authManager.level > 4 {
            authManager.checkTitles(userId: authManager.currentUserId!, title: "レベル５") { exists in
                if !exists {
                    level5flag = true
                    authManager.saveTitleForUser(userId: authManager.currentUserId!, title: "レベル５")
                }
            }
        }
        if authManager.level > 9 {
            authManager.checkTitles(userId: authManager.currentUserId!, title: "レベル１０") { exists in
                if !exists {
                    level10flag = true
                    authManager.saveTitleForUser(userId: authManager.currentUserId!, title: "レベル１０")
                }
            }
        }
    }
    
    private func checkAnswerTitles() {
        authManager.fetchTotalAnswersData(userId: authManager.currentUserId!) { (totalData, totalAnswers) in
            if totalAnswers > 30 {
                authManager.checkTitles(userId: authManager.currentUserId!, title: "回答数３０") { exists in
                    if !exists {
                        answer30flag = true
                        authManager.saveTitleForUser(userId: authManager.currentUserId!, title: "回答数３０")
                    }
                }
            }
            if totalAnswers > 50 {
                authManager.checkTitles(userId: authManager.currentUserId!, title: "回答数５０") { exists in
                    if !exists {
                        answer50flag = true
                        authManager.saveTitleForUser(userId: authManager.currentUserId!, title: "回答数５０")
                    }
                }
            }
            if totalAnswers > 100 {
                authManager.checkTitles(userId: authManager.currentUserId!, title: "回答数１００") { exists in
                    if !exists {
                        answer100flag = true
                        authManager.saveTitleForUser(userId: authManager.currentUserId!, title: "回答数１００")
                    }
                }
            }
        }
    }
    
}

// MARK: - Enhanced Modal Views
struct ExperienceModalView: View {
    @Binding var showModal: Bool
    var addedExperience: Int
    var addedMoney: Int
    var itemRewards: [InventoryReward] = []
    var isCleared: Bool? = nil
    @State private var currentExperience: Double = 0
    @State private var currentMoney: Double = 0
    @State private var showContent = false
    let maxExperience: Double = 100
    @ObservedObject var authManager: AuthManager
    @ObservedObject var audioManager = AudioManager.shared

    private var displaysClear: Bool {
        isCleared ?? (addedExperience != 5)
    }

    var body: some View {
        ZStack {
            Color.black.opacity(0.3)
                .ignoresSafeArea()
                .onTapGesture {
                    dismissModal()
                }
            
            VStack(spacing: 24) {
                // アニメーション付きアイコン
                ZStack {
                    Circle()
                        .fill(displaysClear ? Color.green.opacity(0.2) : Color.red.opacity(0.2))
                        .frame(width: 100, height: 100)
                        .scaleEffect(showContent ? 1.0 : 0.8)
                        .animation(.spring(response: 0.6, dampingFraction: 0.6), value: showContent)
                    
                    Image(systemName: displaysClear ? "checkmark.circle.fill" : "xmark.circle.fill")
                        .font(.system(size: 50))
                        .foregroundColor(displaysClear ? .green : .red)
                        .scaleEffect(showContent ? 1.0 : 0.5)
                        .animation(.spring(response: 0.8, dampingFraction: 0.6).delay(0.2), value: showContent)
                }
                
                VStack(spacing: 8) {
                    Text(displaysClear ? "クリア！" : "ゲームオーバー")
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundColor(.primary)
                        .opacity(showContent ? 1 : 0)
                        .animation(.easeInOut(duration: 0.5).delay(0.4), value: showContent)
                }
                
                // 獲得リワード
                VStack(spacing: 16) {
                    rewardRow(icon: "経験値", title: "経験値", value: "+\(Int(currentExperience))")
                    rewardRow(icon: "コイン", title: "コイン", value: "+\(Int(currentMoney))")
                }
                .opacity(showContent ? 1 : 0)
                .animation(.easeInOut(duration: 0.5).delay(0.6), value: showContent)

                if !itemRewards.isEmpty {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("追加アイテム")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(.secondary)

                        ForEach(Array(itemRewards.enumerated()), id: \.offset) { entry in
                            let reward = entry.element
                            HStack(spacing: 12) {
                                InventoryItemArtworkView(type: reward.type, width: 34, height: 34, cornerRadius: 10)

                                Text(reward.type.displayName)
                                    .font(.body)
                                    .foregroundColor(.primary)

                                Spacer()

                                Text("x\(reward.amount)")
                                    .font(.headline)
                                    .foregroundColor(reward.type.accentColor)
                                    .fontWeight(.semibold)
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color(.systemGray6))
                            )
                        }
                    }
                    .opacity(showContent ? 1 : 0)
                    .animation(.easeInOut(duration: 0.5).delay(0.7), value: showContent)
                }
                
                // プログレスバー
                VStack(spacing: 12) {
                    Text("\(authManager.experience) / \(authManager.level * 100) 経験値")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.secondary)
                    
                    ProgressBar1(value: Double(authManager.experience), maxValue: Double(authManager.level * 100))
                        .frame(height: 12)
                }
                .opacity(showContent ? 1 : 0)
                .animation(.easeInOut(duration: 0.5).delay(0.8), value: showContent)
                
                // 閉じるボタン
                Button(action: dismissModal) {
                    Text("続ける")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.accentColor)
                        )
                }
                .opacity(showContent ? 1 : 0)
                .animation(.easeInOut(duration: 0.5).delay(1.0), value: showContent)
            }
            .padding(24)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color(.systemBackground))
                    .shadow(color: .black.opacity(0.3), radius: 20, x: 0, y: 10)
            )
            .padding(.horizontal, 32)
            .scaleEffect(showContent ? 1.0 : 0.8)
            .animation(.spring(response: 0.6, dampingFraction: 0.8), value: showContent)
        }
        .onAppear {
            authManager.fetchUserFlag()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                showContent = true
                withAnimation(.easeInOut(duration: 1.0).delay(0.5)) {
                    currentExperience = Double(addedExperience) * Double(authManager.rewardFlag)
                    currentMoney = Double(addedMoney) * Double(authManager.rewardFlag)
                }
            }
            
            if displaysClear {
                audioManager.playGameClearSound()
            } else {
                audioManager.playGameOverSound()
            }
            
            DispatchQueue.global(qos: .background).async {
                authManager.fetchUserExperienceAndLevel()
            }
        }
    }
    
    private func rewardRow(icon: String, title: String, value: String) -> some View {
        HStack(spacing: 12) {
            Image(icon)
                .resizable()
                .frame(width: 24, height: 24)
            
            Text(title)
                .font(.body)
                .foregroundColor(.primary)
            
            Spacer()
            
            Text(value)
                .font(.headline)
                .foregroundColor(.green)
                .fontWeight(.semibold)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemGray6))
        )
    }
    
    private func dismissModal() {
        generateHapticFeedback()
        withAnimation(.spring()) {
            showContent = false
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            showModal = false
        }
        audioManager.playCancelSound()
    }
}

struct LevelUpModalView: View {
    @Binding var showLevelUpModal: Bool
    /// 上がる前のレベル。不明なときは1レベル分として表示する
    var previousLevel: Int? = nil
    @State private var showBackground = false
    @State private var showCard = false
    @State private var showMedal = false
    @State private var visibleRows = 0
    @State private var expProgress: Double = 0
    @State private var showButton = false
    @State private var confettiParticles: [LevelUpConfetti] = []
    @ObservedObject var authManager: AuthManager
    @ObservedObject var audioManager = AudioManager.shared

    var body: some View {
        ZStack {
            // 背景
            Color(red: 18 / 255, green: 16 / 255, blue: 34 / 255)
                .opacity(showBackground ? 0.62 : 0)
                .ignoresSafeArea()
                .onTapGesture { }

            // コンフェティ
            ForEach(confettiParticles) { p in
                RoundedRectangle(cornerRadius: 2)
                    .fill(p.color)
                    .frame(width: p.width, height: p.height)
                    .rotationEffect(.degrees(p.rotation))
                    .offset(x: p.x, y: p.y)
                    .opacity(p.opacity)
            }
            .allowsHitTesting(false)

            if showCard {
                LevelUpRewardCard(
                    level: authManager.level,
                    previousLevel: previousLevel ?? authManager.level - 1,
                    experience: authManager.experience,
                    showsMedal: showMedal,
                    visibleRows: visibleRows,
                    expProgress: expProgress,
                    showsButton: showButton,
                    onClose: dismissModal
                )
                .padding(.horizontal, 24)
                .transition(.scale(scale: 0.8).combined(with: .opacity))
            }
        }
        .onAppear {
            authManager.fetchUserExperienceAndLevel()
            playSequence()
        }
    }

    private func playSequence() {
        // 背景
        withAnimation(.easeOut(duration: 0.3)) {
            showBackground = true
        }

        // カード
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                showCard = true
            }
        }

        // メダル
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.45)) {
                showMedal = true
            }
        }

        // コンフェティ
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            spawnConfetti()
        }

        // 報酬の行を 0.08 秒ずつ
        for row in 1...2 {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6 + Double(row - 1) * 0.08) {
                withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
                    visibleRows = row
                }
            }
        }

        // EXP バー
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.85) {
            withAnimation(.easeOut(duration: 0.6)) {
                expProgress = 1
            }
        }

        // ボタン
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.1) {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                showButton = true
            }
        }
    }

    private func spawnConfetti() {
        let colors: [Color] = [.yellow, .orange, .red, .pink, .purple, .cyan]
        for i in 0..<25 {
            var piece = LevelUpConfetti(
                x: CGFloat.random(in: -180...180),
                y: -400,
                width: CGFloat.random(in: 4...8),
                height: CGFloat.random(in: 10...18),
                color: colors.randomElement()!,
                rotation: 0,
                opacity: 1.0
            )
            let delay = Double(i) * 0.025
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                withAnimation(.easeIn(duration: Double.random(in: 1.5...3.0))) {
                    piece.y = 500
                    piece.x += CGFloat.random(in: -30...30)
                    piece.rotation = Double.random(in: 360...720)
                    piece.opacity = 0
                }
                confettiParticles.append(piece)
            }
        }
    }

    private func dismissModal() {
        generateHapticFeedback()
        audioManager.playCancelSound()
        withAnimation(.easeOut(duration: 0.2)) {
            showCard = false
            showBackground = false
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
            showLevelUpModal = false
        }
    }
}

extension QuizLevel {
    /// 結果画面の「不正解を解き直す」で使う誤答復習モード。EXP・コインは誤答復習と同じく付与しない。
    /// 資格に属さない問題（.general）は保存先の復習モードがないので解き直しを出さない。
    var mistakeRetryLevel: QuizLevel? {
        switch localReviewCategory {
        case .itPassport: return .incorrectITAnswer
        case .fundamentalInformation: return .incorrectInfoAnswer
        case .appliedInformation: return .incorrectAppliedAnswer
        case .embeddedSystems: return .incorrectESAnswer
        case .itStrategist: return .incorrectITStrategyAnswer
        case .general: return nil
        }
    }
}

struct LevelUpConfetti: Identifiable {
    let id = UUID()
    var x: CGFloat
    var y: CGFloat
    var width: CGFloat
    var height: CGFloat
    var color: Color
    var rotation: Double
    var opacity: Double
}

struct ProgressBar1: View {
    var value: Double
    var maxValue: Double
    @State private var animatedValue: Double = 0

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 6)
                    .fill(Color(.systemGray5))
                
                RoundedRectangle(cornerRadius: 6)
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [Color.blue, Color.purple]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: CGFloat(animatedValue / maxValue) * geometry.size.width)
                    .animation(.easeInOut(duration: 1.5), value: animatedValue)
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                animatedValue = value
            }
        }
        .onChange(of: value) { newValue in
            withAnimation(.easeInOut(duration: 0.8)) {
                animatedValue = newValue
            }
        }
    }
}

// MARK: - Preview
struct QuizResultView_Previews: PreviewProvider {
    @State static var isPresenting = false
    @State static var navigateToQuizResultView = false

    static var previews: some View {
        let dummyResults = [
            QuizResult(question: "SwiftUIでレイアウトを作成する際に使用する基本的なコンテナビューは？", userAnswer: "VStack", correctAnswer: "VStack", explanation: "VStackは垂直方向にビューを配置するためのコンテナビューです。", isCorrect: true),
            QuizResult(question: "iOSアプリ開発で使用される主要なプログラミング言語は？", userAnswer: "Java", correctAnswer: "Swift", explanation: "Swiftは、Appleが開発したiOSアプリ開発用のプログラミング言語です。", isCorrect: false),
            QuizResult(question: "Xcodeとは何ですか？", userAnswer: "IDE", correctAnswer: "IDE", explanation: "Xcode（統合開発環境）は、Appleのプラットフォームでのソフトウェアアプリケーション開発用の統合開発環境です。", isCorrect: true)
        ]
        let authManager = AuthManager()

        QuizResultView(
            results: dummyResults,
            authManager: authManager,
            isPresenting: $isPresenting,
            navigateToQuizResultView: $navigateToQuizResultView,
            playerExperience: 25,
            playerMoney: 15,
            elapsedTime: 0,
            quizBossLevel: .none,
            quizLevel: .beginner,
            interstitial: Interstitial()
        )
        .environmentObject(AppState())
        .environmentObject(ConnectivityMonitor.shared)
    }
}
