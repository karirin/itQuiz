//
//  QuizIncorrectAnswerListView.swift
//  it
//
//  Created by hashimo ryoya on 2023/12/28.
//

import SwiftUI
import Firebase

struct QuizITIncorrectAnswerListView: View {
    @Binding var isPresenting: Bool
    @State var shuffledQuizList: [QuizQuestion] = []
    @State var isDataLoaded = false // データロード状態の追跡

    private var authManager = AuthManager.shared
    private var audioManager = AudioManager.shared
    @StateObject var sharedInterstitial = Interstitial()
    @EnvironmentObject private var appState: AppState
    @EnvironmentObject private var connectivity: ConnectivityMonitor
    @State private var showingPremium = false
    /// ホームからは今日の進捗を記録。無料は全入口共通で5問、加入者は全問。
    private let isDailyReview: Bool
    private let onDailyReviewCompleted: () -> Void
    private let learningContext: LearningEntryContext?
    @State private var dailyReviewDayKey: String?
    @State private var dailyReviewUserId: String?
    @State private var dailyReviewQuestionCount = 0
    
    init(isPresenting: Binding<Bool>, isDailyReview: Bool = false, learningContext: LearningEntryContext? = nil, onDailyReviewCompleted: @escaping () -> Void = {}) {
            self._isPresenting = isPresenting
            self.isDailyReview = isDailyReview
            self.onDailyReviewCompleted = onDailyReviewCompleted
            self.learningContext = learningContext
        }

    var body: some View {
        VStack{
            if isDataLoaded && shuffledQuizList.isEmpty {
                VStack(spacing: 18) {
                    Image(systemName: "checkmark.seal.fill").font(.largeTitle).foregroundStyle(.green)
                    Text(freeAllowanceExhausted ? "今日の無料復習は完了です" : "いま復習できる問題はありません").font(.title3.bold())
                    Text(freeAllowanceExhausted ? "無料復習は、すべての入口を合わせて1日5問。明日はまた5問復習できます。" : "問題演習で間違えた問題を保存します。回答済みの無料復習は、翌日にまた取り組めます。")
                        .font(.subheadline).foregroundStyle(.secondary).multilineTextAlignment(.center)
                    if !appState.isSubscribed, let userID = authManager.currentUserId,
                       LocalIncorrectAnswerStore.count(userId: userID, category: .itPassport) > 0 {
                        Button("プレミアムで全問題を復習する") { showingPremium = true }
                            .buttonStyle(.borderedProminent)
                    }
                    Button("戻る") { isPresenting = false }
                }.padding(24)
            } else if isDataLoaded {
                // データがロードされたらQuizViewを表示
                QuizView(
                    quizzes: shuffledQuizList,
                    quizLevel: .incorrectITAnswer,
                    isFreeReviewPreview: !appState.isSubscribed,
                    onAnswered: dailyReviewAnswerRecorder,
                    learningContext: learningContext,
                    authManager: authManager,
                    audioManager: audioManager,
                    isPresenting: $isPresenting,
                    interstitial: sharedInterstitial
                )
            } else {
                SlimeFullScreenLoadingView()
            }
        }
        .onAppear {
            if !isDataLoaded { loadIncorrectAnswers() }
        }
        .sheet(isPresented: $showingPremium, onDismiss: {
            Task { @MainActor in
                await appState.refreshSubscriptionState()
                loadIncorrectAnswers()
            }
        }) {
            PreView(audioManager: audioManager, source: .review(incorrectCount: authManager.currentUserId.map {
                LocalIncorrectAnswerStore.count(userId: $0, category: .itPassport)
            } ?? 0))
        }
    }

    private var freeAllowanceExhausted: Bool {
        guard !appState.isSubscribed, let userID = authManager.currentUserId else { return false }
        return ReviewAccessPolicy.remaining(userID: userID) == 0
    }

    private var dailyReviewAnswerRecorder: ((QuizQuestion) -> Void)? {
        guard isDailyReview, let userId = dailyReviewUserId, let dayKey = dailyReviewDayKey else { return nil }
        return { question in
            guard authManager.currentUserId == userId else { return }
            let completedPlan = DailyReviewStore.recordAnswer(key: question.dailyReviewKey, userId: userId, expectedDayKey: dayKey)
            if completedPlan || (!appState.isSubscribed && ReviewAccessPolicy.remaining(userID: userId) == 0) {
                if let context = learningContext {
                    GrowthAnalytics.logDailyLearningComplete(context: context, questionCount: dailyReviewQuestionCount)
                }
                self.onDailyReviewCompleted()
            }
        }
    }

