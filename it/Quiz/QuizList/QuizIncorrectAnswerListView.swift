//
//  QuizIncorrectAnswerListView.swift
//  it
//
//  Created by hashimo ryoya on 2023/12/28.
//

import SwiftUI
import Firebase
import FirebaseAnalytics


enum LocalReviewCategory: String, Codable {
    case itPassport
    case fundamentalInformation
    case appliedInformation
    case embeddedSystems
    case itStrategist
    case general
}

extension QuizLevel {
    var localReviewCategory: LocalReviewCategory {
        switch self {
        case .itBasic, .itStrategy, .itTechnology, .itManagement, .incorrectITAnswer:
            return .itPassport
        case .infoBasic, .infoStrategy, .infoTechnology, .infoManagement, .incorrectInfoAnswer:
            return .fundamentalInformation
        case .appliedBasic, .appliedStrategy, .appliedTechnology, .appliedManagement, .incorrectAppliedAnswer:
            return .appliedInformation
        case .computerSystem, .softHard, .netwarkTusin, .ESsecurity, .incorrectESAnswer:
            return .embeddedSystems
        case .kikaku, .sekkei, .kaihatu, .unyouhoshu, .incorrectITStrategyAnswer:
            return .itStrategist
        default:
            return .general
        }
    }

    var isLocalIncorrectReview: Bool {
        switch self {
        case .incorrectITAnswer, .incorrectInfoAnswer, .incorrectAppliedAnswer,
             .incorrectESAnswer, .incorrectITStrategyAnswer:
            return true
        default:
            return false
        }
    }
}

struct LocalIncorrectAnswerSaveResult {
    let succeeded: Bool
    let recordCount: Int
}

private struct LocalIncorrectAnswerRecord: Codable {
    let id: String
    let quizQuestion: String
    let choices: [String]
    let correctAnswerIndex: Int
    let explanation: String
    let category: LocalReviewCategory
    var sourceQuizLevel: String?
    var incorrectCount: Int
    var lastIncorrectAt: Date

    var quizQuestionValue: QuizQuestion {
        QuizQuestion(
            id: "local_\(id)",
            question: quizQuestion,
            choices: choices,
            correctAnswerIndex: correctAnswerIndex,
            explanation: explanation,
            sourceQuizLevel: sourceQuizLevel
        )
    }

    func matches(_ question: QuizQuestion) -> Bool {
        quizQuestion == question.question
            && choices == question.choices
            && correctAnswerIndex == question.correctAnswerIndex
    }

    func matches(_ answer: IncorrectAnswer, category targetCategory: LocalReviewCategory) -> Bool {
        category == targetCategory
            && quizQuestion == answer.quizQuestion
            && choices == answer.choices
            && correctAnswerIndex == answer.correctAnswerIndex
    }
}

/// 誤答と復習予定を、加入状態にかかわらず端末へ保存する。
enum LocalIncorrectAnswerStore {
    private static let lock = NSLock()

    static func save(
        _ answer: IncorrectAnswer,
        quizLevel: QuizLevel
    ) -> LocalIncorrectAnswerSaveResult {
        LocalReviewScheduleStore.saveMistake(QuizQuestion(question: answer.quizQuestion,
            choices: answer.choices, correctAnswerIndex: answer.correctAnswerIndex,
            explanation: answer.explanation, sourceQuizLevel: answer.sourceQuizLevel), userID: answer.userId)
        return withLock {
            var records = loadUnlocked(userId: answer.userId)
            let category = quizLevel.localReviewCategory

            if let index = records.firstIndex(where: { $0.matches(answer, category: category) }) {
                records[index].incorrectCount += 1
                records[index].lastIncorrectAt = Date()
                records[index].sourceQuizLevel = answer.sourceQuizLevel
            } else {
                records.append(
                    LocalIncorrectAnswerRecord(
                        id: UUID().uuidString,
                        quizQuestion: answer.quizQuestion,
                        choices: answer.choices,
                        correctAnswerIndex: answer.correctAnswerIndex,
                        explanation: answer.explanation,
                        category: category,
                        sourceQuizLevel: answer.sourceQuizLevel,
                        incorrectCount: 1,
                        lastIncorrectAt: Date()
                    )
                )
            }

            records.sort { $0.lastIncorrectAt > $1.lastIncorrectAt }

            let succeeded = saveUnlocked(records, userId: answer.userId)
            return LocalIncorrectAnswerSaveResult(succeeded: succeeded, recordCount: records.count)
        }
    }

    static func migrateSchedules(userId: String) {
        let questions = withLock { loadUnlocked(userId: userId).map(\.quizQuestionValue) }
        LocalReviewScheduleStore.importLegacy(questions, userID: userId)
    }

