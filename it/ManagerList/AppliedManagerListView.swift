//
//  AppliedManagerListView.swift
//  it
//
//  Created by Apple on 2024/03/09.
//

import SwiftUI
import AVFoundation
import Firebase

struct AppliedManagerListView: View {
    @State private var isIntermediateQuizActive: Bool = false
    @State private var isPresentingQuizBeginnerList: Bool = false
    @ObservedObject var authManager = AuthManager.shared
    @State private var isButtonEnabled: Bool = true
    @State private var lastClickedDate: Date = Date()
    @State private var audioPlayerKettei: AVAudioPlayer?
    @State private var isPresentingQuizBeginner: Bool = false
    @State private var isPresentingQuizIntermediate: Bool = false
    @State private var isPresentingQuizAdvanced: Bool = false
    @State private var isPresentingQuizNetwork: Bool = false
    @State private var isPresentingQuizSecurity: Bool = false
    @State private var isPresentingQuizDatabase: Bool = false
    @State private var isPresentingQuizGod: Bool = false
    @State private var isPresentingQuizIncorrectAnswer: Bool = false
    @State private var isSoundOn: Bool = true
    @ObservedObject var audioManager = AudioManager.shared
    @Environment(\.presentationMode) var presentationMode
    @Binding var isPresenting: Bool
    @State private var tutorialNum: Int = 0
    @State private var buttonRect: CGRect = .zero
    @State private var bubbleHeight: CGFloat = 0.0
    @State private var isIncorrectAnswersEmpty: Bool = true
    @StateObject var reward = Reward()
    @State private var showLoginModal: Bool = false
    @State private var isButtonClickable: Bool = false
    @State private var showAlert: Bool = false
    @State private var preFlag: Bool = false
    @EnvironmentObject var appState: AppState
    @EnvironmentObject private var connectivity: ConnectivityMonitor
    @State private var isLoading: Bool = true
    @State private var animateCards: Bool = false
    @State private var incorrectCount: Int = 0
    @StateObject private var accuracyStore = LearningModeAccuracyStore()
    @State private var rewardAnimating = false

    init(isPresenting: Binding<Bool>) {
        _isPresenting = isPresenting
        _lastClickedDate = State(initialValue: Date())
    }


    var body: some View {
        ZStack {
            backgroundView

            VStack(spacing: 0) {
                navigationBar(title: "応用情報技術者試験")

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 24) {
                        reviewSection
                        categorySection
                    }
                    .padding(.top, 16)
                    .padding(.bottom, 120)
                }
            }

            floatingRewardButton

