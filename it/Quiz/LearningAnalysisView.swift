import SwiftUI

struct LearningAnalysisHeader: View {
    var body: some View {
        Text("学習分析")
            .font(.system(size: 18, weight: .bold))
            .foregroundStyle(.primary)
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(.ultraThinMaterial)
    }
}

struct LearningAnalysisView: View {
    @ObservedObject var authManager = AuthManager.shared
    let isPremium: Bool
    let onUpgrade: () -> Void
    @State private var exam: AccuracyExam = .it
    @State private var history: LearningHistory?
    @State private var reviews: [QuizQuestion]?
    @State private var reviewsExam: AccuracyExam?
    @State private var historyFailed = false
    @State private var reviewsFailed = false
    @State private var requestID = UUID()
    @State private var session: AnalysisPracticeSession?
    @State private var now = Date()
    @Environment(\.scenePhase) private var scenePhase

    private struct LoadKey: Hashable {
        let exam: AccuracyExam
        let isPremium: Bool
    }

    var body: some View {
        VStack(spacing: 0) {
            Text(isPremium ? "得意を伸ばして、次の一歩を見つけよう" : "今週の成長と、次に学ぶヒントを見つけよう")
                .font(.system(size: 15, weight: .medium))
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 20)
                .padding(.top, 16)

            Picker("試験を選択", selection: $exam) {
                ForEach(AccuracyExam.allCases) { Text($0.title).tag($0) }
            }
            .pickerStyle(.segmented)
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .accessibilityIdentifier("accuracy.examPicker")

            ScrollView(showsIndicators: false) {
                VStack(spacing: 16) {
                    if let history, let userID = authManager.currentUserId {
                        if historyFailed {
                            Label("更新できませんでした。前回の記録を表示しています。", systemImage: "wifi.exclamationmark")
                                .font(.caption).foregroundStyle(.secondary)
                            Button("再読み込み") { Task { await load() } }
                        }
                        LearningAnalysisDashboard(
                            exam: exam, history: history, reviews: reviewsExam == exam ? reviews : nil,
                            reviewsFailed: reviewsFailed, userID: userID, now: now, isPremium: isPremium,
                            onPractice: startPractice,
                            onReview: {
                                guard isPremium, reviewsExam == exam, let reviews, !reviews.isEmpty else { return }
                                session = AnalysisPracticeSession(exam: exam, area: nil,
                                                                  questions: Array(reviews.shuffled().prefix(5)))
                            },
                            onRetry: { Task { await load() } }, onUpgrade: onUpgrade
                        )
                        .id(exam)
                    } else if historyFailed {
                        SlimeErrorView(title: "学習記録を読み込めませんでした",
                                       message: "通信状況を確認して、もう一度お試しください。") {
                            Task { await load() }
                        }
                        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                        .padding(.top, 16)
                    } else {
                        SlimeCardLoadingView(message: "学習記録を読み込み中")
                            .padding(.top, 40)
                    }
                }
                .padding(.horizontal, 20).padding(.bottom, 28)
                .frame(maxWidth: 640).frame(maxWidth: .infinity)
            }
            .refreshable { await load() }
        }
        .tint(exam.accent)
        .task(id: LoadKey(exam: exam, isPremium: isPremium)) { await load() }
        .onChange(of: isPremium) { premium in
            if !premium { session = nil }
        }
        .onChange(of: scenePhase) { phase in
            if phase == .active { Task { await load() } }
        }
        .fullScreenCover(item: $session, onDismiss: { Task { await load() } }) { session in
            AnalysisPracticeView(session: session)
        }
    }

    private func startPractice(_ area: AccuracyArea) {
        guard isPremium else { return }
        let questions = AnalysisQuestionBank.questions(exam: exam, area: area)
        guard !questions.isEmpty else { return }
        session = AnalysisPracticeSession(exam: exam, area: area, questions: Array(questions.shuffled().prefix(5)))
    }

    @MainActor
    private func load() async {
        let request = UUID()
        requestID = request
        let requestedExam = exam
        let requestedPremium = isPremium
        guard let userID = authManager.currentUserId, !userID.isEmpty else {
            history = nil
            reviews = nil
            return
        }
        reviews = nil
        reviewsFailed = false
        historyFailed = false
        async let newHistory = LearningAnalyticsService.fetchHistory(userID: userID)
        async let newReviews = requestedPremium
            ? LearningAnalyticsService.fetchReviews(userID: userID, exam: requestedExam) : nil
        do {
            let value = try await newHistory
            guard !Task.isCancelled, requestID == request, authManager.currentUserId == userID else { return }
            history = value
            now = Date()
        } catch {
            guard !Task.isCancelled, requestID == request, authManager.currentUserId == userID else { return }
            historyFailed = true
        }
        do {
            let value = try await newReviews
            guard !Task.isCancelled, requestID == request, authManager.currentUserId == userID,
                  requestedPremium == isPremium else { return }
            reviews = value
            reviewsExam = requestedExam
        } catch {
            guard !Task.isCancelled, requestID == request, authManager.currentUserId == userID,
                  requestedPremium == isPremium else { return }
            reviewsFailed = true
        }
    }
}