    static func questions(userId: String, category: LocalReviewCategory) -> [QuizQuestion] {
        let questions = withLock {
            loadUnlocked(userId: userId)
                .filter { $0.category == category }
                .sorted { $0.lastIncorrectAt > $1.lastIncorrectAt }
                .map(\.quizQuestionValue)
        }
        return LocalReviewScheduleStore.excludingMastered(questions, userID: userId)
    }

    static func count(userId: String, category: LocalReviewCategory) -> Int {
        questions(userId: userId, category: category).count
    }

    static func remove(userId: String, category: LocalReviewCategory, matching question: QuizQuestion) {
        withLock {
            var records = loadUnlocked(userId: userId)
            records.removeAll { $0.category == category && $0.matches(question) }
            _ = saveUnlocked(records, userId: userId)
        }
    }

    static func merged(local: [QuizQuestion], remote: [QuizQuestion]) -> [QuizQuestion] {
        var result = remote
        for question in local where !result.contains(where: { sameQuestion($0, question) }) {
            result.append(question)
        }
        return result
    }

    private static func sameQuestion(_ lhs: QuizQuestion, _ rhs: QuizQuestion) -> Bool {
        lhs.question == rhs.question
            && lhs.choices == rhs.choices
            && lhs.correctAnswerIndex == rhs.correctAnswerIndex
    }

    private static func withLock<T>(_ work: () -> T) -> T {
        lock.lock()
        defer { lock.unlock() }
        return work()
    }

    private static func loadUnlocked(userId: String) -> [LocalIncorrectAnswerRecord] {
        guard let data = try? Data(contentsOf: fileURL(userId: userId)),
              let records = try? JSONDecoder().decode([LocalIncorrectAnswerRecord].self, from: data) else {
            return []
        }
        return records
    }

    private static func saveUnlocked(_ records: [LocalIncorrectAnswerRecord], userId: String) -> Bool {
        do {
            let data = try JSONEncoder().encode(records)
            try data.write(to: fileURL(userId: userId), options: .atomic)
            return true
        } catch {
            print("Failed to save local incorrect answers: \(error.localizedDescription)")
            return false
        }
    }

    private static func fileURL(userId: String) throws -> URL {
        let baseURL = try FileManager.default.url(
            for: .applicationSupportDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: true
        )
        let directoryURL = baseURL.appendingPathComponent("ITQuizReviewCache", isDirectory: true)
        try FileManager.default.createDirectory(at: directoryURL, withIntermediateDirectories: true)
        let safeUserId = userId.replacingOccurrences(of: "/", with: "_")
        return directoryURL.appendingPathComponent("\(safeUserId).json")
    }
}

enum ReviewAnalytics {
    static func logMistakeSave(
        result: LocalIncorrectAnswerSaveResult,
        quizLevel: QuizLevel
    ) {
        Analytics.logEvent("mistake_save_result", parameters: [
            "result": result.succeeded ? "success" : "failure",
            "storage": "local",
            "quiz_level": quizLevel.description,
            "qualification": quizLevel.localReviewCategory.rawValue,
            "record_count": result.recordCount
        ])
    }

    static func logReviewPreviewComplete(
        answeredCount: Int,
        correctCount: Int,
        remainingCount: Int
    ) {
        Analytics.logEvent("review_preview_complete", parameters: [
            "qualification": LocalReviewCategory.itPassport.rawValue,
            "answered_count": answeredCount,
            "correct_count": correctCount,
            "remaining_count": remainingCount
        ])
    }
}

struct QuizIncorrectAnswerListView: View {
    @EnvironmentObject private var appState: AppState
    @EnvironmentObject private var connectivity: ConnectivityMonitor
    @Environment(\.scenePhase) private var scenePhase
    @Environment(\.dynamicTypeSize) private var typeSize
    @Binding var isPresenting: Bool
    @ObservedObject private var courseStore: WeaknessCourseStore
    @ObservedObject private var authManager = AuthManager.shared
    @State private var shuffledQuizList: [QuizQuestion] = []
    @State private var activeQuizList: [QuizQuestion] = []
    @State private var weakAreas: [ReviewWeakArea] = []
    @State private var scheduleRecords: [LocalScheduledReview] = []
    @State private var todayActivities: [ReviewDailyActivity] = []
    @State private var reviewBaseline: ReviewSessionBaseline?
    @State private var lastOutcome: ReviewSessionOutcome?
    @State private var pendingHomeAction: ReviewHomeAction?
    @State private var navigationPath: [ReviewHomeRoute] = []
    @State private var isDataLoaded = false
    @State private var loadErrorMessage: String?
    @State private var isRunningQuiz = false
    @State private var isFocusedReview = false
    @State private var freeRemaining = ReviewAccessPolicy.dailyFreeLimit
    @State private var presentedSheet: ReviewHomeSheet?
    @State private var selectedTopic: WeaknessCourseTopic?
    @State private var pendingTopic: WeaknessCourseTopic?
    @State private var now = Date()
    @State private var reviewRequestID = UUID()
    @State private var loggedCourseHome = false
    @State private var focusAlertMessage: String?
    @State private var summary = ReviewScheduleSummary(dueCount: 0, totalCount: 0, nextReviewDate: nil)