            if tutorialNum == 2 {
                tutorialOverlay
            }
        }
        .onAppear {
            setupView()
            if !connectivity.isConnected {
                isLoading = false
                animateCards = true
            }
        }
        .task(id: accuracyRefreshID) {
            await accuracyStore.refresh(
                userID: authManager.currentUserId,
                isConnected: connectivity.isConnected,
                isShowingQuiz: isShowingQuiz
            )
        }
        .onChange(of: connectivity.isConnected) { isConnected in
            if isConnected {
                setupView()
            } else {
                isLoading = false
                incorrectCount = 0
                isIncorrectAnswersEmpty = true
            }
        }
        .gesture(swipeBackGesture)
        .fullScreenCover(isPresented: $preFlag) {
            PreView(
                audioManager: audioManager,
                source: .review(incorrectCount: incorrectCount)
            )
        }
        .fullScreenCover(isPresented: $isPresentingQuizIncorrectAnswer) {
            QuizAppliedIncorrectAnswerListView(isPresenting: $isPresentingQuizIncorrectAnswer)
        }
        .fullScreenCover(isPresented: $isPresentingQuizDatabase) {
            QuizAppliedBasicListView(isPresenting: $isPresentingQuizDatabase)
        }
        .fullScreenCover(isPresented: $isPresentingQuizIntermediate) {
            QuizAppliedStrategyListView(isPresenting: $isPresentingQuizIntermediate)
        }
        .fullScreenCover(isPresented: $isPresentingQuizAdvanced) {
            QuizAppliedManagementListView(isPresenting: $isPresentingQuizAdvanced)
        }
        .fullScreenCover(isPresented: $isPresentingQuizGod) {
            QuizAppliedTechnologyListView(isPresenting: $isPresentingQuizGod)
        }
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text("報酬獲得！"),
                message: Text("1時間だけ獲得した経験値とコインが2倍"),
                dismissButton: .default(Text("OK")) {
                    showAlert = false
                    reward.rewardEarned = false
                }
            )
        }
        .navigationBarHidden(true)
    }

    func isIPad() -> Bool {
        return UIDevice.current.userInterfaceIdiom == .pad
    }

    func fetchNumberOfIncorrectAnswers(userId: String, completion: @escaping (Int) -> Void) {
    let ref = Database.database().reference().child("IncorrectAppliedAnswers").child(userId)
    ref.observeSingleEvent(of: .value) { snapshot in
        
    let count = snapshot.childrenCount // 子ノードの数を取得
    completion(Int(count))
        print("count:\(count)")
        self.isIncorrectAnswersEmpty = (count == 0)
    }
    }
    func isSmallDevice() -> Bool {
        return UIScreen.main.bounds.width < 390
    }
    
    private var isShowingQuiz: Bool {
        isPresentingQuizIntermediate || isPresentingQuizAdvanced || isPresentingQuizNetwork
            || isPresentingQuizDatabase || isPresentingQuizGod || isPresentingQuizIncorrectAnswer || preFlag
    }

    private var accuracyRefreshID: String {
        "\(authManager.currentUserId ?? "")-\(connectivity.isConnected)-\(isShowingQuiz)"
    }

    private var accuracyStatus: String? {
        accuracyStore.status(userID: authManager.currentUserId, isConnected: connectivity.isConnected)
    }

    private var showsPreviousAccuracy: Bool {
        accuracyStore.showsPreviousAccuracy(userID: authManager.currentUserId, isConnected: connectivity.isConnected)
    }

    private var backgroundView: some View {
        LearningModeGlassBackground()
    }

    private func navigationBar(title: String) -> some View {
        HStack {
            Button(action: {
                generateHapticFeedback()
                audioManager.playCancelSound()
                presentationMode.wrappedValue.dismiss()
            }) {
                HStack(spacing: 6) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 16, weight: .semibold))
                    Text("戻る")
                        .font(.system(size: 16, weight: .medium))
                }
                .foregroundColor(Color(hex: "11998e"))
            }
            .buttonStyle(.plain)

            Spacer()

            Text(title)
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.primary)

            Spacer()

            HStack(spacing: 6) { Image(systemName: "chevron.left"); Text("戻る") }
                .opacity(0)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(.ultraThinMaterial)
    }

    private var reviewSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 10) {
                RoundedRectangle(cornerRadius: 2)
                    .fill(LinearGradient(
                        colors: [Color(hex: "f093fb"), Color(hex: "f5576c")],
                        startPoint: .top,
                        endPoint: .bottom
                    ))
                    .frame(width: 4, height: 20)

                Image(systemName: "arrow.counterclockwise")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(Color(hex: "f093fb"))

                Text("不正解した問題を復習")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.secondary)

                Spacer()
            }
            .padding(.horizontal, 20)

            reviewButton
                .padding(.horizontal, 16)
                .opacity(animateCards ? 1 : 0)
                .offset(y: animateCards ? 0 : 20)
                .animation(.spring(response: 0.5, dampingFraction: 0.8).delay(0.1), value: animateCards)
        }
    }

    private var reviewButton: some View {
        Button(action: {
            generateHapticFeedback()
            audioManager.playKetteiSound()
            if appState.isBannerVisible {
                preFlag = true
            } else if !isIncorrectAnswersEmpty {
                isPresentingQuizIncorrectAnswer = true
            }
        }) {
            LearningModeGlassCard(
                title: "復習問題",
                subtitle: isLoading ? "復習問題を読み込み中" : (!isIncorrectAnswersEmpty ? "\(incorrectCount)問の復習問題" : "復習問題なし"),
                count: accuracyStore.count(for: .incorrectAppliedAnswer, userID: authManager.currentUserId),
                status: accuracyStatus,
                showsPreviousAccuracy: showsPreviousAccuracy,
                icon: "arrow.counterclockwise",
                badge: appState.isBannerVisible ? "Premium" : (!isIncorrectAnswersEmpty ? "\(incorrectCount)問" : nil),
                isCompact: true,
                gradient: QuizColors.review
            )
            .opacity(isIncorrectAnswersEmpty && !appState.isBannerVisible && !isLoading ? 0.6 : 1)
        }
        .buttonStyle(.plain)
        .disabled(isIncorrectAnswersEmpty && !appState.isBannerVisible)
        .accessibilityIdentifier("learning.applied.review")
    }

    private var categorySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 10) {
                RoundedRectangle(cornerRadius: 2)
                    .fill(LinearGradient(
                        colors: [Color(hex: "11998e"), Color(hex: "38ef7d")],
                        startPoint: .top,
                        endPoint: .bottom
                    ))
                    .frame(width: 4, height: 20)

                Image(systemName: "folder.fill")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(Color(hex: "11998e"))

                Text("問題カテゴリを選択")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.secondary)

                Spacer()
            }
            .padding(.horizontal, 20)

            VStack(spacing: 12) {
                categoryButton(
                    title: "基礎理解",
                    subtitle: "応用・アルゴリズム基礎",
                    icon: "book.fill",
                    quizLevel: .appliedBasic,
                    gradient: LinearGradient(
                        colors: [Color(hex: "11998e"), Color(hex: "38ef7d")],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    delay: 0.15
                ) { isPresentingQuizDatabase = true }
                .background(GeometryReader { g in
                    Color.clear.preference(key: ViewPositionKey.self, value: [g.frame(in: .global)])
                })

                categoryButton(
                    title: "ストラテジ",
                    subtitle: "経営戦略・業務分析",
                    icon: "chart.line.uptrend.xyaxis",
                    quizLevel: .appliedStrategy,
                    gradient: LinearGradient(
                        colors: [Color(hex: "4facfe"), Color(hex: "00f2fe")],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    delay: 0.2
                ) { isPresentingQuizIntermediate = true }

                categoryButton(
                    title: "マネジメント",
                    subtitle: "プロジェクト・サービス管理",
                    icon: "person.3.fill",
                    quizLevel: .appliedManagement,
                    gradient: LinearGradient(
                        colors: [Color(hex: "fa709a"), Color(hex: "fee140")],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    delay: 0.25
                ) { isPresentingQuizAdvanced = true }

                categoryButton(
                    title: "テクノロジ",
                    subtitle: "開発技術・ネットワーク・DB",
                    icon: "cpu.fill",
                    quizLevel: .appliedTechnology,
                    gradient: LinearGradient(
                        colors: [Color(hex: "667eea"), Color(hex: "764ba2")],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    delay: 0.3
                ) { isPresentingQuizGod = true }
            }
            .padding(.horizontal, 16)
        }
    }

    private func categoryButton(
        title: String,
        subtitle: String,
        icon: String,
        quizLevel: QuizLevel,
        gradient: LinearGradient,
        delay: Double,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: {
            generateHapticFeedback()
            audioManager.playKetteiSound()
            action()
        }) {
            LearningModeGlassCard(
                title: title,
                subtitle: subtitle,
                count: accuracyStore.count(for: quizLevel, userID: authManager.currentUserId),
                status: accuracyStatus,
                showsPreviousAccuracy: showsPreviousAccuracy,
                icon: icon,
                isCompact: true,
                gradient: gradient
            )
        }
        .buttonStyle(.plain)
        .accessibilityIdentifier("learning.applied.\(quizLevel.description)")
        .opacity(animateCards ? 1 : 0)
        .offset(y: animateCards ? 0 : 20)
        .animation(.spring(response: 0.5, dampingFraction: 0.8).delay(delay), value: animateCards)
    }

    private var floatingRewardButton: some View {
        VStack {
            Spacer()
            HStack {
                rewardButton
                    .padding(.leading, 16)
                    .padding(.bottom, 30)
                Spacer()
            }
        }
    }


    private var rewardButton: some View {
        Button(action: {
            generateHapticFeedback()
            reward.ExAndMoReward()
        }) {
            ZStack {
                // Outer glow
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                Color(hex: "ffd700").opacity(0.4),
                                Color(hex: "ffd700").opacity(0)
                            ],
                            center: .center,
                            startRadius: 30,
                            endRadius: 60
                        )
                    )
                    .frame(width: 120, height: 120)
                    .scaleEffect(rewardAnimating ? 1.2 : 1.0)
                    .opacity(reward.rewardLoaded ? 1 : 0)
                
                // Main button
                ZStack {
                    Circle()
                        .fill(
                            reward.rewardLoaded ?
                            LinearGradient(
                                colors: [Color(hex: "ffd700"), Color(hex: "ff8c00")],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ) :
                            LinearGradient(
                                colors: [Color.gray.opacity(0.5), Color.gray.opacity(0.3)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 90, height: 90)
                        .shadow(color: reward.rewardLoaded ? Color(hex: "ffd700").opacity(0.5) : .clear, radius: 10)
                    
                    VStack(spacing: 2) {
                        Text("動画視聴で")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(.white.opacity(0.9))
                        
                        Text("経験値とコインが")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(.white.opacity(0.9))
                        Text("2倍に")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.white.opacity(0.9))
                    }
                }
            }
        }
        .buttonStyle(PlainButtonStyle())
        .disabled(!reward.rewardLoaded)
        .onChange(of: reward.rewardEarned) { earned in
            showAlert = earned
        }
        .onAppear {
            if reward.rewardLoaded {
                withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                    rewardAnimating = true
                }
            }
        }
        .onChange(of: reward.rewardLoaded) { loaded in
            if loaded {
                withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                    rewardAnimating = true
                }
            }
        }
    }

    private var tutorialOverlay: some View {
        TutorialSpotlight(
            spotlight: buttonRect,
            cornerRadius: 20,
            step: 3,
            icon: "hand.tap.fill",
            title: "「基礎理解」をタップ",
            message: "まずは基礎から始めてみましょう",
            accent: [Color(hex: "fa709a"), Color(hex: "fee140")],
            placement: .auto,
            onSkip: {
                generateHapticFeedback()
                tutorialNum = 0
                authManager.updateTutorialNum(userId: authManager.currentUserId ?? "", tutorialNum: 0) { _ in }
            }
        )
        .onTapGesture {
            audioManager.playSound()
            tutorialNum = 0
            authManager.updateTutorialNum(userId: authManager.currentUserId ?? "", tutorialNum: 3) { _ in }
        }
    }

    private var swipeBackGesture: some Gesture {
        DragGesture()
            .onEnded { value in
                if value.translation.width > 80 {
                    presentationMode.wrappedValue.dismiss()
                }
            }
    }

    private func setupView() {
        guard connectivity.isConnected else { return }
        reward.LoadReward()

        if let uid = authManager.currentUserId {
            fetchNumberOfIncorrectAnswers(userId: uid) { count in
                DispatchQueue.main.async {
                    self.incorrectCount = count
                    self.isIncorrectAnswersEmpty = (count == 0)
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    self.isLoading = false
                }
            }
        }

        authManager.fetchUserInfo { (_, _, _, _, _, tutorialNum) in
            if let t = tutorialNum { self.tutorialNum = t }
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            animateCards = true
        }
    }



}

#Preview {
    AppliedManagerListView(isPresenting: .constant(false))
        .environmentObject(AppState())
        .environmentObject(ConnectivityMonitor.shared)
}
