//
//  QuizView.swift main
//  it
//
//  Created by hashimo ryoya on 2023/09/16.
//

import SwiftUI
import AVFoundation
import Firebase

struct IncorrectAnswer {
    var userId: String
    var quizQuestion: String
    var choices: [String]
    var correctAnswerIndex: Int
    var explanation: String
    var sourceQuizLevel: String? = nil
}

struct ViewPositionKey0: PreferenceKey {
    static var defaultValue: [CGRect] = []
    static func reduce(value: inout [CGRect], nextValue: () -> [CGRect]) {
        value.append(contentsOf: nextValue())
    }
}

struct ViewPositionKey1: PreferenceKey {
    static var defaultValue: [CGRect] = []
    static func reduce(value: inout [CGRect], nextValue: () -> [CGRect]) {
        value.append(contentsOf: nextValue())
    }
}

struct ViewPositionKey2: PreferenceKey {
    static var defaultValue: [CGRect] = []
    static func reduce(value: inout [CGRect], nextValue: () -> [CGRect]) {
        value.append(contentsOf: nextValue())
    }
}

struct ViewPositionKey3: PreferenceKey {
    static var defaultValue: [CGRect] = []
    static func reduce(value: inout [CGRect], nextValue: () -> [CGRect]) {
        value.append(contentsOf: nextValue())
    }
}

    struct TimerArc: Shape {
        var startAngle: Angle
        var endAngle: Angle
        
        func path(in rect: CGRect) -> Path {
            var path = Path()
            path.addArc(center: CGPoint(x: rect.midX, y: rect.midY), radius: rect.width / 2, startAngle: startAngle, endAngle: endAngle, clockwise: false)
            return path
        }
    }

struct QuizView: View {
    let quizzes: [QuizQuestion]
    let quizLevel: QuizLevel
    // `let` + 既定値だとメンバーワイズ初期化子から除外され、呼び出し側で指定できない
    var isInfiniteMode: Bool = false
    var isFreeReviewPreview: Bool = false
    var requiresPremiumReview: Bool = false
    var isInitialDiagnostic: Bool = false
    var isLearningTour: Bool = false
    @ObservedObject private var learningTour = InitialLearningTour.shared
    // 操作案内は通常の演習画面を使い、案内中の時間制限と自動進行だけを止める。
    private var isUntimedLearningSession: Bool { isInitialDiagnostic || isLearningTour }
    /// 回答（正解・不正解・わからない・時間切れ）ごとに呼ぶ。今日の復習の進捗記録に使う。
    var onAnswered: ((QuizQuestion) -> Void)? = nil
    var learningContext: LearningEntryContext? = nil
    /// Set by the recovery home: the result screen shows the review outcome and the next step.
    var reviewResultContext: ReviewResultContext? = nil
    @State private var finalStageReviewKeys: Set<String> = []
    @State private var selectedAnswerIndex: Int? = nil
    @State private var reviewSessionUserID: String?
    @State private var reviewAccessMessage: String?
    @State private var currentQuizIndex: Int = 0
    @State private var showCompletionMessage: Bool = false
    @State private var showSubFlag: Bool = false
    @State private var remainingSeconds: Int = 30
    @State private var timer: Timer? = nil
    @State private var navigateToQuizResultView: Bool = false
    @ObservedObject var authManager : AuthManager
    @ObservedObject var audioManager : AudioManager
    @State private var showModal: Bool = false
    @State private var showTutorial: Bool = false
    @State private var quizResults: [QuizResult] = []
    @State private var answerCount: Int = 0
    @State private var correctAnswerCount: Int = 0
    @State private var hasPersistedQuizStats = false
    @State private var leagueSessionId = UUID().uuidString
    @State private var hasLoggedLearningSetStart = false
    @State private var hasInitializedQuiz = false
    @State private var isQuizReady = false
    @State private var isQuizVisible = false
    @State private var hasHandledCompletion = false
    @State private var hasLoggedInitialDiagnosticStart = false
    @State private var countdownValue: Int = 3
    @State private var showCountdown: Bool = false
    @State private var playerHP: Int = 1000
    @State private var playerMaxHP: Int = 1000
    @State private var monsterHP: Int = 3000
    @State private var monsterUnderHP: Int = 30
    @State private var monsterAttack: Int = 30
    @State var showAlert: Bool = false
    @State private var userName: String = ""
    @State private var avator: [[String: Any]] = []
    @State private var monsterBackground: String = ""
    @State private var userMoney: Int = 0
    @State private var userHp: Int = 100
    @State private var userMaxHp: Int = 100
    @State private var userFlag: Int = 0
    @EnvironmentObject var appState: AppState
    @EnvironmentObject private var connectivity: ConnectivityMonitor
    @State private var avatarHp: Int = 100
    @State private var userAttack: Int = 30
    @State private var tutorialNum: Int = 0
    @State private var monsterType: Int = 0
    @State private var playerExperience: Int = 0
    @State private var playerMoney: Int = 0
    @State private var shakeEffect: Bool = false
    @State private var showAttackImage: Bool = false
    @State private var attackImpact: QuizAttackImpact?
    @State var showExplanationModal: Bool = false
    @State private var showMonsterDownImage: Bool = false
    @State private var showIncorrectBackground: Bool = false
    @State private var hasAnswered: Bool = false
    @State private var reviewUnansweredReason: ReviewUnansweredReason?
    @Binding var isPresenting: Bool
    @State var showHomeModal: Bool = false
    @State private var isSoundOn: Bool = true
    @State private var showTutorial1 = true
    @State private var showTutorial2 = false
    @State private var showTutorial3 = false
    @State private var showTutorial4 = false
    @State private var buttonRect: CGRect = .zero
    @State private var buttonRect1: CGRect = .zero
    @State private var buttonRect2: CGRect = .zero
    @State private var buttonRect3: CGRect = .zero
    @State private var tutorialPulse: Bool = false
    @State private var bubbleHeight: CGFloat = 0.0
    @State private var startTime = Date()
    @State private var endTime: Date?
    @State private var elapsedTime: TimeInterval?
    @State private var navigateToQuizResult = false
    @ObservedObject var interstitial: Interstitial
    @State private var rewardFlag: Int = 0
    @State private var comboCount: Int = 0
    @State private var comboPulse: Bool = false
    @State private var comboBurstTitle: String = ""
    @State private var comboBurstSubtitle: String = ""
    @State private var comboBurstColors: [Color] = [Color.blue, Color.cyan]
    @State private var showComboBurst: Bool = false
    /// 「別の問題で」で並べ直した問題。nil の間は呼び出し元の quizzes を使う
    @State private var replacementQuizzes: [QuizQuestion]? = nil
    @State private var sessionDuration: TimeInterval = 0
    private var activeQuizzes: [QuizQuestion] { replacementQuizzes ?? quizzes }
    
    
    var currentQuiz: QuizQuestion {
        guard activeQuizzes.indices.contains(currentQuizIndex) else {
            return QuizQuestion(
                question: "問題を読み込めませんでした",
                choices: ["終了する"],
                correctAnswerIndex: 0,
                explanation: "問題データの読み込みに失敗しました。"
            )
        }
        return activeQuizzes[currentQuizIndex]
    }

    private var initialPracticeExplanation: some View {
        InitialPracticeExplanationCard(
            question: currentQuiz,
            selectedAnswerIndex: selectedAnswerIndex,
            isLastQuestion: currentQuizIndex + 1 == activeQuizzes.count,
            isLearningTour: isLearningTour,
            onContinue: continueInitialPracticeAfterExplanation
        )
    }

    private var explanationQuizIndex: Binding<Int> {
        Binding(
            get: { currentQuizIndex },
            set: { newIndex in
                if isInfiniteMode, !activeQuizzes.isEmpty {
                    currentQuizIndex = newIndex % activeQuizzes.count
                } else {
                    currentQuizIndex = newIndex
                }
            }
        )
    }
    
    @ViewBuilder
    var body: some View {
        if activeQuizzes.isEmpty {
            emptyQuizContent
        } else {
            quizContent
        }
    }

