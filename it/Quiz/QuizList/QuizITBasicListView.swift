//
//  QuizList.swift
//  it
//
//  Created by hashimo ryoya on 2023/09/16.
//

import SwiftUI

struct QuizITBasicList: View {
    @Binding var isPresenting: Bool
    let isInfiniteMode: Bool
    let isInitialDiagnostic: Bool
    let isLearningTour: Bool
    let learningContext: LearningEntryContext?
    let quizBeginnerList: [QuizQuestion] = ITPassportQuestionBank.basic
        
    @State private var shuffledQuizList: [QuizQuestion]
    @State private var dailyQuizLoaded = false
    @State private var dailyQuizDayKey: String?
    @State private var dailyQuizUserId: String?
    @State private var dailyQuizQuestionCount = 0
    private var authManager = AuthManager.shared
    private var audioManager = AudioManager.shared

    init(
        isPresenting: Binding<Bool>,
        isInfiniteMode: Bool = false,
        questionLimit: Int? = nil,
        isInitialDiagnostic: Bool = false,
        isLearningTour: Bool = false,
        learningContext: LearningEntryContext? = nil
    ) {
        _isPresenting = isPresenting
        self.isInfiniteMode = isInfiniteMode
        self.isInitialDiagnostic = isInitialDiagnostic
        self.isLearningTour = isLearningTour
        self.learningContext = learningContext
        let shuffledQuestions = quizBeginnerList.shuffled()
        if isInitialDiagnostic {
            _shuffledQuizList = State(initialValue: InitialPracticeContent.questions)
        } else if isLearningTour {
            let memoryQuestion = quizBeginnerList.first { $0.id == "it.05bd0bea3b194c62a0efef28" }
            _shuffledQuizList = State(initialValue: memoryQuestion.map { [$0] } ?? Array(quizBeginnerList.prefix(1)))
        } else if let questionLimit {
            _shuffledQuizList = State(initialValue: Array(shuffledQuestions.prefix(questionLimit)))
        } else {
            _shuffledQuizList = State(initialValue: shuffledQuestions)
        }
    }
    @StateObject var sharedInterstitial = Interstitial()
    var body: some View {
        Group {
            if learningContext?.activity == .quickQuiz && !dailyQuizLoaded {
                SlimeFullScreenLoadingView(message: "今日の3問を準備中")
            } else {
                quizContent
            }
        }
        .onAppear { prepareDailyQuizIfNeeded() }
    }

    private var quizContent: some View {
        QuizView(
            quizzes: shuffledQuizList,
            quizLevel: .itBasic,
            isInfiniteMode: isInfiniteMode,
            isInitialDiagnostic: isInitialDiagnostic,
            isLearningTour: isLearningTour,
            onAnswered: dailyQuizAnswerRecorder,
            learningContext: learningContext,
            authManager: authManager,
            audioManager: audioManager,
            isPresenting: $isPresenting,
            interstitial: sharedInterstitial
        )
    }

    private func prepareDailyQuizIfNeeded() {
        guard learningContext?.activity == .quickQuiz, !dailyQuizLoaded else { return }
        guard let userId = authManager.currentUserId else {
            shuffledQuizList = []
            dailyQuizLoaded = true
            return
        }
        let questionsByKey = Dictionary(quizBeginnerList.map { ($0.dailyReviewKey, $0) }, uniquingKeysWith: { first, _ in first })
        let state = DailyQuickQuizStore.startOrResume(userId: userId, shuffledAvailableKeys: questionsByKey.keys.shuffled())
        dailyQuizDayKey = state.dayKey
        dailyQuizUserId = userId
        dailyQuizQuestionCount = state.questionKeys.count
        shuffledQuizList = DailyReviewStore.remainingKeys(state: state, availableKeys: Array(questionsByKey.keys)).compactMap { questionsByKey[$0] }
        dailyQuizLoaded = true
    }

    private var dailyQuizAnswerRecorder: ((QuizQuestion) -> Void)? {
        guard let context = learningContext, context.activity == .quickQuiz,
              let userId = dailyQuizUserId, let dayKey = dailyQuizDayKey else { return nil }
        return { question in
            guard authManager.currentUserId == userId else { return }
            if DailyQuickQuizStore.recordAnswer(key: question.dailyReviewKey, userId: userId, expectedDayKey: dayKey) {
                GrowthAnalytics.logDailyLearningComplete(context: context, questionCount: dailyQuizQuestionCount)
            }
        }
    }
}

struct QuizITBasicList_Previews: PreviewProvider {
    static var previews: some View {
        QuizITBasicList(isPresenting: .constant(false))
    }
}