    private var audioManager = AudioManager.shared
    @StateObject var sharedInterstitial = Interstitial()
    private let questionIdPrefix: String?
    private let learningContext: LearningEntryContext?
    private let previewSnapshot: WeaknessReviewSnapshot?

    init(
        isPresenting: Binding<Bool>,
        questionIdPrefix: String? = nil,
        learningContext: LearningEntryContext? = nil,
        courseStore: WeaknessCourseStore? = nil,
        previewSnapshot: WeaknessReviewSnapshot? = nil
    ) {
        self._isPresenting = isPresenting
        self.questionIdPrefix = questionIdPrefix
        self.learningContext = learningContext
        self.courseStore = courseStore ?? .shared
        self.previewSnapshot = previewSnapshot
    }

    var body: some View {
        ZStack {
            if isRunningQuiz {
                QuizView(
                    quizzes: activeQuizList,
                    quizLevel: .incorrectAnswer,
                    isInfiniteMode: false,
                    requiresPremiumReview: isFocusedReview,
                    learningContext: learningContext,
                    reviewResultContext: ReviewResultContext(load: loadReviewResult, finish: { pendingHomeAction = $0 }),
                    authManager: authManager,
                    audioManager: audioManager,
                    isPresenting: $isRunningQuiz,
                    interstitial: sharedInterstitial
                )
            } else {
                NavigationStack(path: $navigationPath) {
                    reviewHome
                        .navigationTitle("苦手克服")
                        .toolbar(.hidden, for: .navigationBar)
                        .navigationDestination(for: ReviewHomeRoute.self, destination: destination)
                }
            }
        }
        .task(id: authManager.currentUserId) { prepareRecovery() }
#if DEBUG
        .onAppear {
            // `-ReviewHomeOpen topics|focus|guide` opens a screen in the simulator preview.
            guard previewSnapshot != nil else { return }
            switch UserDefaults.standard.string(forKey: "ReviewHomeOpen") {
            case "topics": navigationPath = [.topics]
            case "focus": navigationPath = [.focusedTraining]
            case "guide": presentedSheet = .guide
            case "mastered": presentedSheet = .mastered
            default: break
            }
        }
#endif
        .onChange(of: isRunningQuiz) { isRunning in
            if !isRunning {
                finishReviewSession()
                lastOutcome = nil
                loadReviews()
                if let action = pendingHomeAction {
                    pendingHomeAction = nil
                    DispatchQueue.main.async { handle(action) }
                }
            }
        }
        .sheet(item: $presentedSheet, onDismiss: loadReviews) { sheet in
            switch sheet {
            case .mastered:
                MasteredAnswersView(store: courseStore, previewQuestions: previewSnapshot?.mastered)
            case .premium:
                PreView(audioManager: audioManager, source: .review(incorrectCount: summary.dueCount))
            case .guide:
                WeaknessRecoveryGuideSheet()
            }
        }
        .fullScreenCover(item: $selectedTopic, onDismiss: {
            now = Date()
            if let pendingTopic {
                self.pendingTopic = nil
                selectedTopic = pendingTopic
            } else {
                loadReviews()
            }
        }) { topic in
            WeaknessCourseFlow(topic: topic, store: courseStore) { next in pendingTopic = next }
        }
        .onChange(of: scenePhase) { phase in
            if phase == .active, !isRunningQuiz, selectedTopic == nil { prepareRecovery() }
        }
        .onChange(of: appState.isSubscribed) { _ in
            if !isRunningQuiz { loadReviews() }
        }
        .onChange(of: connectivity.isConnected) { _ in
            if !isRunningQuiz { loadReviews() }
        }
        .alert("集中特訓", isPresented: Binding(
            get: { focusAlertMessage != nil },
            set: { if !$0 { focusAlertMessage = nil } }
        )) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(focusAlertMessage ?? "")
        }
    }

    private var reviewHome: some View {
        ZStack {
            RecoveryStyle.background

            VStack(spacing: 0) {
                reviewNavigationBar
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 20) {
                        if !isDataLoaded {
                            SlimeCardLoadingView(message: "問題の復習状況を確認中…")
                                .padding(.top, 40)
                        } else if let loadErrorMessage {
                            SlimeErrorView(
                                title: "問題の復習状況を読み込めませんでした",
                                message: loadErrorMessage,
                                retry: loadReviews
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                        } else {
                            WeaknessReviewHomeContent(plan: homePlan, context: homeContext, onAction: handle, now: now)
                        }
                        if let message = courseStore.syncMessage {
                            HStack(alignment: .top) {
                                Text(message).font(.caption).foregroundStyle(RecoveryStyle.secondaryText)
                                Spacer()
                                Button("再試行") { courseStore.sync() }
                                    .font(.caption.bold()).disabled(courseStore.isSyncing)
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 12)
                    .padding(.bottom, 32)
                    .frame(maxWidth: 640)
                    .frame(maxWidth: .infinity)
                }
                .refreshable { prepareRecovery() }
            }
        }
    }

    private var reviewNavigationBar: some View {
        ZStack {
            Text("苦手克服")
                .font(.headline)
                .foregroundStyle(RecoveryStyle.text)
                .accessibilityAddTraits(.isHeader)
            HStack {
                Button {
                    isPresenting = false
                } label: {
                    if typeSize >= .accessibility1 {
                        Image(systemName: "chevron.left").font(.title3.weight(.semibold))
                            .frame(minWidth: 44, minHeight: 44, alignment: .leading)
                    } else {
                        Label("戻る", systemImage: "chevron.left")
                            .font(.body.weight(.semibold))
                            .frame(minWidth: 44, minHeight: 44, alignment: .leading)
                    }
                }
                .accessibilityLabel("戻る")
                Spacer()
                Button {
                    presentedSheet = .guide
                } label: {
                    if typeSize >= .accessibility1 {
                        Image(systemName: "questionmark.circle").font(.title3)
                            .frame(minWidth: 44, minHeight: 44)
                    } else {
                        Label("しくみ", systemImage: "questionmark.circle")
                            .font(.body.weight(.semibold))
                            .frame(minWidth: 44, minHeight: 44, alignment: .trailing)
                    }
                }
                .accessibilityLabel("しくみ")
            }
        }
        .foregroundColor(RecoveryTint.review.tagText)
        .padding(.horizontal, 16)
        .padding(.vertical, 4)
        .background(.ultraThinMaterial)
    }

    @ViewBuilder
    private func destination(_ route: ReviewHomeRoute) -> some View {
        switch route {
        case .topics:
            WeaknessTopicListView(store: courseStore, now: now,
                                  onSelect: { selectedTopic = $0 },
                                  onPremium: { presentedSheet = .premium })
        case .focusedTraining:
            FocusedTrainingView(weakAreas: weakAreas, subscribed: appState.isSubscribed,
                                onStart: startFocusedReview,
                                onPremium: { presentedSheet = .premium })
        }
    }

    // MARK: Recommendation input

    private var homePlan: ReviewHomePlan { ReviewHomeResolver.resolve(homeInput) }

    private var homeInput: ReviewHomeInput {
        makeHomeInput(summary: summary, dueQuestions: shuffledQuizList, records: scheduleRecords,
                      freeRemaining: freeRemaining, activities: todayActivities, now: now)
    }

    private func makeHomeInput(summary: ReviewScheduleSummary, dueQuestions: [QuizQuestion],
                               records: [LocalScheduledReview], freeRemaining: Int,
                               activities: [ReviewDailyActivity], now: Date) -> ReviewHomeInput {
        let state = courseStore.state
        let subscribed = appState.isSubscribed
        let session = state.activeSession.flatMap { session -> ReviewThemeResume? in
            guard subscribed || state.cloud.freeClaim?.topicID == session.topicID else { return nil }
            return ReviewThemeResume(topicID: session.topicID,
                                     step: session.kind == .practice ? .practice : .checkup(session.confirmedCountAtStart + 1),
                                     questionIndex: session.questionIndex, questionCount: session.questions.count)
        }
        let dueThemes = WeaknessRecoveryOverview(state: state.cloud, now: now).dueTopicIDs
            .filter { state.cloud.canAccess($0, subscribed: subscribed) }
            .map { ReviewDueTheme(topicID: $0, checkupNumber: (state.cloud.progress[$0]?.confirmedCount ?? 0) + 1) }
        let themeDates = state.cloud.progress.compactMap { id, progress -> (topicID: String, number: Int, date: Date)? in
            guard progress.stage == .waiting, let date = progress.nextReviewAt, WeaknessCourseCatalog.topic(id) != nil,
                  state.cloud.canAccess(id, subscribed: subscribed) else { return nil }
            return (id, progress.confirmedCount + 1, date)
        }
        let available = availableReviews(from: dueQuestions)
        return ReviewHomeInput(
            subscribed: subscribed,
            activeSession: session,
            dueReviewCount: summary.dueCount,
            availableReviewCount: available.count,
            availableFinalStageCount: finalStageCount(in: available, records: records),
            freeRemaining: freeRemaining,
            dueThemes: dueThemes,
            hasReviewHistory: summary.totalCount + summary.masteredCount > 0,
            hasThemeProgress: !state.cloud.progress.isEmpty || state.cloud.freeClaim != nil,
            todayActivities: activities,
            upcoming: ReviewUpcomingItem.make(reviewDates: upcomingReviewDates(records), themes: themeDates, now: now)
        )
    }

    private var homeContext: ReviewHomeContext {
        let state = courseStore.state
        let learning = state.activeSession?.topicID
            ?? courseStore.recommendedTopics.first { state.isLearning($0.id) }?.id
        let learningProgress = learning.flatMap { state.cloud.progress[$0] }
        return ReviewHomeContext(subscribed: appState.isSubscribed, freeRemaining: freeRemaining,
                                 freeClaimTopicID: state.cloud.freeClaim?.topicID,
                                 masteredQuestionCount: summary.masteredCount,
                                 masteredTopicCount: courseStore.masteredTopics.count,
                                 learningTopicID: learning,
                                 learningTopicNearMastery: learningProgress?.stage == .waiting
                                    && (learningProgress?.confirmedCount ?? 0) >= 1,
                                 reviewStreak: summary.reviewStreak,
                                 todayMasteredCount: todayActivities.filter { $0.kind == .review }
                                    .reduce(0) { $0 + $1.masteredCount })
    }

    private var availableReviews: [QuizQuestion] { availableReviews(from: shuffledQuizList) }

    private func availableReviews(from questions: [QuizQuestion]) -> [QuizQuestion] {
        if let previewSnapshot {
            return appState.isSubscribed ? questions : Array(questions.prefix(previewSnapshot.freeRemaining))
        }
        guard let userID = authManager.currentUserId else { return [] }
        return ReviewAccessPolicy.available(questions, userID: userID, subscribed: appState.isSubscribed)
    }

    private func finalStageCount(in questions: [QuizQuestion], records: [LocalScheduledReview]) -> Int {
        if let previewSnapshot { return min(previewSnapshot.finalStageCount, questions.count) }
        let finalKeys = Set(records.filter { $0.progress.masteredAt == nil && $0.progress.stage >= 2 }
            .map { ReviewAccessPolicy.key($0.question) })
        return questions.filter { finalKeys.contains(ReviewAccessPolicy.key($0)) }.count
    }

    private func upcomingReviewDates(_ records: [LocalScheduledReview]) -> [Date] {
        if let previewSnapshot { return previewSnapshot.upcomingReviewDates }
        return records.filter { $0.progress.masteredAt == nil }.compactMap(\.progress.nextReviewAt)
    }

    private func handle(_ action: ReviewHomeAction) {
        switch action {
        case .startReview: startAllReviews()
        case .openTopic(let id): selectedTopic = WeaknessCourseCatalog.topic(id)
        case .openPremium: presentedSheet = .premium
        case .openMastered: presentedSheet = .mastered
        case .openGuide: presentedSheet = .guide
        case .close: isPresenting = false
        }
    }

    // MARK: Loading

    private func prepareRecovery() {
        now = Date()
        if previewSnapshot == nil {
            selectedTopic = nil
            pendingTopic = nil
            courseStore.configure(userID: authManager.currentUserId)
            if let userId = authManager.currentUserId {
                courseStore.importQuestions(LocalIncorrectAnswerStore.questions(userId: userId, category: .itPassport))
            }
        }
        if !loggedCourseHome {
            CourseAnalytics.log("course_home_view")
            loggedCourseHome = true
        }
        loadReviews()
    }

    private func loadReviews() {
        let requestID = UUID()
        reviewRequestID = requestID
        now = Date()
        shuffledQuizList = []
        weakAreas = []
        summary = ReviewScheduleSummary(dueCount: 0, totalCount: 0, nextReviewDate: nil)
        if let previewSnapshot {
            summary = previewSnapshot.summary
            shuffledQuizList = previewSnapshot.questions
            freeRemaining = previewSnapshot.freeRemaining
            todayActivities = previewSnapshot.todayActivities
            weakAreas = previewSnapshot.weakAreas
            loadErrorMessage = nil
            isDataLoaded = true
            return
        }
        guard let userId = authManager.currentUserId else {
            loadErrorMessage = "ログイン状態を確認して、もう一度お試しください。"
            isDataLoaded = true
            return
        }
        LocalIncorrectAnswerStore.migrateSchedules(userId: userId)
        freeRemaining = ReviewAccessPolicy.remaining(userID: userId)
        todayActivities = ReviewDailyActivityLog.today(userID: userId)
        applyLocalReviews(userID: userId)
        guard connectivity.isConnected else { return }
        ReviewScheduleService.fetchSummary(userId: userId, questionIdPrefix: questionIdPrefix) { fetched in
            guard reviewRequestID == requestID, authManager.currentUserId == userId else { return }
            if questionIdPrefix != nil {
                summary = fetched
                ReviewScheduleService.fetchDueQuestions(userId: userId, questionIdPrefix: questionIdPrefix) { result in
                    guard reviewRequestID == requestID, authManager.currentUserId == userId else { return }
                    if case .success(let questions) = result { shuffledQuizList = questions }
                }
            } else {
                applyLocalReviews(userID: userId)
                summary = fetched
            }
        }
        RateManager.shared.fetchReviewWeakAreas(userId: userId) { fetched in
            guard reviewRequestID == requestID, authManager.currentUserId == userId else { return }
            weakAreas = fetched
        }
    }

    private func applyLocalReviews(userID: String) {
        summary = ReviewScheduleService.localSummary(userId: userID)
        scheduleRecords = LocalReviewScheduleStore.records(userID: userID)
        shuffledQuizList = LocalReviewScheduleStore.dueQuestions(userID: userID)
        courseStore.importQuestions(shuffledQuizList)
        loadErrorMessage = nil
        isDataLoaded = true
    }

    // MARK: Review sessions

    private func startAllReviews() {
        guard previewSnapshot == nil, !shuffledQuizList.isEmpty else { return }
        isFocusedReview = false
        activeQuizList = availableReviews
        guard !activeQuizList.isEmpty else { presentedSheet = .premium; return }
        beginReviewSession()
    }

    private func startFocusedReview(_ area: ReviewWeakArea) {
        guard appState.isSubscribed else { presentedSheet = .premium; return }
        let focusedQuestions = shuffledQuizList.filter { $0.sourceQuizLevel == area.quizLevel.description }
        guard !focusedQuestions.isEmpty else {
            focusAlertMessage = "今日の復習には\(area.displayName)の問題がありません。通常の問題演習で分野別に学習できます。"
            return
        }
        isFocusedReview = true
        activeQuizList = Array(focusedQuestions.shuffled().prefix(10))
        beginReviewSession()
    }

    private func beginReviewSession() {
        if let userId = authManager.currentUserId {
            reviewBaseline = ReviewSessionBaseline(records: LocalReviewScheduleStore.records(userID: userId), startedAt: Date())
        }
        isRunningQuiz = true
    }

    /// Logs today's review from the schedule change, so the home can tell "all done" from "nothing scheduled".
    /// Runs once per session: from the result screen, or when the quiz closes early.
    @discardableResult
    private func finishReviewSession() -> ReviewSessionOutcome? {
        guard let baseline = reviewBaseline, let userId = authManager.currentUserId else { return lastOutcome }
        reviewBaseline = nil
        let outcome = ReviewSessionOutcome.make(before: baseline.records,
                                                after: LocalReviewScheduleStore.records(userID: userId),
                                                sessionStart: baseline.startedAt)
        if let activity = outcome.activity(completedAt: Date()) {
            ReviewDailyActivityLog.record(activity, userID: userId)
        }
        lastOutcome = outcome
        return outcome
    }

    /// The outcome plus the next recommendation, computed from the stores as they are after the quiz.
    private func loadReviewResult() -> ReviewSessionResult? {
        guard let outcome = finishReviewSession(), let userId = authManager.currentUserId else { return nil }
        let records = LocalReviewScheduleStore.records(userID: userId)
        let summary = ReviewScheduleService.localSummary(userId: userId)
        let input = makeHomeInput(summary: summary,
                                  dueQuestions: LocalReviewScheduleStore.dueQuestions(userID: userId),
                                  records: records, freeRemaining: ReviewAccessPolicy.remaining(userID: userId),
                                  activities: ReviewDailyActivityLog.today(userID: userId), now: Date())
        return ReviewSessionResult(outcome: outcome,
                                   next: ReviewHomeResolver.resolve(input).cards.first(where: \.isActionable),
                                   masteredTotal: summary.masteredCount,
                                   freeRemaining: appState.isSubscribed ? nil : input.freeRemaining)
    }

    @ViewBuilder
    private func reviewStatusView(
        icon: String,
        title: String,
        message: String,
        buttonTitle: String,
        buttonAction: @escaping () -> Void
    ) -> some View {
        VStack(spacing: 20) {
            Image(systemName: icon)
                .font(.largeTitle.weight(.semibold))
                .foregroundStyle(Color("loading"))

            Text(title)
                .font(.title2.bold())
                .foregroundColor(Color("fontGray"))

            Text(message)
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .lineSpacing(5)

            Button(buttonTitle, action: buttonAction)
                .buttonStyle(RecoveryPrimaryButtonStyle(tint: .review))
        }
        .padding(28)
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 24))
        .shadow(color: .black.opacity(0.12), radius: 16, y: 8)
    }
}