    private var emptyQuizContent: some View {
        VStack(spacing: 24) {
            Text("問題がありません")
                .font(.system(size: 17, weight: .medium))
                .foregroundColor(Color("fontGray"))
            Button(action: {
                generateHapticFeedback()
                isPresenting = false
            }) {
                Text("戻る")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 32)
                    .padding(.vertical, 12)
                    .background(Color("purple2"))
                    .clipShape(Capsule())
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
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

    private var isDailyLearning: Bool { learningContext?.isDailyPlan == true }

    private var displayedMonsterImageName: String {
        isReviewQuiz ? "ReviewWhiteBeardMonster" : "\(quizLevel)Monster\(monsterType)"
    }

    private var quizContent: some View {
        NavigationView{
            ZStack{
                if isReviewQuiz || isInitialDiagnostic {
                    ReviewGardenBackground()
                } else {
                    Image(monsterBackground).resizable().ignoresSafeArea()
                }
                if isInitialDiagnostic {
                    InitialPracticeQuestionView(
                        question: currentQuiz, questionIndex: currentQuizIndex,
                        questionCount: activeQuizzes.count, selectedAnswerIndex: selectedAnswerIndex,
                        hasAnswered: hasAnswered,
                        answersDisabled: hasAnswered || showExplanationModal || showCompletionMessage
                            || (isLearningTour && learningTour.step != .question),
                        preservesDisabledAnswerAppearance: isLearningTour && learningTour.step == .questionIntroduction,
                        onAnswer: answerSelectionAction,
                        onUnknown: skipInitialPracticeQuestion,
                        onExit: {
                            pauseTimer()
                            if isLearningTour { learningTour.requestFinish() }
                            isPresenting = false
                        }
                    )
                    if isInitialDiagnostic {
                    NavigationLink("", destination: QuizResultView(
                        results: quizResults, authManager: authManager,
                        isPresenting: $isPresenting, navigateToQuizResultView: $navigateToQuizResultView,
                        playerExperience: playerExperience, playerMoney: playerMoney,
                        elapsedTime: 0, quizBossLevel: .none, quizLevel: quizLevel,
                        interstitial: interstitial, isInitialDiagnostic: true,
                        learningContext: learningContext
                    ).navigationBarBackButtonHidden(true), isActive: $navigateToQuizResultView)
                    .hidden()
                    }
                } else if isReviewQuiz {
                    ReviewExerciseContent(
                        question: currentQuiz,
                        questionIndex: currentQuizIndex,
                        questionCount: activeQuizzes.count,
                        selectedAnswerIndex: selectedAnswerIndex,
                        hasAnswered: hasAnswered,
                        answersDisabled: hasAnswered || showCountdown || showExplanationModal
                            || reviewUnansweredReason != nil || showCompletionMessage,
                        showsTimer: !isInfiniteMode,
                        remainingSeconds: $remainingSeconds,
                        isFinalStage: isFinalStageReview,
                        attackImpact: attackImpact,
                        comboCount: comboCount, comboPulse: comboPulse,
                        showsMonsterDown: showMonsterDownImage && monsterHP <= 0,
                        onSettings: {
                            generateHapticFeedback()
                            showHomeModal.toggle()
                            audioManager.playSound()
                        },
                        onAnswer: { answerSelectionAction(index: $0) },
                        onUnknown: {
                            generateHapticFeedback()
                            recordUnansweredReview(.unknown)
                        }
                    )
                    if showCompletionMessage {
                        NavigationLink("", destination: QuizResultView(
                            results: quizResults, authManager: authManager,
                            isPresenting: $isPresenting,
                            navigateToQuizResultView: $navigateToQuizResultView,
                            playerExperience: playerExperience, playerMoney: playerMoney,
                            elapsedTime: 0, quizBossLevel: .none, quizLevel: quizLevel,
                            interstitial: interstitial, isFreeReviewPreview: isFreeReviewPreview,
                            isInitialDiagnostic: isInitialDiagnostic, learningContext: learningContext,
                            reviewResultContext: reviewResultContext,
                            sessionDuration: sessionDuration, retryQuestions: incorrectQuestions, onStartNewSet: canStartNewSet ? startNewQuestionSet : nil
                        ).navigationBarBackButtonHidden(true), isActive: $navigateToQuizResultView)
                    }
                } else {
                GeometryReader { geometry in
                let layout = QuizBattleLayoutMetrics(
                    availableHeight: geometry.size.height,
                    isPad: isIPad(),
                    reservedFooterHeight: isReviewQuiz ? 64 : 0
                )
                VStack(spacing: 8) {
                    HStack {
                        Button(action: {
                            generateHapticFeedback()
                            showHomeModal.toggle()
                            audioManager.playSound()
                        }) {
                            ZStack {
                                Circle()
                                    .fill(Color.white)
                                    .frame(width: 52, height: 52)
                                    .shadow(color: .black.opacity(0.15), radius: 8, x: 0, y: 4)

                                Image(systemName: "gearshape.fill")
                                    .font(.system(size: 22, weight: .semibold))
                                    .foregroundColor(Color("fontGray"))
                            }
                        }
                        .padding(.leading)
                        .foregroundColor(.gray)
                        Spacer()
                        if !isInfiniteMode {
                            TimerView(remainingSeconds: $remainingSeconds)
                                .background(GeometryReader { geometry in
                                    Color.clear.preference(key: ViewPositionKey3.self, value: [geometry.frame(in: .global)])
                                })
                        }
                    }
                    .padding(.trailing)
                    .fixedSize(horizontal: false, vertical: true)
                    //                    .padding(.top,40)
                    VStack(spacing: 8) {
                        Spacer(minLength: 0)
                        QuestionCardView(
                            question: currentQuiz.question,
                            selectedAnswerIndex: selectedAnswerIndex,
                            correctAnswerIndex: currentQuiz.correctAnswerIndex,
                            maximumHeight: layout.questionMaximumHeight
                        )
                        .background(GeometryReader { geometry in
                            Color.clear.preference(key: ViewPositionKey0.self, value: [geometry.frame(in: .global)])
                        })
                        .padding(.horizontal, 16)
                        Spacer(minLength: 0)
                        ZStack {
                            ZStack{
                                QuizMonsterImpactView(
                                    imageName: displayedMonsterImageName,
                                    width: layout.monsterSize,
                                    impact: attackImpact
                                )
                                // 敵キャラを倒した
                                if showMonsterDownImage && monsterHP <= 0 {
                                    Image("倒す")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(height:80)
                                }

                            }

                            // コンボバッジをモンスターの右に表示（ZStackで重ねて表示位置がずれない）
                            if comboCount >= 2 {
                                MonsterComboBadgeView(
                                    comboCount: comboCount,
                                    multiplier: MonsterComboSystem.multiplier(for: comboCount),
                                    isPulsing: comboPulse
                                )
                                .scaleEffect(min(1, layout.monsterSize / 72))
                                .offset(x: isSmallDevice() ? 65 : 90, y: 0)
                                .transition(.scale.combined(with: .opacity))
                                .animation(.spring(response: 0.3, dampingFraction: 0.6), value: comboCount)
                            }
                        }
                        .frame(height: layout.monsterSize)
                        if !isDailyLearning && quizLevel != .incorrectAnswer && quizLevel != .incorrectITAnswer && quizLevel != .incorrectInfoAnswer && quizLevel != .incorrectAppliedAnswer && quizLevel != .incorrectESAnswer && quizLevel != .incorrectITStrategyAnswer {
                            ZStack{
                                VStack{
                                    HStack{
                                        ProgressBar3(value: Double(monsterHP), maxValue: Double(monsterUnderHP), color: Color("hpMonsterColor"))
                                            .frame(height: 20)
                                        Text("\(monsterHP)/\(monsterUnderHP)")
                                            .padding(.horizontal,10)
                                            .padding(.vertical, 3)
                                            .foregroundColor(Color(.white))
                                            .background(Color.black.opacity(0.5))
                                            .cornerRadius(30)
                                    }
                                    .padding(.horizontal)
                                    // 味方キャラのHP
                                    HStack{
                                        Image(avator.isEmpty ? "defaultIcon" : (avator.first?["name"] as? String) ?? "")
                                            .resizable()
                                            .frame(width: 30,height:30)
                                        ProgressBar3(value: Double(playerHP), maxValue: Double(self.userMaxHp), color: Color("hpUserColor"))
                                            .frame(height: 20)
                                        Text("\(playerHP)/\(self.userMaxHp)")
                                            .padding(.horizontal,10)
                                            .padding(.vertical, 3)
                                            .foregroundColor(Color(.white))
                                            .background(Color.black.opacity(0.5))
                                            .cornerRadius(30)
                                    }
                                    .padding(.horizontal)
                                }
                                    // 味方がダメージをくらう
                                    if let selected = selectedAnswerIndex, selected != currentQuiz.correctAnswerIndex {
                                        if showAttackImage{
                                            //                                    Image("\(quizLevel)MonsterAttack\(monsterType)")
                                            Image("beginnerMonsterAttack\(monsterType)")
                                                .resizable()
                                                .scaledToFit()
                                                .frame(height:90)
         
                                                .padding(.bottom, -30)
                                    }
                                }
                            }
                            .background(GeometryReader { geometry in
                                Color.clear.preference(key: ViewPositionKey2.self, value: [geometry.frame(in: .global)])
                            })
                        } else {
                            ReviewQuestionProgressView(
                                questionIndex: currentQuizIndex,
                                questionCount: activeQuizzes.count
                            )
                            .padding(.horizontal, 16)
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    QuizAnswerScrollView(questionIndex: currentQuizIndex) {
                        VStack(spacing: 0) {

                            AnswerSelectionView(choices: currentQuiz.choices, correctAnswerIndex: hasAnswered ? currentQuiz.correctAnswerIndex : nil,
                                                preservesDisabledAppearance: isLearningTour && learningTour.step == .questionIntroduction) { index in
                                answerSelectionAction(index: index)
                            }
                            .disabled((isReviewQuiz && (hasAnswered || showExplanationModal || reviewUnansweredReason != nil))
                                || (isLearningTour && (hasAnswered || showExplanationModal || showCompletionMessage
                                    || learningTour.step != .question)))
                            
                            //            AnswerSelectionView(choices: currentQuiz.choices) { index in
                            //                                            answerSelectionAction(index: index)
                            //                                        }
                            .onAppear{
                                
                                showTutorial = true
                                //                print("AnswerSelectionView currentQuiz.choices:\(currentQuiz.choices)")
                            }
                            .frame(maxWidth: .infinity)
                            .shadow(radius: 1)
                            .background(GeometryReader { geometry in
                                Color.clear.preference(key: ViewPositionKey1.self, value: [geometry.frame(in: .global)])
                            })
                            
                            if showCompletionMessage && !isLearningTour {
                                    NavigationLink("", destination: QuizResultView(results: quizResults, authManager: authManager, isPresenting: $isPresenting, navigateToQuizResultView: $navigateToQuizResultView, playerExperience: playerExperience, playerMoney: playerMoney, elapsedTime: 0, quizBossLevel: .none, quizLevel: quizLevel, interstitial: interstitial, isFreeReviewPreview: isFreeReviewPreview, isInitialDiagnostic: isInitialDiagnostic, learningContext: learningContext, reviewResultContext: reviewResultContext, sessionDuration: sessionDuration, retryQuestions: incorrectQuestions, onStartNewSet: canStartNewSet ? startNewQuestionSet : nil).navigationBarBackButtonHidden(true), isActive: $navigateToQuizResultView)
                            }
                        }
                    }
                    .frame(height: layout.answerHeight)
                    .learningTourTarget(.answers)
                    .padding(.bottom, 8)
                    
                    .sheet(isPresented: $showModal) {
                        ExperienceModalView(showModal: $showModal, addedExperience: 10, addedMoney: 10, authManager: authManager)
                    }
                    if isReviewQuiz {
                        Button {
                            generateHapticFeedback()
                            recordUnansweredReview(.unknown)
                        } label: {
                            Label("わからない・解説を見る", systemImage: "questionmark.circle")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(Color("fontGray"))
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                                .background(Color.white.opacity(0.94), in: RoundedRectangle(cornerRadius: 14))
                        }
                        .buttonStyle(.plain)
                        .disabled(hasAnswered || showCountdown || showExplanationModal || reviewUnansweredReason != nil || showCompletionMessage)
                        .accessibilityIdentifier("review.dontKnow")
                        .accessibilityHint("未習得として記録し、この問題の正解と解説を表示します")
                        .padding(.horizontal, 16)
                        .padding(.bottom, 8)
                    }
                }.background(showIncorrectBackground ? Color(.red).opacity(0.1) : Color(.white).opacity(0))
                    .onPreferenceChange(ViewPositionKey0.self) { positions in
                        self.buttonRect = positions.first ?? .zero
                    }
                    .onPreferenceChange(ViewPositionKey1.self) { positions in
                        self.buttonRect1 = positions.first ?? .zero
                    }
                    .onPreferenceChange(ViewPositionKey2.self) { positions in
                        self.buttonRect2 = positions.first ?? .zero
                    }
                    .onPreferenceChange(ViewPositionKey3.self) { positions in
                        self.buttonRect3 = positions.first ?? .zero
                    }
                }
                }
                if showExplanationModal {
                    ZStack {
                        Color.black.opacity(0.7).edgesIgnoringSafeArea(.all)
                        if isUntimedLearningSession {
                            initialPracticeExplanation
                        } else if let selectedIndex = selectedAnswerIndex, selectedIndex < currentQuiz.choices.count {
                            ModalExplanationView(
                                isPresented: $showExplanationModal,
                                selectedAnswerIndex: $selectedAnswerIndex, showAlert: $showAlert, audioManager: audioManager , question: currentQuiz.question, userAnswer: currentQuiz.choices[selectedIndex],
                                correctAnswer: currentQuiz.choices.indices.contains(currentQuiz.correctAnswerIndex) ? currentQuiz.choices[currentQuiz.correctAnswerIndex] : "",
                                explanation: currentQuiz.explanation, currentQuizIndex: explanationQuizIndex,
                                userFlag: $userFlag, pauseTimer:pauseTimer, startTimer: startTimer,
                                reviewQuestionCount: isReviewQuiz ? activeQuizzes.count : nil
                            )
                        }else{
                            ModalReturnView(
                                isPresented: $showExplanationModal, pauseTimer:pauseTimer, startTimer: startTimer)
                        }
                    }
                }
                if let reason = reviewUnansweredReason {
                    Color.black.opacity(0.7).ignoresSafeArea()
                    ReviewUnansweredExplanationView(
                        reason: reason,
                        question: currentQuiz,
                        questionIndex: currentQuizIndex,
                        questionCount: activeQuizzes.count,
                        isLastQuestion: !isInfiniteMode && currentQuizIndex + 1 == activeQuizzes.count,
                        onContinue: continueAfterUnansweredReview
                    )
                }
                if showHomeModal {
                    ZStack {
                        Color.black.opacity(0.7)
                            .edgesIgnoringSafeArea(.all)
                        ModalView(isSoundOn: $isSoundOn, isPresented: $showHomeModal, isPresenting: $isPresenting, audioManager: audioManager, showHomeModal: $showHomeModal,tutorialNum: $tutorialNum,pauseTimer:pauseTimer,resumeTimer: resumeTimer, userFlag: $userFlag)
                    }
                }
                if showSubFlag {
                    ZStack {
                        Color.black.opacity(0.7)
                            .edgesIgnoringSafeArea(.all)
                        SubModalView(isSoundOn: $isSoundOn, isPresented: $showSubFlag, isPresenting: $isPresenting, audioManager: audioManager, showHomeModal: $showHomeModal,pauseTimer:pauseTimer,resumeTimer: resumeTimer, userFlag: $userFlag)
                    }
                }
// MARK: - Quiz Tutorial Overlays
                if tutorialNum == 4 && showTutorial == true {
                    quizTutorialOverlay(
                        spotlightRect: buttonRect,
                        cornerRadius: 16,
                        stepNumber: 4,
                        icon: "doc.text.fill",
                        title: "問題が出題されます",
                        description: "ここに問題文が表示されます",
                        accentColors: [Color(hex: "667eea"), Color(hex: "764ba2")],
                        messagePlacement: .below
                    )
                }
                if tutorialNum == 5 && showTutorial == true {
                    quizTutorialOverlay(
                        spotlightRect: buttonRect1,
                        cornerRadius: 20,
                        stepNumber: 5,
                        icon: "hand.tap.fill",
                        title: "選択肢をタップ",
                        description: "正解と思うものを選んでください",
                        accentColors: [Color(hex: "11998e"), Color(hex: "38ef7d")],
                        messagePlacement: .above
                    )
                }
                if tutorialNum == 6 && showTutorial == true {
                    quizTutorialOverlay(
                        spotlightRect: buttonRect2,
                        cornerRadius: 16,
                        stepNumber: 6,
                        icon: "heart.fill",
                        title: "バトルのルール",
                        description: "正解で敵にダメージ、不正解で自分がダメージ\nHPが0になるとゲームオーバーです",
                        accentColors: [Color(hex: "fa709a"), Color(hex: "fee140")],
                        messagePlacement: .below
                    )
                }
                if tutorialNum == 7 && showTutorial == true {
                    quizTutorialOverlay(
                        spotlightRect: buttonRect3,
                        cornerRadius: 30,
                        stepNumber: 7,
                        icon: "timer",
                        title: "制限時間に注意",
                        description: "時間切れになると自分がダメージを受けます",
                        accentColors: [Color(hex: "f093fb"), Color(hex: "f5576c")],
                        messagePlacement: .below
                    )
                }
                MonsterComboBurstView(
                    title: comboBurstTitle,
                    subtitle: comboBurstSubtitle,
                    colors: comboBurstColors,
                    isVisible: showComboBurst && !isUntimedLearningSession
                )
                .offset(y: -100)
                .allowsHitTesting(false)
                .accessibilityHidden(!showComboBurst || isUntimedLearningSession)

                if showCountdown {
                    ZStack {
                        // 背景
                        Color.black.opacity(0.7)
                            .edgesIgnoringSafeArea(.all)
                        // カウントダウンの数字
                        Text("\(countdownValue)")
                            .font(.system(size: 100))
                            .foregroundColor(.white)
                            .bold()
                    }
                }
            }
            .fontWeight(.bold)
            .onTapGesture {
                //                audioManager.playSound()
                if showCountdown == false {
                    if tutorialNum == 4 {
                        tutorialNum = 5
                        authManager.updateTutorialNum(userId: authManager.currentUserId ?? "", tutorialNum: 5) { success in
                        }
                    } else if tutorialNum == 5 {
                        tutorialNum = 6
                        authManager.updateTutorialNum(userId: authManager.currentUserId ?? "", tutorialNum: 6) { success in
                        }
                    } else if tutorialNum == 6 {
                        tutorialNum = 7
                        authManager.updateTutorialNum(userId: authManager.currentUserId ?? "", tutorialNum: 7) { success in
                        }
                    } else if tutorialNum == 7 {
                        resumeTimer()
                        tutorialNum = 0
                        authManager.updateTutorialNum(userId: authManager.currentUserId ?? "", tutorialNum: 0) { success in
                        }
                    }
                }
            }
            .learningTourOverlay(step: .questionIntroduction, target: .answers,
                onSkip: { learningTour.requestFinish(); isPresenting = false },
                onContinue: { learningTour.advance(from: .questionIntroduction) })
            .learningTourOverlay(step: .completion,
                onSkip: { learningTour.requestFinish(); isPresenting = false },
                onContinue: { learningTour.requestFinish(exit: .continueLearning); isPresenting = false },
                onHome: { learningTour.requestFinish(); isPresenting = false })
            .overlay(alignment: .topTrailing) {
                if isLearningTour && (learningTour.step == .question || learningTour.step == .explanation) {
                    Button("スキップ") { learningTour.requestFinish(); isPresenting = false }
                        .font(.subheadline.weight(.semibold))
                        .padding(12).background(.white, in: Capsule())
                        .padding(.trailing, 16)
                        .accessibilityIdentifier("learningTour.skip")
                }
            }
            .onAppear {
                isQuizVisible = true
                // 広告から戻っても終了した試合を初期化しない。
                if showCompletionMessage {
                    if isPresenting && !isLearningTour {
                        navigateToQuizResultView = true
                    }
                    return
                }
                if hasInitializedQuiz {
                    if isQuizReady && !hasAnswered && !showExplanationModal &&
                        !showHomeModal && !showSubFlag && tutorialNum == 0 {
                        resumeTimer()
                    }
                    return
                }
                hasInitializedQuiz = true
                if reviewSessionUserID == nil { reviewSessionUserID = authManager.currentUserId }
                if quizLevel == .incorrectAnswer, let userID = authManager.currentUserId {
                    finalStageReviewKeys = Set(LocalReviewScheduleStore.records(userID: userID)
                        .filter { $0.progress.masteredAt == nil && $0.progress.stage >= 2 }
                        .map { ReviewAccessPolicy.key($0.question) })
                }
                if isInitialDiagnostic && !hasLoggedInitialDiagnosticStart {
                    GrowthAnalytics.logInitialDiagnosticStart()
                    hasLoggedInitialDiagnosticStart = true
                }
                if appState.isSubscribed && quizLevel.isLocalIncorrectReview {
                    PremiumAnalytics.logPremiumFirstUseIfNeeded(feature: "review")
                }
                if !hasLoggedLearningSetStart {
                    InterstitialOpportunityCoordinator.shared.logLearningSetStart(
                        surface: "normal_quiz",
                        quizLevel: quizLevel,
                        learningContext: learningContext
                    )
                    hasLoggedLearningSetStart = true
                }
                if !isUntimedLearningSession && learningContext?.interstitialExclusionReason == nil && connectivity.isConnected && appState.shouldShowAds {
                    interstitial.preloadIfNeeded()
                }
                withAnimation(.easeInOut(duration: 1.2).repeatForever(autoreverses: true)) {
                    tutorialPulse = true
                }
                if isInfiniteMode || isUntimedLearningSession {
                    showCountdown = false
                } else {
                    startCountdown()
                }
                self.monsterType = 1 // すぐに1に戻す
                if !connectivity.isConnected {
                    self.userMaxHp = self.userHp
                    self.playerHP = self.userHp
                    self.startTime = Date()
                    isQuizReady = true
                    return
                }
                authManager.fetchUserInfo { (name, avatar, money, hp, attack, tutorialNum) in
                    self.userName = name ?? ""
                    self.avator = avatar ?? [[String: Any]]()
                    print("avator:\(avator)")
                    self.userMoney = money ?? 0
                    self.userHp = hp ?? 100
                    self.userAttack = attack ?? 20
                    self.tutorialNum = isUntimedLearningSession ? 0 : (tutorialNum ?? 0)
                    if let additionalAttack = self.avator.first?["attack"] as? Int {
                        self.userAttack = self.userAttack + additionalAttack
                    }
                    if let additionalHealth = self.avator.first?["health"] as? Int {
                        self.userMaxHp = self.userHp + additionalHealth
                    }
                    if let additionalHealth = self.avator.first?["health"] as? Int {
                        self.playerHP = self.userHp + additionalHealth
                    } else {
                        self.playerHP = self.userHp
                    }
                    isQuizReady = true
                    if self.tutorialNum == 0 {
                        //                        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                        startTimer() // Viewが表示されたときにタイマーを開始
                        //                        }
                    }
                    if self.tutorialNum == 2 {
                        authManager.updateTutorialNum(userId: authManager.currentUserId ?? "", tutorialNum: 0) { success in
                            // データベースのアップデートが成功したかどうかをハンドリング
                        }
                    }
                }
                self.startTime = Date()
                authManager.fetchUserRewardFlag()
                
                if isReviewQuiz {
                    userAttack = 0
                }
                authManager.fetchUserFlag()
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    userFlag = authManager.userFlag
                }            }
            .onDisappear {
                isQuizVisible = false
                if quizLevel.localReviewCategory == .itPassport,
                   WeaknessCourseStore.shared.userID == authManager.currentUserId {
                    WeaknessCourseStore.shared.sync()
                }
                attackImpact = nil
                // 画面を離れるときは必ずタイマーを止める
                timer?.invalidate()
                timer = nil

                // 経過時間の記録だけを行う（遷移はここでは行わない）
                if playerExperience != 5 && playerMoney != 5 {
                    self.endTime = Date()
                    self.elapsedTime = self.endTime?.timeIntervalSince(self.startTime)
                    // self.navigateToQuizResult = true  // ← ここは削除
                }
            }
            .alert(isPresented: $showAlert) {
                Alert(
                    title: Text("通知"),
                    message: Text("設定画面で切り替える事ができます"),
                    dismissButton: .default(Text("OK"), action: {
                        //                        isPresented = false
                        startTimer()
                        selectedAnswerIndex = nil
                    })
                )
            }
            .onChange(of: userFlag) { flag in
                //                          print("onchange userFlag:\(userFlag)")
                //                userFlag = authManager.userFlag
            }
            .alert("復習のご案内", isPresented: Binding(
                get: { reviewAccessMessage != nil }, set: { if !$0 { reviewAccessMessage = nil } }
            )) {
                Button("戻る") { isPresenting = false }
            } message: {
                Text(reviewAccessMessage ?? "")
            }
            .onChange(of: selectedAnswerIndex) { newValue in
                if let selected = newValue, selected != currentQuiz.correctAnswerIndex {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        self.showIncorrectBackground = true
                    }
                } else {
                    self.showIncorrectBackground = false
                }
            }
            .onChange(of: showCompletionMessage) { newValue in
                // 「別の問題で」のリセットで false に戻すときは、報酬の付与も結果画面への遷移もしない
                guard newValue, !hasHandledCompletion else { return }
                hasHandledCompletion = true
                sessionDuration = Date().timeIntervalSince(startTime)
                // Short question sets also finish before defeating the last monster.
                if newValue { persistQuizStatsIfPossible() }
                if connectivity.isConnected {
                    // 味方のHPが０以下のとき
                    if newValue && playerHP <= 0 {
                        DispatchQueue.global(qos: .background).async {
                            authManager.addExperience(points: 5, onSuccess: {
                                // 成功した時の処理をここに書きます
                            }, onFailure: { error in
                                // 失敗した時の処理をここに書きます。`error`は失敗の原因を示す情報が含まれている可能性があります。
                            })
                            authManager.addMoney(amount: 5)

                            DispatchQueue.main.async {
                            }
                        }
                    } else {
                        DispatchQueue.global(qos: .background).async {
                            authManager.addExperience(points: playerExperience * authManager.rewardFlag, onSuccess: {
                                //                            print("addExperience \(authManager.rewardFlag)")
                            }, onFailure: { error in
                                // 失敗した時の処理をここに書きます。`error`は失敗の原因を示す情報が含まれている可能性があります。
                            })
                            authManager.addMoney(amount: playerMoney * authManager.rewardFlag)
                            DispatchQueue.main.async {
                                // ここでUIの更新を行います。
                            }
                        }
                    }
                }
                guard !isLearningTour else { return }
                let completedSessionId = leagueSessionId
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    guard showCompletionMessage, isPresenting,
                          leagueSessionId == completedSessionId else { return }
                    showModal = false
                    navigateToQuizResultView = true
                }
            }
            .onChange(of: monsterType) { newMonsterType in
                configureMonster(for: newMonsterType)
            }
            .navigationBarBackButtonHidden(true)
        }
    }
}

struct QuestionCardView: View {
    let question: String
    let selectedAnswerIndex: Int?
    let correctAnswerIndex: Int
    var maximumHeight: CGFloat = 210
    @State private var appearAnimation = false