    private func loadIncorrectAnswers() {
        guard let userId = authManager.currentUserId else {
            isDataLoaded = true
            return
        }

        LocalIncorrectAnswerStore.migrateSchedules(userId: userId)
        let localQuestions = LocalIncorrectAnswerStore.questions(
            userId: userId,
            category: .itPassport
        )

        guard appState.isSubscribed else {
            present(localQuestions, userId: userId, limit: nil)
            return
        }

        // 加入済みなら通信状態にかかわらず、保存済み誤答を全問利用できる。
        guard connectivity.isConnected else {
            present(localQuestions, userId: userId, limit: nil)
            return
        }

        fetchITIncorrectAnswers(userId: userId) { remoteQuestions in
            guard authManager.currentUserId == userId else { return }
            self.present(
                LocalIncorrectAnswerStore.merged(local: localQuestions, remote: remoteQuestions),
                userId: userId,
                limit: nil
            )
        }
    }

    private func present(_ questions: [QuizQuestion], userId: String, limit: Int?) {
        let questions = LocalReviewScheduleStore.excludingMastered(questions, userID: userId)
        if isDailyReview {
            shuffledQuizList = dailyReviewQuestions(from: questions, userId: userId)
        } else if let limit {
            shuffledQuizList = Array(questions.shuffled().prefix(limit))
        } else {
            shuffledQuizList = questions.shuffled()
        }
        shuffledQuizList = ReviewAccessPolicy.available(shuffledQuizList, userID: userId, subscribed: appState.isSubscribed)
        dailyReviewQuestionCount = shuffledQuizList.count
        isDataLoaded = true
    }

    /// 今日の出題を固定し、途中でやめた場合は未回答の問題だけを出題する。
    private func dailyReviewQuestions(from questions: [QuizQuestion], userId: String) -> [QuizQuestion] {
        if !appState.isSubscribed {
            let eligible = ReviewAccessPolicy.available(questions, userID: userId, subscribed: false)
            let previous = DailyReviewStore.todayState(DailyReviewStore.load(userId: userId), now: Date())
            let answered = previous?.answeredKeys ?? []
            let state = DailyReviewState(dayKey: DailyReviewStore.dayKey(for: Date()),
                questionKeys: answered + eligible.map(\.dailyReviewKey), answeredKeys: answered)
            DailyReviewStore.save(state, userId: userId)
            dailyReviewDayKey = state.dayKey
            dailyReviewUserId = userId
            return eligible
        }
        let questionsByKey = Dictionary(
            questions.map { ($0.dailyReviewKey, $0) },
            uniquingKeysWith: { first, _ in first }
        )
        var state = DailyReviewStore.startOrResume(
            state: DailyReviewStore.load(userId: userId),
            shuffledAvailableKeys: questionsByKey.keys.shuffled(),
            now: Date(),
            questionLimit: appState.isSubscribed ? questionsByKey.count : DailyReviewStore.dailyQuestionLimit
        )
        if appState.isSubscribed {
            state.questionKeys = Array(Set(state.questionKeys).union(questionsByKey.keys)).sorted()
        }
        // 別の入口で克服した問題は既存の進捗表示と同じく回答済みとして扱う。
        let resolvedKeys = state.questionKeys.filter { questionsByKey[$0] == nil }
        state.answeredKeys = Array(Set(state.answeredKeys).union(resolvedKeys))
        dailyReviewDayKey = state.dayKey
        dailyReviewUserId = userId
        dailyReviewQuestionCount = state.questionKeys.count
        DailyReviewStore.save(state, userId: userId)
        return DailyReviewStore
            .remainingKeys(state: state, availableKeys: Array(questionsByKey.keys))
            .compactMap { questionsByKey[$0] }
    }
    }

extension QuizQuestion {
    var dailyReviewKey: String {
        DailyReviewStore.questionKey(
            question: question,
            choices: choices,
            correctAnswerIndex: correctAnswerIndex
        )
    }
}
    
func fetchITIncorrectAnswers(userId: String, completion: @escaping ([QuizQuestion]) -> Void) {
    let ref = Database.database().reference().child("IncorrectITAnswers").child(userId)
    ref.observeSingleEvent(of: .value) { snapshot in
        var quizList = [QuizQuestion]()
        
        for child in snapshot.children {
            if let childSnapshot = child as? DataSnapshot,
               let dict = childSnapshot.value as? [String: Any],
               let question = dict["quizQuestion"] as? String,
               let choices = dict["choices"] as? [String],
               let correctAnswerIndex = dict["correctAnswerIndex"] as? Int,
               let explanation = dict["explanation"] as? String {
                let quizId = childSnapshot.key // クイズIDを取得
                let quiz = QuizQuestion(id: quizId, question: question, choices: choices, correctAnswerIndex: correctAnswerIndex, explanation: explanation)
                quizList.append(quiz)
            }
        }
        
        completion(quizList)
    } withCancel: { _ in
        // 通信・権限エラーでも端末内の誤答で復習を続けられるようにする。
        completion([])
    }
}


struct QuizITIncorrectAnswerListView_Previews: PreviewProvider {
    static var previews: some View {
        QuizITIncorrectAnswerListView(isPresenting: .constant(false))
    }
}