private struct ReviewSessionBaseline {
    let records: [LocalScheduledReview]
    let startedAt: Date
}

private enum ReviewHomeSheet: String, Identifiable {
    case mastered, premium, guide
    var id: String { rawValue }
}

private struct MasteredAnswersView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var connectivity: ConnectivityMonitor
    @ObservedObject var store: WeaknessCourseStore
    @ObservedObject private var authManager = AuthManager.shared
    let previewQuestions: [MasteredReviewQuestion]?
    @State private var questions: [MasteredReviewQuestion] = []
    @State private var isLoading = true
    @State private var loadFailed = false
    @State private var requestID = UUID()

    var body: some View {
        NavigationStack {
            List {
                Section("マスターしたテーマ · \(store.masteredTopics.count)件") {
                    if store.masteredTopics.isEmpty {
                        Text("練習と、日を空けた2回のおさらいに正解すると記録されます。")
                            .font(.subheadline).foregroundStyle(.secondary)
                    }
                    ForEach(store.masteredTopics) { topic in
                        DisclosureGroup {
                            Text(topic.lesson).font(.subheadline)
                        } label: {
                            VStack(alignment: .leading, spacing: 5) {
                                Label(topic.title, systemImage: topic.symbol).font(.headline)
                                if let date = store.state.cloud.progress[topic.id]?.masteredAt {
                                    Text(date.formatted(date: .abbreviated, time: .omitted))
                                        .font(.caption).foregroundStyle(.secondary)
                                }
                            }
                        }
                    }
                }
                Section("克服した問題" + (isLoading || loadFailed ? "" : " · \(questions.count)問")) {
                    if isLoading {
                        SlimeInlineLoadingView(message: "問題の記録を読み込み中…")
                    } else if loadFailed {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("問題の記録を読み込めませんでした。通信環境を確認してください。")
                                .font(.subheadline).foregroundStyle(.secondary)
                            Button("もう一度試す", action: load)
                        }
                    } else if questions.isEmpty {
                        Text("翌日・正解から3日後・正解から7日後の解き直しをクリアすると記録されます。")
                            .font(.subheadline).foregroundStyle(.secondary)
                    }
                    ForEach(questions) { question in
                        VStack(alignment: .leading, spacing: 8) {
                            Text(question.question).font(.subheadline)
                            Label(question.masteredAt.formatted(date: .abbreviated, time: .omitted),
                                  systemImage: "checkmark.seal.fill")
                                .font(.caption).foregroundStyle(.secondary)
                        }
                        .padding(.vertical, 6)
                    }
                }
            }
            .navigationTitle("克服図鑑")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("閉じる") { dismiss() } }
            }
        }
        .task(id: authManager.currentUserId) { load() }
    }

    private func load() {
        let request = UUID()
        requestID = request
        questions = []
        loadFailed = false
        if let previewQuestions {
            questions = previewQuestions
            isLoading = false
            return
        }
        guard let userId = authManager.currentUserId else {
            isLoading = false
            loadFailed = true
            return
        }
        questions = ReviewScheduleService.localMasteredQuestions(userId: userId)
        guard connectivity.isConnected else { isLoading = false; return }
        isLoading = questions.isEmpty
        ReviewScheduleService.fetchMasteredQuestions(userId: userId) { result in
            guard requestID == request, authManager.currentUserId == userId else { return }
            switch result {
            case .success(let fetched): questions = fetched
            case .failure: loadFailed = questions.isEmpty
            }
            isLoading = false
        }
    }
}