    var body: some View {
        questionContent
            .background {
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.white)
                    .shadow(color: Color.black.opacity(0.1), radius: 15, x: 0, y: 8)
            }
            .overlay {
                // Result marks do not change the card's height or intercept scrolling.
                if let selected = selectedAnswerIndex {
                    Group {
                        if selected == correctAnswerIndex {
                            Circle()
                                .stroke(Color.red, lineWidth: 8)
                                .frame(width: 80, height: 80)
                        } else {
                            Image(systemName: "xmark")
                                .font(.system(size: 60, weight: .bold))
                                .foregroundColor(.blue)
                        }
                    }
                    .opacity(0.8)
                    .transition(.scale.combined(with: .opacity))
                    .allowsHitTesting(false)
                }
            }
            .scaleEffect(appearAnimation ? 1.0 : 0.95)
            .opacity(appearAnimation ? 1.0 : 0)
            .onAppear {
                withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                    appearAnimation = true
                }
            }
    }

    private var questionContent: some View {
        QuizQuestionHeightLayout(maximumHeight: maximumHeight) {
            // Measure the full text; ScrollView reports only its viewport height.
            questionText(compact: false).hidden()
            ViewThatFits(in: .vertical) {
                questionText(compact: false)
                // Try slightly tighter typography before requiring a reading gesture.
                questionText(compact: true)
                VStack(spacing: 0) {
                    ScrollView(.vertical) {
                        questionText(compact: true)
                    }
                    // Each new question starts at the beginning, even after a long one.
                    .id(question)
                    Label("スクロールして続きを読む", systemImage: "chevron.down")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(.secondary)
                        .padding(.bottom, 6)
                }
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }

    private func questionText(compact: Bool) -> some View {
        Text(question)
            .font(.system(size: isSmallDevice() ? 15 : (compact ? 16 : 17), weight: .semibold))
            .foregroundColor(Color("fontGray"))
            .multilineTextAlignment(.leading)
            .lineSpacing(compact ? 3 : 4)
            .lineLimit(nil)
            .padding(.horizontal, 16)
            .padding(.vertical, compact ? 12 : 16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .fixedSize(horizontal: false, vertical: true)
    }
}

struct QuizView_Previews: PreviewProvider {
    static var previews: some View {
        QuizITBasicList(isPresenting: .constant(false))
            .environmentObject(AppState())
            .environmentObject(ConnectivityMonitor.shared)
//        QuizIncorrectAnswerListView(isPresenting: .constant(false))
    }
}

extension QuizView {
    func pauseTimer() {
        timer?.invalidate()
    }

    func resumeTimer() {
        timer?.invalidate()
        guard isQuizVisible, isQuizReady, isPresenting,
              !showCompletionMessage, !navigateToQuizResultView else {
            timer = nil
            return
        }
        if isUntimedLearningSession {
            timer = nil
            return
        }
        if isReviewQuiz && (hasAnswered || reviewUnansweredReason != nil || showCompletionMessage) {
            timer = nil
            return
        }
        guard !isInfiniteMode else {
            timer = nil
            return
        }
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
            if remainingSeconds > 0 {
                remainingSeconds -= 1
            } else {
                timer.invalidate()
                if isReviewQuiz {
                    recordUnansweredReview(.timedOut)
                    return
                }
                if isDailyLearning || isInitialDiagnostic {
                    recordDailyQuickQuizTimeout()
                } else {
                    playerHP -= monsterAttack
                }
                moveToNextQuiz()
            }
        }
    }

    func startCountdown() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
                if countdownValue > 1 {
                    countdownValue -= 1
                } else {
                    timer.invalidate()
                    showCountdown = false
                    if tutorialNum != 3 && tutorialNum < 4 {
                        startTimer()
                    }
                }
            }
        }
    }

    func startTimer() {
        timer?.invalidate()
        guard isQuizVisible, isQuizReady, isPresenting,
              !showCompletionMessage, !navigateToQuizResultView else {
            timer = nil
            return
        }
        if isUntimedLearningSession {
            timer = nil
            return
        }
        if isReviewQuiz && (hasAnswered || reviewUnansweredReason != nil || showCompletionMessage) {
            timer = nil
            return
        }
        guard !isInfiniteMode else {
            timer = nil
            remainingSeconds = currentQuiz.recommendedTimeLimit
            return
        }
        remainingSeconds = currentQuiz.recommendedTimeLimit
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
            if remainingSeconds > 0 {
                remainingSeconds -= 1
            } else {
                timer.invalidate()
                if isReviewQuiz {
                    recordUnansweredReview(.timedOut)
                    return
                }
                applyTimeoutComboPenalty()
                recordReviewFailureIfNeeded()
                if isDailyLearning || isInitialDiagnostic {
                    recordDailyQuickQuizTimeout()
                } else {
                    playerHP -= monsterAttack
                }
                moveToNextQuiz()
            }
        }
    }

    /// 通常クイズのタイムアウトでも今日の3問の回答・結果を欠落させない。
    private func recordDailyQuickQuizTimeout() {
        guard !hasAnswered, activeQuizzes.indices.contains(currentQuizIndex) else { return }
        hasAnswered = true
        onAnswered?(currentQuiz)
        answerCount += 1
        quizResults.append(QuizResult(
            question: currentQuiz.question,
            userAnswer: "時間切れ",
            correctAnswer: currentQuiz.choices[currentQuiz.correctAnswerIndex],
            explanation: currentQuiz.explanation,
            isCorrect: false
        ))
    }

    func moveToNextQuiz() {
        guard !showCompletionMessage else { return }
        guard activeQuizzes.indices.contains(currentQuizIndex) else {
            showCompletionMessage = true
            timer?.invalidate()
            navigateToQuizResultView = true
            return
        }

        // 初回は非表示設定・最終問題・戦闘の勝敗によらず、解説を読んでから進む。
        if isUntimedLearningSession {
            pauseTimer()
            if isLearningTour { learningTour.advance(from: .question) }
            showExplanationModal = true
            return
        }

        if isInfiniteMode {
            if userFlag == 0 {
                showExplanationModal = true
            } else {
                currentQuizIndex = (currentQuizIndex + 1) % activeQuizzes.count
                selectedAnswerIndex = nil
            }
            hasAnswered = false
            return
        }

        if !isDailyLearning && !isReviewQuiz && monsterType == 2 && monsterHP <= 0 {
            showCompletionMessage = true
            timer?.invalidate()
            persistQuizStatsIfPossible()
            navigateToQuizResultView = true
        } else if !isDailyLearning && !isReviewQuiz && playerHP <= 0 {
            showCompletionMessage = true
            timer?.invalidate()
            playerExperience = 5
            playerMoney = 5
            persistQuizStatsIfPossible()
            navigateToQuizResultView = true
        } else if remainingSeconds == 0 {
            if currentQuizIndex + 1 < activeQuizzes.count {
                currentQuizIndex += 1
                selectedAnswerIndex = nil
                hasAnswered = false
                startTimer()
            } else {
                showCompletionMessage = true
                timer?.invalidate()
                navigateToQuizResultView = true
            }
        } else if currentQuizIndex + 1 < activeQuizzes.count {
            if userFlag == 0 {
                showExplanationModal = true
            } else {
                currentQuizIndex += 1
                selectedAnswerIndex = nil
                hasAnswered = false
                startTimer()
            }
            hasAnswered = false
        } else {
            showCompletionMessage = true
            timer?.invalidate()
            navigateToQuizResultView = true
        }
    }

    private func continueInitialPracticeAfterExplanation() {
        guard isUntimedLearningSession, showExplanationModal, hasAnswered else { return }
        showExplanationModal = false
        if isLearningTour {
            timer?.invalidate()
            persistQuizStatsIfPossible()
            showCompletionMessage = true
            learningTour.advance(from: .explanation)
            return
        }
        selectedAnswerIndex = nil
        showIncorrectBackground = false
        showAttackImage = false
        attackImpact = nil

        if currentQuizIndex + 1 == activeQuizzes.count {
            timer?.invalidate()
            persistQuizStatsIfPossible()
            showCompletionMessage = true
            navigateToQuizResultView = true
        } else {
            currentQuizIndex += 1
            hasAnswered = false
            startTimer()
        }
    }

    private func skipInitialPracticeQuestion() {
        guard isUntimedLearningSession, !hasAnswered, !showExplanationModal,
              !showCompletionMessage, activeQuizzes.indices.contains(currentQuizIndex) else { return }

        generateHapticFeedback()
        pauseTimer()
        selectedAnswerIndex = nil
        hasAnswered = true
        answerCount += 1
        onAnswered?(currentQuiz)

        if let userID = authManager.currentUserId {
            WeaknessCourseStore.shared.recordMistake(
                question: currentQuiz, selectedIndex: nil, userID: userID
            )
            let incorrectAnswer = IncorrectAnswer(
                userId: userID,
                quizQuestion: currentQuiz.question,
                choices: currentQuiz.choices,
                correctAnswerIndex: currentQuiz.correctAnswerIndex,
                explanation: currentQuiz.explanation,
                sourceQuizLevel: quizLevel.description
            )
            let saveResult = LocalIncorrectAnswerStore.save(incorrectAnswer, quizLevel: quizLevel)
            ReviewAnalytics.logMistakeSave(result: saveResult, quizLevel: quizLevel)
            if connectivity.isConnected && appState.isSubscribed {
                saveIncorrectAnswerIfNeeded(incorrectAnswer)
            }
        }
        if connectivity.isConnected {
            authManager.recordAnswer(isCorrect: false)
        }
        quizResults.append(QuizResult(
            question: currentQuiz.question,
            userAnswer: "わからない",
            correctAnswer: currentQuiz.choices[currentQuiz.correctAnswerIndex],
            explanation: currentQuiz.explanation,
            isCorrect: false
        ))
        if isLearningTour { learningTour.advance(from: .question) }
        showExplanationModal = true
    }

    // MARK: - Quiz Tutorial Overlay Builder
    enum TutorialMessagePlacement {
        case above, below
    }

    @ViewBuilder
    private func quizTutorialOverlay(
        spotlightRect: CGRect,
        cornerRadius: CGFloat,
        stepNumber: Int,
        icon: String,
        title: String,
        description: String,
        accentColors: [Color],
        messagePlacement: TutorialMessagePlacement
    ) -> some View {
        TutorialSpotlight(
            spotlight: spotlightRect,
            cornerRadius: cornerRadius,
            step: stepNumber,
            icon: icon,
            title: title,
            message: description,
            accent: accentColors,
            placement: messagePlacement == .below ? .below : .above,
            onSkip: {
                generateHapticFeedback()
                tutorialNum = 0
                authManager.updateTutorialNum(userId: authManager.currentUserId ?? "", tutorialNum: 0) { _ in }
            }
        )
    }

    func answerSelectionAction(index: Int) {
        guard isQuizReady, !showCompletionMessage else { return }
        guard !isLearningTour || learningTour.step == .question else { return }
        guard !hasAnswered, reviewUnansweredReason == nil,
              !showExplanationModal, activeQuizzes.indices.contains(currentQuizIndex),
              currentQuiz.choices.indices.contains(index) else { return }
        guard claimReviewAnswer() else { return }

        selectedAnswerIndex = index
        timer?.invalidate()
        onAnswered?(currentQuiz)

        let isAnswerCorrect = selectedAnswerIndex == currentQuiz.correctAnswerIndex
        recordLocalReview(correct: isAnswerCorrect)
        if !isInfiniteMode, !isAnswerCorrect,
           quizLevel.localReviewCategory == .itPassport,
           let userID = authManager.currentUserId {
            WeaknessCourseStore.shared.recordMistake(question: currentQuiz, selectedIndex: index, userID: userID)
        }
        if !isInfiniteMode && connectivity.isConnected {
            authManager.recordAnswer(isCorrect: isAnswerCorrect)
        }
        if isAnswerCorrect {
            let damage = comboAdjustedDamage()
            audioManager.playCorrectSound()
            DispatchQueue.main.asyncAfter(deadline: .now() + QuizAttackImpact.delay) {
                if !isUntimedLearningSession {
                    audioManager.playAttackSound()
                }
                registerSuccessfulCombo()
                correctAnswerCount += 1
                answerCount += 1
                var displayedDamage: Int?
                if !isInfiniteMode && !isDailyLearning && !isUntimedLearningSession && quizLevel != .incorrectAnswer && quizLevel != .incorrectITAnswer && quizLevel != .incorrectInfoAnswer && quizLevel != .incorrectAppliedAnswer && quizLevel != .incorrectESAnswer && quizLevel != .incorrectITStrategyAnswer {
                    monsterHP -= damage
                    displayedDamage = damage
                }
                let impact = QuizAttackImpact(
                    damage: displayedDamage,
                    isBoosted: damage > userAttack,
                    sequence: correctAnswerCount,
                    comboCount: comboCount
                )
                attackImpact = impact
                impact.playHaptic()
                GuildManager.shared.attackRaidBossIfPossible(damage: damage)
                if !isInfiniteMode && monsterHP <= 0 {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        audioManager.playDownSound()
                        showMonsterDownImage = true
                    }
                } else if !isInfiniteMode && !isDailyLearning && !isUntimedLearningSession && playerHP <= 0 {
                    showCompletionMessage = true
                    timer?.invalidate()
                }
            }

            if !isInfiniteMode,
               quizLevel.isLocalIncorrectReview,
               let userId = authManager.currentUserId {
                LocalIncorrectAnswerStore.remove(
                    userId: userId,
                    category: quizLevel.localReviewCategory,
                    matching: currentQuiz
                )
            }

            if !isInfiniteMode,
               connectivity.isConnected,
               let userId = authManager.currentUserId,
               let questionId = currentQuiz.id {
                switch quizLevel {
                case .incorrectITAnswer:
                    removeCorrectITAnswer(for: userId, questionId: questionId)
                case .incorrectInfoAnswer:
                    removeCorrectInfoAnswer(for: userId, questionId: questionId)
                case .incorrectAppliedAnswer:
                    removeCorrectAppliedAnswer(for: userId, questionId: questionId)
                case .incorrectAnswer:
                    if !questionId.hasPrefix("scheduled_local_") {
                        ReviewScheduleService.recordCorrectReview(userId: userId, questionId: questionId)
                    }
                case .incorrectESAnswer:
                    removeCorrectESAnswer(for: userId, questionId: questionId)
                case .incorrectITStrategyAnswer:
                    removeCorrectITStrategyAnswer(for: userId, questionId: questionId)
                default:
                    break
                }
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                // Check victory before changing the monster: the final enemy is type 2.
                moveToNextQuiz()
                showMonsterDownImage = false
                if !isInfiniteMode && monsterHP <= 0 && !showCompletionMessage {
                    monsterType += 1
                }
            }
        } else {
            resetCombo(withTitle: "COMBO BREAK", subtitle: "倍率リセット", colors: [Color.gray, Color.black.opacity(0.8)])
            if !isInfiniteMode, let userId = authManager.currentUserId {
                if quizLevel == .incorrectAnswer {
                    if connectivity.isConnected, let questionId = currentQuiz.id,
                       !questionId.hasPrefix("scheduled_local_") {
                        ReviewScheduleService.recordIncorrectReview(userId: userId, questionId: questionId)
                    }
                } else if !quizLevel.isLocalIncorrectReview {
                    let incorrectAnswer = IncorrectAnswer(
                        userId: userId,
                        quizQuestion: currentQuiz.question,
                        choices: currentQuiz.choices,
                        correctAnswerIndex: currentQuiz.correctAnswerIndex,
                        explanation: currentQuiz.explanation,
                        sourceQuizLevel: quizLevel.description
                    )
                    let saveResult = LocalIncorrectAnswerStore.save(incorrectAnswer, quizLevel: quizLevel)
                    ReviewAnalytics.logMistakeSave(result: saveResult, quizLevel: quizLevel)

                    if connectivity.isConnected && appState.isSubscribed {
                        saveIncorrectAnswerIfNeeded(incorrectAnswer)
                    }
                }
            }

            answerCount += 1
            audioManager.playUnCorrectSound()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                if !isUntimedLearningSession {
                    audioManager.playMonsterAttackSound()
                }
                if !isInfiniteMode && !isDailyLearning && !isUntimedLearningSession && !isReviewQuiz {
                    playerHP -= monsterAttack
                }
                showAttackImage = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                moveToNextQuiz()
            }
        }

        let result = QuizResult(
            question: currentQuiz.question,
            userAnswer: currentQuiz.choices[index],
            correctAnswer: currentQuiz.choices[currentQuiz.correctAnswerIndex],
            explanation: currentQuiz.explanation,
            isCorrect: isAnswerCorrect
        )
        if !isInfiniteMode {
            quizResults.append(result)
        }
        showAttackImage = false
        hasAnswered = true
    }

    private func recordUnansweredReview(_ reason: ReviewUnansweredReason) {
        guard isReviewQuiz, !hasAnswered, !showExplanationModal,
              reviewUnansweredReason == nil, !showCompletionMessage,
              activeQuizzes.indices.contains(currentQuizIndex) else { return }
        guard claimReviewAnswer() else { return }
        recordLocalReview(correct: false)

        // タイマーと連打の両方を止めてから、未習得を一度だけ記録する。
        hasAnswered = true
        timer?.invalidate()
        timer = nil
        selectedAnswerIndex = nil
        reviewUnansweredReason = reason
        showAttackImage = false
        answerCount += 1

        if reason == .timedOut {
            applyTimeoutComboPenalty()
        } else {
            resetCombo(withTitle: "COMBO BREAK", subtitle: "倍率リセット", colors: [.gray, .black.opacity(0.8)])
        }

        guard !isInfiniteMode else { return }
        onAnswered?(currentQuiz)
        if quizLevel.localReviewCategory == .itPassport, let userID = authManager.currentUserId {
            WeaknessCourseStore.shared.recordMistake(question: currentQuiz, selectedIndex: nil, userID: userID)
        }
        if connectivity.isConnected {
            authManager.recordAnswer(isCorrect: false)
            recordReviewFailureIfNeeded()
        }
        // 資格別の誤答は削除せず残す。期限付き復習は不正解と同じく翌日に戻す。
        quizResults.append(QuizResult(
            question: currentQuiz.question,
            userAnswer: reason.rawValue,
            correctAnswer: currentQuiz.choices.indices.contains(currentQuiz.correctAnswerIndex)
                ? currentQuiz.choices[currentQuiz.correctAnswerIndex] : "",
            explanation: currentQuiz.explanation,
            isCorrect: false
        ))
    }

    private func continueAfterUnansweredReview() {
        guard reviewUnansweredReason != nil, hasAnswered else { return }
        generateHapticFeedback()
        audioManager.playCancelSound()
        reviewUnansweredReason = nil

        if !isInfiniteMode && currentQuizIndex + 1 >= activeQuizzes.count {
            timer?.invalidate()
            persistQuizStatsIfPossible()
            showCompletionMessage = true
            navigateToQuizResultView = true
            return
        }

        currentQuizIndex = (currentQuizIndex + 1) % activeQuizzes.count
        selectedAnswerIndex = nil
        hasAnswered = false
        showIncorrectBackground = false
        attackImpact = nil
        startTimer()
    }

    private func comboAdjustedDamage() -> Int {
        let multiplier = MonsterComboSystem.multiplier(for: comboCount + 1)
        return max(Int((Double(userAttack) * multiplier).rounded()), userAttack)
    }

    private func registerSuccessfulCombo() {
        let previousTier = MonsterComboSystem.tier(for: comboCount)
        comboCount += 1
        triggerComboPulse()

        guard let currentTier = MonsterComboSystem.tier(for: comboCount) else { return }
        // ティアが変わった時だけバーストを表示
        guard previousTier?.requiredStreak != currentTier.requiredStreak else { return }
        let subtitle = "\(currentTier.title)  ·  ATK x\(String(format: "%.1f", currentTier.multiplier))"
        presentComboBurst(title: "\(comboCount) COMBO", subtitle: subtitle, colors: currentTier.colors)
    }

    private func applyTimeoutComboPenalty() {
        guard comboCount > 0 else { return }
        let reducedCombo = MonsterComboSystem.reducedComboCountAfterTimeout(from: comboCount)
        comboCount = reducedCombo
        comboPulse = false

        if reducedCombo >= 3, let tier = MonsterComboSystem.tier(for: reducedCombo) {
            presentComboBurst(
                title: "TIME OUT",
                subtitle: "\(reducedCombo) COMBO まで減少",
                colors: tier.colors
            )
        } else {
            comboCount = 0
            presentComboBurst(
                title: "TIME OUT",
                subtitle: "コンボ消失",
                colors: [Color.gray, Color.black.opacity(0.8)]
            )
        }
    }

    private func resetCombo(withTitle title: String, subtitle: String, colors: [Color]) {
        guard comboCount > 0 else { return }
        comboCount = 0
        comboPulse = false
        presentComboBurst(title: title, subtitle: subtitle, colors: colors)
    }

    private func triggerComboPulse() {
        comboPulse = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.28) {
            comboPulse = false
        }
    }

    private func presentComboBurst(title: String, subtitle: String, colors: [Color]) {
        comboBurstTitle = title
        comboBurstSubtitle = subtitle
        comboBurstColors = colors
        showComboBurst = true

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.95) {
            showComboBurst = false
        }
    }

    func saveIncorrectAnswer(_ answer: IncorrectAnswer) {
        ReviewScheduleService.saveIncorrectAnswer(answer)
    }

    func saveIncorrectITAnswer(_ answer: IncorrectAnswer) {
        saveIncorrectAnswer(answer, at: "IncorrectITAnswers")
    }

    func saveIncorrectInfoAnswer(_ answer: IncorrectAnswer) {
        saveIncorrectAnswer(answer, at: "IncorrectInfoAnswers")
    }

    func saveIncorrectAppliedAnswer(_ answer: IncorrectAnswer) {
        saveIncorrectAnswer(answer, at: "IncorrectAppliedAnswers")
    }

    func saveIncorrectESAnswer(_ answer: IncorrectAnswer) {
        saveIncorrectAnswer(answer, at: "IncorrectESAnswers")
    }

    func saveIncorrectITStrategyAnswer(_ answer: IncorrectAnswer) {
        saveIncorrectAnswer(answer, at: "IncorrectITStrategyAnswers")
    }

    func removeCorrectAnswer(for userId: String, questionId: String) {
        removeCorrectAnswer(at: "IncorrectAnswers", userId: userId, questionId: questionId)
    }

    func removeCorrectITAnswer(for userId: String, questionId: String) {
        removeCorrectAnswer(at: "IncorrectITAnswers", userId: userId, questionId: questionId)
    }

    func removeCorrectInfoAnswer(for userId: String, questionId: String) {
        removeCorrectAnswer(at: "IncorrectInfoAnswers", userId: userId, questionId: questionId)
    }

    func removeCorrectAppliedAnswer(for userId: String, questionId: String) {
        removeCorrectAnswer(at: "IncorrectAppliedAnswers", userId: userId, questionId: questionId)
    }

    func removeCorrectESAnswer(for userId: String, questionId: String) {
        removeCorrectAnswer(at: "IncorrectESAnswers", userId: userId, questionId: questionId)
    }

    func removeCorrectITStrategyAnswer(for userId: String, questionId: String) {
        removeCorrectAnswer(at: "IncorrectITStrategyAnswers", userId: userId, questionId: questionId)
    }

    private func persistQuizStatsIfPossible() {
        if quizLevel.localReviewCategory == .itPassport,
           WeaknessCourseStore.shared.userID == authManager.currentUserId {
            WeaknessCourseStore.shared.sync()
        }
        guard !hasPersistedQuizStats, !isInfiniteMode, answerCount > 0,
              connectivity.isConnected,
              let userId = authManager.currentUserId else { return }
        hasPersistedQuizStats = true
        RateManager.shared.updateQuizData(
            userId: userId,
            quizType: quizLevel,
            newCorrectAnswers: correctAnswerCount,
            newTotalAnswers: answerCount
        )
        RateManager.shared.updateAnswerData(
            userId: userId,
            quizType: quizLevel,
            newTotalAnswers: answerCount
        )
        WeeklyLeagueService.shared.recordQuizResult(
            userId: userId,
            context: WeeklyLeagueQuizContext(
                results: quizResults,
                quizLevel: quizLevel,
                didClear: monsterHP <= 0
            ),
            sessionId: leagueSessionId
        )
    }

    private func saveIncorrectAnswerIfNeeded(_ answer: IncorrectAnswer) {
        guard quizLevel != .incorrectAnswer,
              quizLevel != .incorrectITAnswer,
              quizLevel != .incorrectInfoAnswer,
              quizLevel != .incorrectAppliedAnswer,
              quizLevel != .incorrectESAnswer,
              quizLevel != .incorrectITStrategyAnswer else {
            return
        }

        switch quizLevel {
        case .itBasic, .itStrategy, .itTechnology, .itManagement:
            saveIncorrectITAnswer(answer)
        case .infoBasic, .infoStrategy, .infoTechnology, .infoManagement:
            saveIncorrectInfoAnswer(answer)
        case .appliedBasic, .appliedStrategy, .appliedTechnology, .appliedManagement:
            saveIncorrectAppliedAnswer(answer)
        case .computerSystem, .softHard, .netwarkTusin, .ESsecurity:
            saveIncorrectESAnswer(answer)
        case .kikaku, .sekkei, .kaihatu, .unyouhoshu:
            saveIncorrectITStrategyAnswer(answer)
        default:
            saveIncorrectAnswer(answer)
        }
        if quizLevel.localReviewCategory != .general {
            ReviewScheduleService.syncLocalReview(QuizQuestion(question: answer.quizQuestion, choices: answer.choices,
                correctAnswerIndex: answer.correctAnswerIndex, explanation: answer.explanation,
                sourceQuizLevel: answer.sourceQuizLevel), userId: answer.userId, subscribed: true)
        }
    }

    private func saveIncorrectAnswer(_ answer: IncorrectAnswer, at path: String) {
        let ref = Database.database().reference().child(path).child(answer.userId).childByAutoId()
        ref.setValue([
            "quizQuestion": answer.quizQuestion,
            "choices": answer.choices,
            "correctAnswerIndex": answer.correctAnswerIndex,
            "explanation": answer.explanation,
        ])
    }

    private func removeCorrectAnswer(at path: String, userId: String, questionId: String) {
        let ref = Database.database().reference().child(path).child(userId).child(questionId)
        ref.removeValue { error, _ in
            if let error = error {
                print("Error removing correct answer: \(error.localizedDescription)")
            } else {
                print("Correct answer removed successfully.")
            }
        }
    }

    private func recordReviewFailureIfNeeded() {
        guard connectivity.isConnected,
              quizLevel == .incorrectAnswer,
              let userId = authManager.currentUserId,
              let questionId = currentQuiz.id, !questionId.hasPrefix("scheduled_local_") else { return }
        ReviewScheduleService.recordIncorrectReview(userId: userId, questionId: questionId)
    }

    private func claimReviewAnswer() -> Bool {
        guard isReviewQuiz, !isInfiniteMode else { return true }
#if DEBUG
        if ProcessInfo.processInfo.arguments.contains("-ReviewExercisePreview") { return true }
#endif
        guard let userID = authManager.currentUserId, userID == reviewSessionUserID else {
            timer?.invalidate()
            reviewAccessMessage = "アカウントが変わりました。復習画面を開き直してください。"
            return false
        }
        guard !requiresPremiumReview || appState.isSubscribed else {
            timer?.invalidate()
            reviewAccessMessage = "分野を選ぶ集中特訓はプレミアムで利用できます。無料のおすすめ復習は苦手克服ホームから続けられます。"
            return false
        }
        guard ReviewAccessPolicy.record(currentQuiz, userID: userID, subscribed: appState.isSubscribed) else {
            timer?.invalidate()
            reviewAccessMessage = "今日の無料復習は終了しました。明日はまた5問復習できます。プレミアムでは全問題を復習できます。"
            return false
        }
        return true
    }

    /// The schedule is read once on appear, so the badge stays on the question after it is answered.
    private var isFinalStageReview: Bool {
        quizLevel == .incorrectAnswer && !isInfiniteMode
            && finalStageReviewKeys.contains(ReviewAccessPolicy.key(currentQuiz))
    }

    private func recordLocalReview(correct: Bool) {
        guard isReviewQuiz, !isInfiniteMode, let userID = authManager.currentUserId else { return }
        if quizLevel == .incorrectAnswer && currentQuiz.id?.hasPrefix("scheduled_local_") != true { return }
        if LocalReviewScheduleStore.recordAnswer(currentQuiz, correct: correct, userID: userID) {
            MissionManager.shared.updateMissionProgress(type: .review, increment: 1) { _ in }
            GuildManager.shared.recordReviewCompleted()
        }
        if connectivity.isConnected {
            ReviewScheduleService.syncLocalReview(currentQuiz, userId: userID, subscribed: appState.isSubscribed)
        }
    }
}