struct LearningAnalysisDashboard: View {
    let exam: AccuracyExam
    let history: LearningHistory
    let reviews: [QuizQuestion]?
    let reviewsFailed: Bool
    let userID: String
    let now: Date
    let isPremium: Bool
    let onPractice: (AccuracyArea) -> Void
    let onReview: () -> Void
    let onRetry: () -> Void
    let onUpgrade: () -> Void
    @State private var period: LearningPeriod = .all

    private var periodCounts: [String: LearningCount] { history.counts(exam: exam, period: period, now: now) }
    private var recommendation: LearningRecommendation {
        .make(exam: exam, counts: usesRecentRecommendation ? history.counts(exam: exam, period: .month, now: now) : history.totals)
    }
    private var usesRecentRecommendation: Bool {
        let recent = history.counts(exam: exam, period: .month, now: now)
        return exam.areaKeys.allSatisfy { (recent[$0]?.answers ?? 0) >= 10 }
    }
    private var recommendationSource: String {
        usesRecentRecommendation ? "直近30日の回答から" : "これまでの回答から"
    }

    var body: some View {
        if isPremium {
            premiumContent
        } else {
            VStack(spacing: 16) {
                AnalysisWeekCard(exam: exam, history: history, userID: userID, now: now)
                AnalysisRecentAccuracyCard(exam: exam, history: history, now: now)
                AnalysisInsightPreviewCard(exam: exam, recommendation: recommendation,
                                           source: recommendationSource, onUpgrade: onUpgrade)
            }
        }
    }

    private var premiumContent: some View {
        VStack(spacing: 16) {
            AnalysisRecommendationCard(recommendation: recommendation,
                                       source: recommendationSource,
                                       accent: exam.accent, gradient: exam.learningGradient) {
                onPractice(recommendation.area)
            }
            AnalysisWeekCard(exam: exam, history: history, userID: userID, now: now)
            AnalysisReviewCard(pendingCount: reviews?.count, correctCount: history.totals[exam.reviewKey]?.correct ?? 0,
                               failed: reviewsFailed, accent: exam.accent, gradient: exam.learningGradient, onReview: onReview, onRetry: onRetry)

            VStack(alignment: .leading, spacing: 12) {
                Text("理解度の変化").font(.title3.weight(.bold))
                Picker("集計期間", selection: $period) {
                    ForEach(LearningPeriod.allCases) { Text($0.title).tag($0) }
                }
                .pickerStyle(.segmented)
                .accessibilityIdentifier("analysis.periodPicker")

                if period != .all {
                    if let change = history.change(exam: exam, period: period, now: now) {
                        Label(String(format: "前の%d日間から %+.1fポイント", period.rawValue, change),
                              systemImage: change > 0 ? "arrow.up.right" : change < 0 ? "arrow.down.right" : "arrow.right")
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(change >= 0 ? exam.accent : Color.secondary)
                    } else {
                        Text("前の同じ日数との比較は、両期間の記録が揃い、それぞれ10問以上になると表示します。")
                            .font(.caption).foregroundStyle(.secondary)
                    }
                    Text("期間別の正答率は、この機能の追加後に記録された回答が対象です。以前の成績は「累計」で確認できます。")
                        .font(.caption).foregroundStyle(.secondary)
                }
                AccuracyDashboard(exam: exam, quizData: periodCounts.mapValues { QuizData(answer: $0.answers, correct: $0.correct) },
                                  periodTitle: period.title, showsLearningHint: false, onPractice: onPractice)
                    .id(period)
            }
            AnalysisActivityCard(exam: exam, history: history, now: now)
        }
    }
}