/// Injected snapshots keep recovery previews independent of account data and Firebase.
struct WeaknessReviewSnapshot {
    let summary: ReviewScheduleSummary
    let questions: [QuizQuestion]
    let mastered: [MasteredReviewQuestion]
    var freeRemaining = ReviewAccessPolicy.dailyFreeLimit
    /// Due questions one correct answer from mastery; the first ones in `questions`.
    var finalStageCount = 0
    var todayActivities: [ReviewDailyActivity] = []
    var upcomingReviewDates: [Date] = []
    var weakAreas: [ReviewWeakArea] = []

#if DEBUG
    static func scenario(_ scenario: ReviewHomePreviewScenario, now: Date = Date()) -> Self {
        let day: TimeInterval = 86400
        func questions(_ count: Int) -> [QuizQuestion] {
            ITPassportQuestionBank.all.prefix(count).enumerated().map { index, question in
                var value = question
                value.id = "scheduled_local_preview\(index)"
                return value
            }
        }
        func summary(due: Int, total: Int, next: Date?, mastered: Int = 12, streak: Int = 4) -> ReviewScheduleSummary {
            ReviewScheduleSummary(dueCount: due, totalCount: total, nextReviewDate: next, masteredCount: mastered, reviewStreak: streak)
        }
        func review(answered: Int, correct: Int, mastered: Int) -> ReviewDailyActivity {
            ReviewDailyActivity(kind: .review, topicID: nil, answeredCount: answered, correctCount: correct,
                                masteredCount: mastered, completedAt: now.addingTimeInterval(-3600))
        }
        let masteredQuestions = [MasteredReviewQuestion(id: "preview-mastered", question: "バックアップの目的は？",
            explanation: "データを復元できるようにするためです。", masteredAt: now, sourceQuizLevel: nil)]
        let weakAreas = [ReviewWeakArea(quizLevel: .network, accuracy: 42, answerCount: 30),
                         ReviewWeakArea(quizLevel: .security, accuracy: 55, answerCount: 24),
                         ReviewWeakArea(quizLevel: .database, accuracy: 71, answerCount: 12)]
        var snapshot: Self
        switch scenario {
        case .continueTheme:
            snapshot = Self(summary: summary(due: 3, total: 6, next: now + day), questions: questions(3),
                            mastered: masteredQuestions, finalStageCount: 1,
                            upcomingReviewDates: [now + day, now + day, now + 3 * day])
        case .reviewDue:
            snapshot = Self(summary: summary(due: 7, total: 9, next: now + 2 * day, streak: 3), questions: questions(7),
                            mastered: masteredQuestions, finalStageCount: 2, upcomingReviewDates: [now + 2 * day, now + 2 * day])
        case .themeCheckup:
            snapshot = Self(summary: summary(due: 0, total: 4, next: now + day), questions: [],
                            mastered: masteredQuestions, upcomingReviewDates: [now + day, now + day, now + 4 * day])
        case .freeLimit, .freeLimitWithTheme:
            snapshot = Self(summary: summary(due: 3, total: 6, next: now + 3 * day, mastered: 15, streak: 5), questions: questions(3),
                            mastered: masteredQuestions, freeRemaining: 0, finalStageCount: 1,
                            todayActivities: [review(answered: 5, correct: 4, mastered: 1)],
                            upcomingReviewDates: [now + 3 * day])
        case .firstRun:
            snapshot = Self(summary: summary(due: 0, total: 0, next: nil, mastered: 0, streak: 0), questions: [], mastered: [])
        case .allClear:
            snapshot = Self(summary: summary(due: 0, total: 5, next: now + day, mastered: 14, streak: 5), questions: [],
                            mastered: masteredQuestions,
                            todayActivities: [review(answered: 5, correct: 4, mastered: 2),
                                              ReviewDailyActivity(kind: .themeCheckup, topicID: "dns", answeredCount: 2,
                                                                  correctCount: 2, masteredCount: 0, completedAt: now,
                                                                  checkupNumber: 1)],
                            upcomingReviewDates: [now + day, now + day])
        case .nothingToday:
            snapshot = Self(summary: summary(due: 0, total: 3, next: now + day, mastered: 14, streak: 0), questions: [],
                            mastered: masteredQuestions, upcomingReviewDates: [now + day, now + day])
        case .afterReview:
            snapshot = Self(summary: summary(due: 0, total: 4, next: now + 3 * day, mastered: 14), questions: [],
                            mastered: masteredQuestions, freeRemaining: 0,
                            todayActivities: [review(answered: 5, correct: 4, mastered: 2)],
                            upcomingReviewDates: [now + 3 * day, now + 3 * day])
        }
        if scenario != .firstRun { snapshot.weakAreas = weakAreas }
        return snapshot
    }
#endif
}

#if DEBUG
struct QuizIncorrectAnswerListView_Previews: PreviewProvider {
    static var previews: some View {
        ForEach(ReviewHomePreviewScenario.allCases, id: \.self) { scenario in
            ForEach([false, true], id: \.self) { subscribed in
                WeaknessCoursePreview(scenario: scenario, subscribed: subscribed)
                    .environmentObject(ConnectivityMonitor.shared)
                    .previewDisplayName("\(scenario.title) · \(subscribed ? "プレミアム" : "無料")")
            }
        }
        WeaknessCoursePreview(scenario: .reviewDue, subscribed: false)
            .environmentObject(ConnectivityMonitor.shared)
            .previewDevice(PreviewDevice(rawValue: "iPhone SE (3rd generation)"))
            .previewDisplayName("iPhone SE · 解き直し")
        WeaknessCoursePreview(scenario: .reviewDue, subscribed: false)
            .environmentObject(ConnectivityMonitor.shared)
            .environment(\.dynamicTypeSize, .accessibility2)
            .previewDisplayName("大きな文字 · 解き直し")
    }
}
#endif