// MARK: - 結果画面からの再挑戦
extension QuizView {
    /// 今回の不正解を、出題した問題データに戻す（結果画面の「不正解を解き直す」用）。
    var incorrectQuestions: [QuizQuestion] {
        var seen = Set<String>()
        return quizResults.filter { !$0.isCorrect }.compactMap { result in
            guard seen.insert(result.question).inserted else { return nil }
            return activeQuizzes.first { $0.question == result.question }
        }
    }

    /// 日課・初回体験・復習は決まった問題を解くので、別の問題には切り替えない。
    var canStartNewSet: Bool {
        !isInfiniteMode && !isReviewQuiz && !isUntimedLearningSession
            && learningContext == nil && reviewResultContext == nil && activeQuizzes.count > 1
    }

    /// 同じカテゴリの問題を並べ直し、直前に出た問題は後ろに回して新しいバトルを始める。
    func startNewQuestionSet() {
        let playedQuestions = Set(quizResults.map(\.question))
        let shuffled = quizzes.shuffled()
        replacementQuizzes = shuffled.filter { !playedQuestions.contains($0.question) }
            + shuffled.filter { playedQuestions.contains($0.question) }

        timer?.invalidate()
        timer = nil
        currentQuizIndex = 0
        remainingSeconds = currentQuiz.recommendedTimeLimit
        selectedAnswerIndex = nil
        hasAnswered = false
        quizResults = []
        answerCount = 0
        correctAnswerCount = 0
        hasPersistedQuizStats = false
        hasHandledCompletion = false
        leagueSessionId = UUID().uuidString
        showExplanationModal = false
        reviewUnansweredReason = nil
        showMonsterDownImage = false
        showAttackImage = false
        attackImpact = nil
        showIncorrectBackground = false
        comboCount = 0
        playerHP = userMaxHp
        startTime = Date()
        endTime = nil
        elapsedTime = nil
        sessionDuration = 0
        monsterType = 1
        configureMonster(for: 1)
        showCompletionMessage = false
        navigateToQuizResultView = false
        InterstitialOpportunityCoordinator.shared.logLearningSetStart(
            surface: "normal_quiz",
            quizLevel: quizLevel,
            learningContext: learningContext
        )
        startTimer()
    }