struct AnalysisPracticeSession: Identifiable {
    let id = UUID()
    let exam: AccuracyExam
    let area: AccuracyArea?
    let questions: [QuizQuestion]
    var level: QuizLevel { area.map { exam.level(for: $0) } ?? exam.reviewLevel }
}

private struct AnalysisPracticeView: View {
    let session: AnalysisPracticeSession
    @State private var isPresenting = true
    @StateObject private var interstitial = Interstitial()
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationView {
            QuizView(quizzes: session.questions, quizLevel: session.level,
                     authManager: AuthManager.shared, audioManager: AudioManager.shared,
                     isPresenting: $isPresenting, interstitial: interstitial)
                .navigationBarBackButtonHidden(true)
        }
        .navigationViewStyle(.stack)
        .onChange(of: isPresenting) { if !$0 { dismiss() } }
    }
}

/// Reuse the shipped question banks so practice and analysis always refer to the same areas.
enum AnalysisQuestionBank {
    static func questions(exam: AccuracyExam, area: AccuracyArea) -> [QuizQuestion] {
        let binding = Binding.constant(false)
        switch (exam, area) {
        case (.it, .basic): return ITPassportQuestionBank.basic
        case (.it, .strategy): return ITPassportQuestionBank.strategy
        case (.it, .technology): return ITPassportQuestionBank.technology
        case (.it, .management): return ITPassportQuestionBank.management
        case (.info, .basic): return QuizInfoBasicListView(isPresenting: binding).quizBeginnerList
        case (.info, .strategy): return QuizInfoStrategyListView(isPresenting: binding).quizBeginnerList
        case (.info, .technology): return QuizInfoTechnologyListView(isPresenting: binding).quizBeginnerList
        case (.info, .management): return QuizInfoManagementListView(isPresenting: binding).quizBeginnerList
        case (.applied, .basic): return QuizAppliedBasicListView(isPresenting: binding).quizBeginnerList
        case (.applied, .strategy): return QuizAppliedStrategyListView(isPresenting: binding).quizBeginnerList
        case (.applied, .technology): return QuizAppliedTechnologyListView(isPresenting: binding).quizBeginnerList
        case (.applied, .management): return QuizAppliedManagementListView(isPresenting: binding).quizBeginnerList
        }
    }
}