    /// 敵のHP・攻撃力と、クリア時の経験値・コインを設定する。
    func configureMonster(for newMonsterType: Int) {
        switch quizLevel {
        case .beginner:
            monsterBackground = "beginnerBackground"
            playerExperience = 20
            playerMoney = 10
            // print(playerExperience)
            if playerHP <= 0 {
                playerExperience = 5
                playerMoney = 5
            }
            switch newMonsterType {
            case 1:
                monsterHP = 80
                monsterUnderHP = 80
                monsterAttack = 10
            case 2:
                monsterHP = 120
                monsterUnderHP = 120
                monsterAttack = 15
            case 3:
                monsterHP = 160
                monsterUnderHP = 160
                monsterAttack = 20
            default:
                monsterHP = 30
            }
        case .intermediate:
            monsterBackground = "intermediateBackground"
            playerExperience = 30
            playerMoney = 20
            if userHp <= 0 {
                playerExperience = 5
                playerMoney = 5
            }
            switch newMonsterType {
            case 1:
                monsterHP = 80
                monsterUnderHP = 80
                monsterAttack = 15
            case 2:
                monsterHP = 120
                monsterUnderHP = 120
                monsterAttack = 20
            case 3:
                monsterHP = 160
                monsterUnderHP = 160
                monsterAttack = 25
            default:
                monsterHP = 50
            }
        case .advanced:
            monsterBackground = "advancedBackground"
            playerExperience = 40
            playerMoney = 30
            if userHp <= 0 {
                playerExperience = 5
                playerMoney = 5
            }
            switch newMonsterType {
            case 1:
                monsterHP = 120
                monsterUnderHP = 120
                monsterAttack = 20
            case 2:
                monsterHP = 160
                monsterUnderHP = 160
                monsterAttack = 25
            case 3:
                monsterHP = 200
                monsterUnderHP = 200
                monsterAttack = 30
            default:
                monsterHP = 80
            }
        case .network:
            monsterBackground = "networkBackground"
            playerExperience = 40
            playerMoney = 30
            if userHp <= 0 {
                playerExperience = 5
                playerMoney = 5
            }
            switch newMonsterType {
            case 1:
                monsterHP = 120
                monsterUnderHP = 120
                monsterAttack = 20
            case 2:
                monsterHP = 160
                monsterUnderHP = 160
                monsterAttack = 25
            case 3:
                monsterHP = 200
                monsterUnderHP = 200
                monsterAttack = 30
            default:
                monsterHP = 80
            }
        case .security:
            monsterBackground = "securityBackground"
            playerExperience = 40
            playerMoney = 30
            if userHp <= 0 {
                playerExperience = 5
                playerMoney = 5
            }
            switch newMonsterType {
            case 1:
                monsterHP = 80
                monsterUnderHP = 80
                monsterAttack = 15
            case 2:
                monsterHP = 120
                monsterUnderHP = 120
                monsterAttack = 20
            case 3:
                monsterHP = 160
                monsterUnderHP = 160
                monsterAttack = 25
            default:
                monsterHP = 50
            }
        case .database:
            monsterBackground = "databaseBackground"
            playerExperience = 40
            playerMoney = 30
            if userHp <= 0 {
                playerExperience = 5
                playerMoney = 5
            }
            switch newMonsterType {
            case 1:
                monsterHP = 80
                monsterUnderHP = 80
                monsterAttack = 15
            case 2:
                monsterHP = 120
                monsterUnderHP = 120
                monsterAttack = 20
            case 3:
                monsterHP = 160
                monsterUnderHP = 160
                monsterAttack = 25
            default:
                monsterHP = 50
            }
        case .daily:
            monsterBackground = "dailyBackground"
            playerExperience = 60
            playerMoney = 60
            if userHp <= 0 {
                playerExperience = 5
                playerMoney = 5
            }
            switch newMonsterType {
            case 1:
                monsterHP = 50
                monsterUnderHP = 50
                monsterAttack = 20
            case 2:
                monsterHP = 60
                monsterUnderHP = 60
                monsterAttack = 30
            case 3:
                monsterHP = 70
                monsterUnderHP = 70
                monsterAttack = 40
            default:
                monsterHP = 50
            }
        case .god:
            monsterBackground = "godBackground"
            playerExperience = 200
            playerMoney = 200
            if userHp <= 0 {
                playerExperience = 5
                playerMoney = 5
            }
            switch newMonsterType {
            case 1:
                monsterHP = 80
                monsterUnderHP = 80
                monsterAttack = 500
            case 2:
                monsterHP = 120
                monsterUnderHP = 120
                monsterAttack = 1000
            case 3:
                monsterHP = 160
                monsterUnderHP = 160
                monsterAttack = 1500
            default:
                monsterHP = 1000
            }

        case .timeBeginner:
            monsterBackground = "timeBeginnerBackground"
            playerExperience = 20
            playerMoney = 20
            if userHp <= 0 {
                playerExperience = 5
                playerMoney = 5
            }
            switch newMonsterType {
            case 1:
                monsterHP = 20
                monsterUnderHP = 20
                monsterAttack = 20
            case 2:
                monsterHP = 30
                monsterUnderHP = 30
                monsterAttack = 30
            case 3:
                monsterHP = 40
                monsterUnderHP = 40
                monsterAttack = 40
            default:
                monsterHP = 1000
            }
        case .timeIntermediate:
            monsterBackground = "timeIntermediateBackground"
            playerExperience = 30
            playerMoney = 30
            if userHp <= 0 {
                playerExperience = 5
                playerMoney = 5
            }
            switch newMonsterType {
            case 1:
                monsterHP = 40
                monsterUnderHP = 40
                monsterAttack = 40
            case 2:
                monsterHP = 50
                monsterUnderHP = 50
                monsterAttack = 50
            case 3:
                monsterHP = 60
                monsterUnderHP = 60
                monsterAttack = 60
            default:
                monsterHP = 1000
            }
        case .timeAdvanced:
            monsterBackground = "timeAdvancedBackground"
            playerExperience = 40
            playerMoney = 40
            if userHp <= 0 {
                playerExperience = 5
                playerMoney = 5
            }
            switch newMonsterType {
            case 1:
                monsterHP = 50
                monsterUnderHP = 50
                monsterAttack = 50
            case 2:
                monsterHP = 60
                monsterUnderHP = 60
                monsterAttack = 60
            case 3:
                monsterHP = 70
                monsterUnderHP = 70
                monsterAttack = 70
            default:
                monsterHP = 1000
            }
        case .incorrectAnswer,.incorrectITAnswer,.incorrectInfoAnswer,.incorrectAppliedAnswer,.incorrectESAnswer,.incorrectITStrategyAnswer:
            monsterBackground = "incorrectAnswerBackground"
            playerExperience = 0
            playerMoney = 0
            if playerHP <= 0 {
                playerExperience = 5
                playerMoney = 5
            }
            switch newMonsterType {
            case 1:
                monsterHP = 10
                monsterUnderHP = 10
                monsterAttack = 0
            case 2:
                monsterHP = 10
                monsterUnderHP = 10
                monsterAttack = 0
            case 3:
                monsterHP = 10
                monsterUnderHP = 10
                monsterAttack = 0
            default:
                monsterHP = 10
            }
        case .beginnerStory1:
            monsterBackground = "beginnerBackground"
            playerExperience = 20
            playerMoney = 10
            // print(playerExperience)
            if playerHP <= 0 {
                playerExperience = 5
                playerMoney = 5
            }
            switch newMonsterType {
            case 1:
                monsterHP = 80
                monsterUnderHP = 80
                monsterAttack = 20
            case 2:
                monsterHP = 120
                monsterUnderHP = 120
                monsterAttack = 30
            case 3:
                monsterHP = 160
                monsterUnderHP = 160
                monsterAttack = 40
            default:
                monsterHP = 30
            }
        case .beginnerStory2:
            monsterBackground = "beginnerBackground"
            playerExperience = 20
            playerMoney = 10
            // print(playerExperience)
            if playerHP <= 0 {
                playerExperience = 5
                playerMoney = 5
            }
            switch newMonsterType {
            case 1:
                monsterHP = 80
                monsterUnderHP = 80
                monsterAttack = 20
            case 2:
                monsterHP = 120
                monsterUnderHP = 120
                monsterAttack = 30
            case 3:
                monsterHP = 160
                monsterUnderHP = 160
                monsterAttack = 40
            default:
                monsterHP = 30
            }
        case .beginnerStory3:
            monsterBackground = "beginnerBackground"
            playerExperience = 20
            playerMoney = 10
            // print(playerExperience)
            if playerHP <= 0 {
                playerExperience = 5
                playerMoney = 5
            }
            switch newMonsterType {
            case 1:
                monsterHP = 80
                monsterUnderHP = 80
                monsterAttack = 20
            case 2:
                monsterHP = 120
                monsterUnderHP = 120
                monsterAttack = 30
            case 3:
                monsterHP = 160
                monsterUnderHP = 160
                monsterAttack = 40
            default:
                monsterHP = 30
            }
        case .itStrategy:
            monsterBackground = "itStrategyBackground"
            playerExperience = 20
            playerMoney = 10
            // print(playerExperience)
            if playerHP <= 0 {
                playerExperience = 5
                playerMoney = 5
            }
            switch newMonsterType {
            case 1:
                monsterHP = 80
                monsterUnderHP = 80
                monsterAttack = 15
            case 2:
                monsterHP = 120
                monsterUnderHP = 120
                monsterAttack = 20
            case 3:
                monsterHP = 160
                monsterUnderHP = 160
                monsterAttack = 25
            default:
                monsterHP = 30
            }
        case .infoStrategy:
            monsterBackground = "infoStrategyBackground"
            playerExperience = 20
            playerMoney = 10
            // print(playerExperience)
            if playerHP <= 0 {
                playerExperience = 5
                playerMoney = 5
            }
            switch newMonsterType {
            case 1:
                monsterHP = 80
                monsterUnderHP = 80
                monsterAttack = 15
            case 2:
                monsterHP = 120
                monsterUnderHP = 120
                monsterAttack = 20
            case 3:
                monsterHP = 160
                monsterUnderHP = 160
                monsterAttack = 25
            default:
                monsterHP = 30
            }
        case .appliedStrategy:
            monsterBackground = "appliedStrategyBackground"
            playerExperience = 20
            playerMoney = 10
            // print(playerExperience)
            if playerHP <= 0 {
                playerExperience = 5
                playerMoney = 5
            }
            switch newMonsterType {
            case 1:
                monsterHP = 80
                monsterUnderHP = 80
                monsterAttack = 20
            case 2:
                monsterHP = 120
                monsterUnderHP = 120
                monsterAttack = 30
            case 3:
                monsterHP = 160
                monsterUnderHP = 160
                monsterAttack = 40
            default:
                monsterHP = 30
            }
        case .itTechnology:
            monsterBackground = "itTechnologyBackground"
            playerExperience = 20
            playerMoney = 10
            // print(playerExperience)
            if playerHP <= 0 {
                playerExperience = 5
                playerMoney = 5
            }
            switch newMonsterType {
            case 1:
                monsterHP = 80
                monsterUnderHP = 80
                monsterAttack = 20
            case 2:
                monsterHP = 120
                monsterUnderHP = 120
                monsterAttack = 25
            case 3:
                monsterHP = 160
                monsterUnderHP = 160
                monsterAttack = 30
            default:
                monsterHP = 30
            }
        case .infoTechnology:
            monsterBackground = "infoTechnologyBackground"
            playerExperience = 20
            playerMoney = 10
            // print(playerExperience)
            if playerHP <= 0 {
                playerExperience = 5
                playerMoney = 5
            }
            switch newMonsterType {
            case 1:
                monsterHP = 80
                monsterUnderHP = 80
                monsterAttack = 20
            case 2:
                monsterHP = 120
                monsterUnderHP = 120
                monsterAttack = 25
            case 3:
                monsterHP = 160
                monsterUnderHP = 160
                monsterAttack = 30
            default:
                monsterHP = 30
            }
        case .appliedTechnology:
            monsterBackground = "appliedTechnologyBackground"
            playerExperience = 20
            playerMoney = 10
            // print(playerExperience)
            if playerHP <= 0 {
                playerExperience = 5
                playerMoney = 5
            }
            switch newMonsterType {
            case 1:
                monsterHP = 80
                monsterUnderHP = 80
                monsterAttack = 20
            case 2:
                monsterHP = 120
                monsterUnderHP = 120
                monsterAttack = 25
            case 3:
                monsterHP = 160
                monsterUnderHP = 160
                monsterAttack = 30
            default:
                monsterHP = 30
            }
        case .itManagement:
            monsterBackground = "itManagementBackground"
            playerExperience = 20
            playerMoney = 10
            // print(playerExperience)
            if playerHP <= 0 {
                playerExperience = 5
                playerMoney = 5
            }
            switch newMonsterType {
            case 1:
                monsterHP = 80
                monsterUnderHP = 80
                monsterAttack = 25
            case 2:
                monsterHP = 120
                monsterUnderHP = 120
                monsterAttack = 30
            case 3:
                monsterHP = 160
                monsterUnderHP = 160
                monsterAttack = 35
            default:
                monsterHP = 30
            }
        case .infoManagement:
            monsterBackground = "infoManagementBackground"
            playerExperience = 20
            playerMoney = 10
            // print(playerExperience)
            if playerHP <= 0 {
                playerExperience = 5
                playerMoney = 5
            }
            switch newMonsterType {
            case 1:
                monsterHP = 80
                monsterUnderHP = 80
                monsterAttack = 25
            case 2:
                monsterHP = 120
                monsterUnderHP = 120
                monsterAttack = 30
            case 3:
                monsterHP = 160
                monsterUnderHP = 160
                monsterAttack = 35
            default:
                monsterHP = 30
            }
        case .appliedManagement:
            monsterBackground = "appliedManagementBackground"
            playerExperience = 20
            playerMoney = 10
            // print(playerExperience)
            if playerHP <= 0 {
                playerExperience = 5
                playerMoney = 5
            }
            switch newMonsterType {
            case 1:
                monsterHP = 80
                monsterUnderHP = 80
                monsterAttack = 25
            case 2:
                monsterHP = 120
                monsterUnderHP = 120
                monsterAttack = 30
            case 3:
                monsterHP = 160
                monsterUnderHP = 160
                monsterAttack = 35
            default:
                monsterHP = 30
            }
        case .itBasic:
            monsterBackground = "itBasicBackground"
            playerExperience = 20
            playerMoney = 10
            // print(playerExperience)
            if playerHP <= 0 {
                playerExperience = 5
                playerMoney = 5
            }
            switch newMonsterType {
            case 1:
                monsterHP = 80
                monsterUnderHP = 80
                monsterAttack = 10
            case 2:
                monsterHP = 120
                monsterUnderHP = 120
                monsterAttack = 15
            case 3:
                monsterHP = 160
                monsterUnderHP = 160
                monsterAttack = 20
            default:
                monsterHP = 30
            }
        case .infoBasic:
            monsterBackground = "infoBasicBackground"
            playerExperience = 20
            playerMoney = 10
            // print(playerExperience)
            if playerHP <= 0 {
                playerExperience = 5
                playerMoney = 5
            }
            switch newMonsterType {
            case 1:
                monsterHP = 80
                monsterUnderHP = 80
                monsterAttack = 10
            case 2:
                monsterHP = 120
                monsterUnderHP = 120
                monsterAttack = 15
            case 3:
                monsterHP = 160
                monsterUnderHP = 160
                monsterAttack = 20
            default:
                monsterHP = 30
            }
        case .appliedBasic:
            monsterBackground = "appliedBasicBackground"
            playerExperience = 20
            playerMoney = 10
            // print(playerExperience)
            if playerHP <= 0 {
                playerExperience = 5
                playerMoney = 5
            }
            switch newMonsterType {
            case 1:
                monsterHP = 80
                monsterUnderHP = 80
                monsterAttack = 10
            case 2:
                monsterHP = 120
                monsterUnderHP = 120
                monsterAttack = 15
            case 3:
                monsterHP = 160
                monsterUnderHP = 160
                monsterAttack = 20
            default:
                monsterHP = 30
            }
        case .mugen:
            monsterBackground = "appliedBasicBackground"
            playerExperience = 20
            playerMoney = 10
            // print(playerExperience)
            if playerHP <= 0 {
                playerExperience = 5
                playerMoney = 5
            }
            switch newMonsterType {
            case 1:
                monsterHP = 80
                monsterUnderHP = 80
                monsterAttack = 20
            case 2:
                monsterHP = 120
                monsterUnderHP = 120
                monsterAttack = 30
            case 3:
                monsterHP = 160
                monsterUnderHP = 160
                monsterAttack = 40
            default:
                monsterHP = 30
            }
        case .computerSystem:
            monsterBackground = "computerSystemBackground"
            playerExperience = 20
            playerMoney = 10
            if playerHP <= 0 {
                playerExperience = 5
                playerMoney = 5
            }
            switch newMonsterType {
            case 1:
                monsterHP = 80
                monsterUnderHP = 80
                monsterAttack = 20
            case 2:
                monsterHP = 120
                monsterUnderHP = 120
                monsterAttack = 25
            case 3:
                monsterHP = 160
                monsterUnderHP = 160
                monsterAttack = 30
            default:
                monsterHP = 30
            }
        case .softHard:
            monsterBackground = "softHardBackground"
            playerExperience = 20
            playerMoney = 10
            if playerHP <= 0 {
                playerExperience = 5
                playerMoney = 5
            }
            switch newMonsterType {
            case 1:
                monsterHP = 80
                monsterUnderHP = 80
                monsterAttack = 20
            case 2:
                monsterHP = 120
                monsterUnderHP = 120
                monsterAttack = 25
            case 3:
                monsterHP = 160
                monsterUnderHP = 160
                monsterAttack = 30
            default:
                monsterHP = 30
            }
        case .netwarkTusin:
            monsterBackground = "netwarkTusinBackground"
            playerExperience = 20
            playerMoney = 10
            if playerHP <= 0 {
                playerExperience = 5
                playerMoney = 5
            }
            switch newMonsterType {
            case 1:
                monsterHP = 80
                monsterUnderHP = 80
                monsterAttack = 25
            case 2:
                monsterHP = 120
                monsterUnderHP = 120
                monsterAttack = 30
            case 3:
                monsterHP = 160
                monsterUnderHP = 160
                monsterAttack = 35
            default:
                monsterHP = 30
            }
        case .ESsecurity:
            monsterBackground = "ESsecurityBackground"
            playerExperience = 20
            playerMoney = 10
            if playerHP <= 0 {
                playerExperience = 5
                playerMoney = 5
            }
            switch newMonsterType {
            case 1:
                monsterHP = 80
                monsterUnderHP = 80
                monsterAttack = 30
            case 2:
                monsterHP = 120
                monsterUnderHP = 120
                monsterAttack = 35
            case 3:
                monsterHP = 160
                monsterUnderHP = 160
                monsterAttack = 40
            default:
                monsterHP = 30
            }
            case .kikaku:
                monsterBackground = "kikakuBackground"
                playerExperience = 20
                playerMoney = 10
                if playerHP <= 0 {
                    playerExperience = 5
                    playerMoney = 5
                }
                switch newMonsterType {
                case 1:
                    monsterHP = 80
                    monsterUnderHP = 80
                    monsterAttack = 20
                case 2:
                    monsterHP = 120
                    monsterUnderHP = 120
                    monsterAttack = 25
                case 3:
                    monsterHP = 160
                    monsterUnderHP = 160
                    monsterAttack = 30
                default:
                    monsterHP = 30
            }
        case .sekkei:
            monsterBackground = "sekkeiBackground"
            playerExperience = 20
            playerMoney = 10
            if playerHP <= 0 {
                playerExperience = 5
                playerMoney = 5
            }
            switch newMonsterType {
            case 1:
                monsterHP = 80
                monsterUnderHP = 80
                monsterAttack = 25
            case 2:
                monsterHP = 120
                monsterUnderHP = 120
                monsterAttack =  30
            case 3:
                monsterHP = 160
                monsterUnderHP = 160
                monsterAttack = 35
            default:
                monsterHP = 30
        }
        case .kaihatu:
            monsterBackground = "kaihatuBackground"
            playerExperience = 20
            playerMoney = 10
            if playerHP <= 0 {
                playerExperience = 5
                playerMoney = 5
            }
            switch newMonsterType {
            case 1:
                monsterHP = 80
                monsterUnderHP = 80
                monsterAttack = 30
            case 2:
                monsterHP = 120
                monsterUnderHP = 120
                monsterAttack =  35
            case 3:
                monsterHP = 160
                monsterUnderHP = 160
                monsterAttack = 40
            default:
                monsterHP = 30
        }
        case .unyouhoshu:
            monsterBackground = "unyouHoshuBackground"
            playerExperience = 20
            playerMoney = 10
            if playerHP <= 0 {
                playerExperience = 5
                playerMoney = 5
            }
            switch newMonsterType {
            case 1:
                monsterHP = 80
                monsterUnderHP = 80
                monsterAttack = 35
            case 2:
                monsterHP = 120
                monsterUnderHP = 120
                monsterAttack =  40
            case 3:
                monsterHP = 160
                monsterUnderHP = 160
                monsterAttack = 45
            default:
                monsterHP = 30
        }
        }
    }
}