#if DEBUG
/// Local fixture for layout and navigation checks. Launch with -ForceOfflineMode to exercise quizzes without writes.
struct LearningAnalysisPreview: View {
    var isPremium = true
    var showsEmptyHistory = false
    @State private var exam: AccuracyExam = .it
    @State private var session: AnalysisPracticeSession?
    @State private var showsPremium = false
    private let now = Date()
    private var hasPremium: Bool { isPremium && !ProcessInfo.processInfo.arguments.contains("-AnalysisFree") }
    private var isEmpty: Bool { showsEmptyHistory || ProcessInfo.processInfo.arguments.contains("-AnalysisEmpty") }
    private var history: LearningHistory {
        guard !isEmpty else { return LearningHistory() }
        var result = LearningHistory()
        for (index, day) in LearningDates.days(ending: now, count: 40).enumerated() {
            let key = LearningDates.key(day)
            for exam in AccuracyExam.allCases {
                for area in AccuracyArea.allCases {
                    let level = exam.key(for: area)
                    let answers = index % 6 == 0 ? 0 : 5
                    let correct = answers == 0 ? 0 : area == .technology ? 2 : index < 25 ? 3 : 4
                    let count = LearningCount(answers: answers, correct: correct)
                    result.daily[key, default: [:]][level] = count
                    result.answers[level, default: [:]][key] = answers
                    result.totals[level, default: LearningCount()] = result.totals[level, default: LearningCount()] + count
                }
                result.daily[key, default: [:]][exam.reviewKey] = LearningCount(answers: 2, correct: 1)
                result.answers[exam.reviewKey, default: [:]][key] = 2
                result.totals[exam.reviewKey, default: LearningCount()] = result.totals[exam.reviewKey, default: LearningCount()] + LearningCount(answers: 2, correct: 1)
            }
        }
        return result
    }
    var body: some View {
        VStack(spacing: 0) {
            LearningAnalysisHeader()
            Text(hasPremium ? "得意を伸ばして、次の一歩を見つけよう" : "今週の成長と、次に学ぶヒントを見つけよう")
                .font(.system(size: 15, weight: .medium))
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 20)
                .padding(.top, 16)
            Picker("試験を選択", selection: $exam) {
                ForEach(AccuracyExam.allCases) { Text($0.title).tag($0) }
            }.pickerStyle(.segmented).padding(.horizontal, 20).padding(.vertical, 12)
                .accessibilityIdentifier("accuracy.examPicker")
            ScrollView(showsIndicators: false) {
                LearningAnalysisDashboard(exam: exam, history: history, reviews: isEmpty ? [] : [sampleQuestion],
                                          reviewsFailed: ProcessInfo.processInfo.arguments.contains("-AnalysisReviewError"),
                                          userID: "analysis-local-preview", now: now, isPremium: hasPremium,
                                          onPractice: { area in
                    session = AnalysisPracticeSession(exam: exam, area: area,
                                                      questions: Array(AnalysisQuestionBank.questions(exam: exam, area: area).shuffled().prefix(5)))
                }, onReview: {
                    session = AnalysisPracticeSession(exam: exam, area: nil, questions: [sampleQuestion])
                }, onRetry: {}, onUpgrade: { showsPremium = true })
                .id(exam).padding(.horizontal, 20).padding(.bottom, 30)
                .frame(maxWidth: 640).frame(maxWidth: .infinity)
            }
        }
        .background { LearningModeGlassBackground() }.tint(exam.accent)
        .fullScreenCover(item: $session) { AnalysisPracticeView(session: $0) }
        .fullScreenCover(isPresented: $showsPremium) {
            PreView(audioManager: AudioManager.shared, source: .analysis)
        }
    }
    private var sampleQuestion: QuizQuestion {
        QuizQuestion(question: "情報セキュリティの三要素に含まれるものはどれか？",
                     choices: ["機密性", "収益性", "独創性", "娯楽性"], correctAnswerIndex: 0,
                     explanation: "情報セキュリティの三要素は機密性・完全性・可用性です。")
    }
}

#Preview("学習分析") {
    LearningAnalysisPreview()
        .environmentObject(AppState())
        .environmentObject(ConnectivityMonitor.shared)
}

#Preview("無料の学習分析") {
    LearningAnalysisPreview(isPremium: false)
        .environmentObject(AppState())
        .environmentObject(ConnectivityMonitor.shared)
}

#Preview("無料・学習記録なし") {
    LearningAnalysisPreview(isPremium: false, showsEmptyHistory: true)
        .environmentObject(AppState())
        .environmentObject(ConnectivityMonitor.shared)
}
#endif
